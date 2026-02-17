const mongoose = require('mongoose');

const helplineRequestSchema = new mongoose.Schema({
    patientName: {
        type: String,
        required: true,
        trim: true
    },
    bloodGroup: {
        type: String,
        enum: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
        required: true
    },
    unitsRequired: {
        type: Number,
        required: true,
        min: 1
    },
    hospital: {
        type: String,
        required: true
    },
    city: {
        type: String,
        required: true,
        index: true
    },
    urgencyLevel: {
        type: String,
        enum: ['Normal', 'Urgent', 'Critical'],
        default: 'Normal'
    },
    status: {
        type: String,
        enum: ['Pending', 'Assigned', 'InProgress', 'Completed', 'Escalated', 'Cancelled'],
        default: 'Pending',
        index: true
    },
    assignedVolunteer: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'VolunteerProfile'
    },
    requestedBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    assignedAt: {
        type: Date
    },
    firstResponseAt: {
        type: Date
    },
    resolvedAt: {
        type: Date
    },
    // Mandatory hackathon requirement
    callRemark: {
        type: String,
        trim: true
    }
}, {
    timestamps: true
});

const HelplineRequest = mongoose.model('HelplineRequest', helplineRequestSchema);
module.exports = HelplineRequest;
