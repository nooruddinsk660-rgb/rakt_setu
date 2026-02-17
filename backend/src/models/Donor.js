const mongoose = require('mongoose');

const donorSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
        trim: true
    },
    bloodGroup: {
        type: String,
        enum: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
        required: true,
        index: true
    },
    phoneEncrypted: {
        type: String,
        required: true
    },
    city: {
        type: String,
        required: true,
        trim: true,
        index: true
    },
    lastDonationDate: {
        type: Date
    },
    nextEligibleDate: {
        type: Date
    },
    availabilityStatus: {
        type: Boolean,
        default: true
    },
    createdBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    }
}, {
    timestamps: true
});

// Pre-save hook to calculate next eligible date
donorSchema.pre('save', function () {
    if (this.isModified('lastDonationDate') && this.lastDonationDate) {
        const nextDate = new Date(this.lastDonationDate);
        nextDate.setDate(nextDate.getDate() + 90); // +90 days rule
        this.nextEligibleDate = nextDate;
    }
});

const Donor = mongoose.model('Donor', donorSchema);
module.exports = Donor;
