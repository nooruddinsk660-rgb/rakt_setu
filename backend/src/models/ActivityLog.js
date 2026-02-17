const mongoose = require('mongoose');

const activityLogSchema = new mongoose.Schema({
    volunteerId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'VolunteerProfile',
        required: true
    },
    activityType: {
        type: String,
        enum: ['EVENT', 'HELPLINE'],
        required: true
    },
    referenceId: {
        type: mongoose.Schema.Types.ObjectId,
        // Ref could be 'Event' or 'HelplineRequest' models in future
        required: true
    },
    pointsEarned: {
        type: Number,
        default: 0
    },
    description: {
        type: String
    },
    timestamp: {
        type: Date,
        default: Date.now
    }
}, {
    timestamps: true
});

const ActivityLog = mongoose.model('ActivityLog', activityLogSchema);
module.exports = ActivityLog;
