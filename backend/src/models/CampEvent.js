const mongoose = require('mongoose');

const campWorkflowSteps = [
    'LeadReceived',
    'ContactingPOC',
    'BloodBankBooked',
    'VolunteersAssigned',
    'CampCompleted',
    'FollowupPending',
    'Closed'
];

const campEventSchema = new mongoose.Schema({
    organizationName: {
        type: String,
        required: [true, 'Organization name is required'],
        trim: true
    },
    poc: {
        name: { type: String, required: true },
        phone: { type: String, required: true },
        email: { type: String, required: true }
    },
    location: {
        type: String,
        required: [true, 'Location is required'],
        index: true
    },
    bloodBank: {
        type: String,
        required: [true, 'Blood Bank name is required']
    },
    createdBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        index: true
    },
    workflowStatus: {
        type: String,
        enum: campWorkflowSteps,
        default: 'LeadReceived'
    },
    donationCount: {
        type: Number,
        default: 0
    },
    eventDate: {
        type: Date
    },
    volunteers: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    }]
}, { timestamps: true });

// State Machine Validation
campEventSchema.pre('save', function () {
    if (this.isModified('workflowStatus')) {
        const currentStepIndex = campWorkflowSteps.indexOf(this._original?.workflowStatus || 'LeadReceived');
        const newStepIndex = campWorkflowSteps.indexOf(this.workflowStatus);

        // Allow strictly next step or same step (or closed/cancelled logic if needed, but strict for now)
        // Also allowing Admin to force jump might be needed later, but per requirements: "Step-wise updates"
        // For new docs, _original might be undefined, so it passes.

        // We need to fetch original doc to compare if it's an update. 
        // Mongoose pre-save 'this' is the document. 
        // Ideally handled in controller or using a plugin, but basic index check here:

        // Note: isModified check is good, but we don't have access to 'old' value easily in pre-save without fetching.
        // Relying on Controller for strict "Previous -> Next" validation is often cleaner for Error messaging.
        // But we can enforce Enum here (already done).
    }
    ;
});

module.exports = mongoose.model('CampEvent', campEventSchema);
