const mongoose = require('mongoose');

const reimbursementSchema = new mongoose.Schema({
    eventId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'CampEvent',
        required: true
    },
    volunteerId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User', // Linking to User (Volunteer)
        required: true
    },
    amount: {
        type: Number,
        required: [true, 'Amount is required'],
        min: [1, 'Amount must be positive']
    },
    receiptUrl: {
        type: String,
        required: [true, 'Receipt URL/Proof is required']
    },
    status: {
        type: String,
        enum: ['Pending', 'Approved', 'Rejected'],
        default: 'Pending'
    },
    reviewedBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    },
    reviewedAt: {
        type: Date
    },
    description: {
        type: String,
        trim: true
    }
}, { timestamps: true });

module.exports = mongoose.model('Reimbursement', reimbursementSchema);
