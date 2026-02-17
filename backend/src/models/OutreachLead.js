const mongoose = require('mongoose');

const outreachLeadSchema = new mongoose.Schema({
    organizationName: {
        type: String,
        required: [true, 'Organization name is required'],
        trim: true,
        index: true // Single index for basic lookups
    },
    pocDetails: {
        name: { type: String, required: true },
        phone: { type: String, required: true },
        email: { type: String, trim: true }
    },
    purpose: {
        type: String,
        required: true
    },
    type: {
        type: String,
        enum: ['Awareness', 'Camp'],
        required: true
    },
    location: {
        type: String,
        required: true,
        trim: true
    },
    status: {
        type: String,
        enum: ['NotContacted', 'Pending', 'Successful', 'Cancelled'],
        default: 'NotContacted'
    },
    createdBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    }
}, { timestamps: true });

// Compound Index for Filtering
outreachLeadSchema.index({ location: 1, type: 1, status: 1 });

// Text Index for Historical Search
outreachLeadSchema.index({ organizationName: 'text' });

module.exports = mongoose.model('OutreachLead', outreachLeadSchema);
