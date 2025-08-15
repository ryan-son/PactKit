let NATIVE_IDENTITY_PUBLIC_KEY_B64 = window.NATIVE_IDENTITY_PUBLIC_KEY;

let jsEphemeralKeyPair;
let sessionKey;

const handshakeButton = document.getElementById('handshakeButton');
const sendButton = document.getElementById('sendButton');
const messageInput = document.getElementById('messageInput');
const logDiv = document.getElementById('log');

const log = (message) => {
    console.log(message);
    logDiv.innerHTML += `<div>${new Date().toLocaleTimeString()}: ${message}</div>`;
};

const base64ToArrayBuffer = (b64) => {
    const byteString = atob(b64);
    const byteArray = new Uint8Array(byteString.length);
    for (let i = 0; i < byteString.length; i++) {
        byteArray[i] = byteString.charCodeAt(i);
    }
    return byteArray.buffer;
};

const arrayBufferToBase64 = (buffer) => {
    let binary = '';
    const bytes = new Uint8Array(buffer);
    for (let i = 0; i < bytes.byteLength; i++) {
        binary += String.fromCharCode(bytes[i]);
    }
    return btoa(binary);
};

async function hkdf(secret, salt, info, keyLen) {
    const HASH_ALG = 'SHA-256';
    const saltKey = await crypto.subtle.importKey('raw', salt, { name: 'HMAC', hash: HASH_ALG }, false, ['sign']);
    const prk = await crypto.subtle.sign('HMAC', saltKey, secret);

    const prkKey = await crypto.subtle.importKey('raw', prk, { name: 'HMAC', hash: HASH_ALG }, false, ['sign']);
    let okm = new Uint8Array();
    let t = new Uint8Array();
    const infoBuffer = new Uint8Array(info);

    for (let i = 1; okm.length < keyLen; i++) {
        const counter = new Uint8Array([i]);
        const dataToSign = new Uint8Array(t.length + infoBuffer.length + counter.length);
        dataToSign.set(t, 0);
        dataToSign.set(infoBuffer, t.length);
        dataToSign.set(counter, t.length + infoBuffer.length);
        t = new Uint8Array(await crypto.subtle.sign('HMAC', prkKey, dataToSign));

        const newOkm = new Uint8Array(okm.length + t.length);
        newOkm.set(okm, 0);
        newOkm.set(t, okm.length);
        okm = newOkm;
    }

    return okm.slice(0, keyLen).buffer;
}

function postToNative(type, payload) {
    const message = JSON.stringify({ type, payload });
    if (window.webkit && window.webkit.messageHandlers.pactkit) {
        window.webkit.messageHandlers.pactkit.postMessage(message);
    } else {
        log("Error: Native message handler 'pactkit' not found.");
    }
}

window.handleNativeResponse = async function(responseJsonString) {
    log(`⬇️ Received response from Native: ${responseJsonString}`);
    const response = JSON.parse(responseJsonString);
    const responseType = response.type;

    if (response.type == "handshakeResponse") {
        await handleHandshakeResponse(response.payload);
    } else if (response.type == "encryptedMessage") {
        try {
            const encryptedData = base64ToArrayBuffer(response.payload.ciphertext);
            const nonce = encryptedData.slice(0, 12);
            const ciphertext = encryptedData.slice(12);

            const decryptedData = await crypto.subtle.decrypt(
                { name: 'AES-GCM', iv: nonce },
                sessionKey,
                ciphertext
            );

            const decryptedMessage = new TextDecoder().decode(decryptedData);
            log(`✉️ Decrypted message from Native: "${decryptedMessage}"`);
        } catch (error) {
            log(`❌ Decryption failed: ${error}`);
        }
    }
};

async function startHandshake() {
    log("🤝 Starting handshake...");

    if (!window.NATIVE_IDENTITY_PUBLIC_KEY) {
        log("❌ Error: Native identity key not injected.");
        return;
    }

    jsEphemeralKeyPair = await crypto.subtle.generateKey(
        { name: 'ECDH', namedCurve: 'P-256' },
        true,
        ['deriveBits']
    );

    const jsPublicKeyRaw = await crypto.subtle.exportKey('raw', jsEphemeralKeyPair.publicKey);

    const requestPayload = { ephemeralPublicKey: arrayBufferToBase64(jsPublicKeyRaw) };

    log(`⬆️ Sending handshake request to Native (65 bytes)...`);
    postToNative("handshakeRequest", requestPayload);
}

async function handleHandshakeResponse(payload) {
    try {
        const hostKeyWithPrefix = base64ToArrayBuffer(payload.ephemeralPublicKey);
        const signatureData = base64ToArrayBuffer(payload.signature);

        const jsKeyWithPrefix = await crypto.subtle.exportKey('raw', jsEphemeralKeyPair.publicKey);

        const hostKeyForTranscript = hostKeyWithPrefix.slice(1);
        const jsKeyForTranscript = jsKeyWithPrefix.slice(1);

        const transcript = new Uint8Array([
            ...new Uint8Array(hostKeyForTranscript),
            ...new Uint8Array(jsKeyForTranscript)
        ]);

        const nativeIdentityPublicKey = await crypto.subtle.importKey(
            'raw', base64ToArrayBuffer(NATIVE_IDENTITY_PUBLIC_KEY_B64),
            { name: 'Ed25519' }, true, ['verify']
        );
        const isSignatureValid = await crypto.subtle.verify('Ed25519', nativeIdentityPublicKey, signatureData, transcript);

        if (!isSignatureValid) {
            throw new Error("Signature verification failed.");
        }
        log("✅ Signature verification successful!");

        const hostEphemeralPublicKey = await crypto.subtle.importKey(
            'raw',
            hostKeyWithPrefix,
            { name: 'ECDH', namedCurve: 'P-256' },
            false,
            []
        );
        const sharedSecret = await crypto.subtle.deriveBits(
            { name: 'ECDH', public: hostEphemeralPublicKey },
            jsEphemeralKeyPair.privateKey,
            256
        );

        const salt = new TextEncoder().encode('PactKit-Channel-Establishment-Salt');
        const info = transcript; // 128 bytes transcript
        const derivedKeyData = await hkdf(sharedSecret, salt, info, 32);

        sessionKey = await crypto.subtle.importKey('raw', derivedKeyData, { name: 'AES-GCM' }, true, ['encrypt', 'decrypt']);

        log("🔑 Secure channel established. Ready to send messages.");

        handshakeButton.disabled = true;
        sendButton.disabled = false;
        messageInput.disabled = false;
    } catch (error) {
        log(`❌ Handshake failed: ${error}`);
    }
}

async function sendMessage() {
    if (!sessionKey) {
        log("⚠️ Handshake not completed. Cannot send message.");
        return;
    }
    const message = messageInput.value;
    if (!message) {
        log("⚠️ Please enter a message.");
        return;
    }

    try {
        const nonce = crypto.getRandomValues(new Uint8Array(12)); // 96-bit IV for AES-GCM
        const messageData = new TextEncoder().encode(message);

        const encryptedData = await crypto.subtle.encrypt({ name: 'AES-GCM', iv: nonce }, sessionKey, messageData);

        const combinedData = new Uint8Array(nonce.length + encryptedData.byteLength);
        combinedData.set(nonce, 0);
        combinedData.set(new Uint8Array(encryptedData), nonce.length);

        const encryptedPayload = { ciphertext: arrayBufferToBase64(combinedData) };

        log(`⬆️ Sending encrypted message: "${message}"`);
        postToNative("encryptedMessage", encryptedPayload);
        messageInput.value = "";

    } catch (error) {
        log(`❌ Encryption failed: ${error}`);
    }
}

handshakeButton.addEventListener('click', startHandshake);
sendButton.addEventListener('click', sendMessage);
log("JavaScript loaded. Waiting for Native Identity Key...");

const keyCheckInterval = setInterval(() => {
    if (window.NATIVE_IDENTITY_PUBLIC_KEY) {
        NATIVE_IDENTITY_PUBLIC_KEY_B64 = window.NATIVE_IDENTITY_PUBLIC_KEY;
        log("✅ Native Identity Key injected.");
        clearInterval(keyCheckInterval);
    }
}, 100);
