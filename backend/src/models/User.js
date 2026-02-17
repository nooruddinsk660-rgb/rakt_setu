const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
        trim: true
    },
    email: {
        type: String,
        required: true,
        unique: true,
        trim: true,
        lowercase: true,
        index: true
    },
    phone: {
        type: String,
        required: true,
        trim: true,
        unique: true,
        sparse: true
    },
    password: {
        type: String,
        required: true
    },
    role: {
        type: String,
        enum: ['ADMIN', 'MANAGER', 'HR', 'HELPLINE', 'VOLUNTEER'],
        default: 'VOLUNTEER'
    },
    city: {
        type: String,
        required: true,
        trim: true
    },
    isActive: {
        type: Boolean,
        default: true
    },
    failedLoginAttempts: {
        type: Number,
        default: 0
    },
    lockUntil: {
        type: Date
    },
    lastLogin: {
        type: Date
    }
}, {
    timestamps: true
});

// Pre-save hook to hash password
userSchema.pre('save', async function () {
    if (!this.isModified('password')) return;

    try {
        const salt = await bcrypt.genSalt(10);
        this.password = await bcrypt.hash(this.password, salt);
    } catch (error) {
        throw error;
    }
});

// Method to compare password
userSchema.methods.comparePassword = async function (candidatePassword) {
    return await bcrypt.compare(candidatePassword, this.password);
};

// Method to check if account is locked
userSchema.methods.isLocked = function () {
    return !!(this.lockUntil && this.lockUntil > Date.now());
};

// Method to increment failed login attempts
userSchema.methods.incrementLoginAttempts = async function () {
    // If lock has expired, reset attempts and remove lock
    if (this.lockUntil && this.lockUntil < Date.now()) {
        return await this.updateOne({
            $set: { failedLoginAttempts: 1 },
            $unset: { lockUntil: 1 }
        });
    }

    // Otherwise, increment attempts
    const updates = { $inc: { failedLoginAttempts: 1 } };

    // Lock account if attempts reach 5 (and not already locked)
    if (this.failedLoginAttempts + 1 >= 5 && !this.isLocked()) {
        updates.$set = { lockUntil: Date.now() + 15 * 60 * 1000 }; // Lock for 15 minutes
    }

    return await this.updateOne(updates);
};

// Method to reset failed login attempts
userSchema.methods.resetLoginAttempts = async function () {
    return await this.updateOne({
        $set: { failedLoginAttempts: 0 },
        $unset: { lockUntil: 1 }
    });
};

const User = mongoose.model('User', userSchema);
module.exports = User;
