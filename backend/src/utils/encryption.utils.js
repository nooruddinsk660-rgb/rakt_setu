const crypto = require('crypto');
const { ENCRYPTION_KEY, ENCRYPTION_IV } = require('../config/env');

const algorithm = 'aes-256-cbc';

// Ensure key is 32 bytes and iv is 16 bytes
const key = crypto.scryptSync(ENCRYPTION_KEY, 'salt', 32);
const iv = Buffer.from(ENCRYPTION_IV, 'utf8').slice(0, 16);

const encrypt = (text) => {
    const cipher = crypto.createCipheriv(algorithm, key, iv);
    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    return encrypted;
};

const decrypt = (encryptedText) => {
    const decipher = crypto.createDecipheriv(algorithm, key, iv);
    let decrypted = decipher.update(encryptedText, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    return decrypted;
};

module.exports = { encrypt, decrypt };
