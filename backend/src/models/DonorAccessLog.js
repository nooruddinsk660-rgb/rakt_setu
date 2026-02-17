const mongoose = require('mongoose');

const donorAccessLogSchema = new mongoose.Schema({
    donorId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Donor',
        required: true
    },
    accessedBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    purpose: {
        type: String,
        required: true
    },
    timestamp: {
        type: Date,
        default: Date.now
    }
}, {
    timestamps: true
});

const DonorAccessLog = mongoose.model('DonorAccessLog', donorAccessLogSchema);
module.exports = DonorAccessLog;
