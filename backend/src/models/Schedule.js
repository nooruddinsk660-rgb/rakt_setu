const mongoose = require('mongoose');

const scheduleSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        unique: true
    },
    availableDays: {
        type: [String],
        enum: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        default: []
    },
    timeSlots: {
        type: [String],
        // Example format: '10:00-12:00', '14:00-16:00'
        default: []
    },
    isLocked: {
        type: Boolean,
        default: false
    }
}, { timestamps: true });

module.exports = mongoose.model('Schedule', scheduleSchema);
