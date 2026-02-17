require('dotenv').config();

module.exports = {
    PORT: process.env.PORT || 5000,
    MONGO_URI: process.env.MONGO_URI || 'mongodb://localhost:27017/raktSetu',
    NODE_ENV: process.env.NODE_ENV || 'development',
    JWT_SECRET: process.env.JWT_SECRET || 'your_secret_key_here',
    JWT_REFRESH_SECRET: process.env.JWT_REFRESH_SECRET || 'your_refresh_secret_key_here',
    JWT_ACCESS_EXPIRATION: process.env.JWT_ACCESS_EXPIRATION || '15m',
    JWT_REFRESH_EXPIRATION: process.env.JWT_REFRESH_EXPIRATION || '7d',
    ENCRYPTION_KEY: process.env.ENCRYPTION_KEY || '12345678901234567890123456789012', // 32 chars
    ENCRYPTION_IV: process.env.ENCRYPTION_IV || '1234567890123456' // 16 chars
};
