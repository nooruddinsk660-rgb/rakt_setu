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
        enum: ['ADMIN', 'MANAGER', 'HR', 'HELPLINE', 'VOLUNTEER', 'DONOR', 'HOSPITAL', 'PATIENT'],
        default: 'VOLUNTEER'
    },
    roleRequest: {
        type: String,
        enum: ['MANAGER', 'HR', 'HELPLINE', 'HOSPITAL', 'NONE'],
        default: 'NONE'
    },
    city: {
        type: String,
        required: true,
        trim: true
    },
    location: {
        type: {
            type: String,
            enum: ['Point'],
            default: 'Point'
        },
        coordinates: {
            type: [Number], // [longitude, latitude]
            index: '2dsphere'
        }
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
    },
    // --- Hospital Specific Fields ---
    hospitalDetails: {
        hospitalName: { type: String, trim: true },
        licenseNumber: { type: String, trim: true },
        website: { type: String, trim: true }
    },
    // --- Patient/Recipient Specific Fields ---
    emergencyStatus: {
        type: Boolean,
        default: false
    },
    // --- Donor Specific Fields ---
    bloodGroup: {
        type: String,
        enum: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
        // Not required for all users (e.g. Admins might not donate)
        required: false
    },
    availabilityStatus: {
        type: Boolean,
        default: true
    },
    lastDonationDate: {
        type: Date
    },
    nextEligibleDate: {
        type: Date
    }
}, {
    timestamps: true
});

// Pre-save hook to hash password and calculate eligibility
userSchema.pre('save', async function () {
    // Hash Password
    if (this.isModified('password')) {
        try {
            const salt = await bcrypt.genSalt(10);
            this.password = await bcrypt.hash(this.password, salt);
        } catch (error) {
            throw error;
        }
    }

    // Calculate Next Eligible Date
    if (this.isModified('lastDonationDate') && this.lastDonationDate) {
        const nextDate = new Date(this.lastDonationDate);
        nextDate.setDate(nextDate.getDate() + 90); // +90 days rule
        this.nextEligibleDate = nextDate;
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
