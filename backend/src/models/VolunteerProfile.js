const mongoose = require('mongoose');

const volunteerProfileSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        unique: true
    },
    bloodGroup: {
        type: String,
        enum: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
        required: true
    },
    availabilityStatus: {
        type: Boolean,
        default: true
    },
    totalEvents: {
        type: Number,
        default: 0
    },
    totalHelplines: {
        type: Number,
        default: 0
    },
    performanceScore: {
        type: Number,
        default: 0
    },
    status: {
        type: String,
        enum: ['Active', 'Inactive'],
        default: 'Active'
    },
    lastActive: {
        type: Date,
        default: Date.now
    }
}, {
    timestamps: true
});

// Method to recalculate score
volunteerProfileSchema.methods.calculateScore = async function () {
    // Score formula: (events * 3) + (helplines * 5)
    // We can add responseSpeedWeight later if needed
    this.performanceScore = (this.totalEvents * 3) + (this.totalHelplines * 5);
    return this.save();
};

const VolunteerProfile = mongoose.model('VolunteerProfile', volunteerProfileSchema);
module.exports = VolunteerProfile;
