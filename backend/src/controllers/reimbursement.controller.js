const Reimbursement = require('../models/Reimbursement');
const { createNotification } = require('./notification.controller');

const CampEvent = require('../models/CampEvent');

// Create Reimbursement Request
exports.createReimbursement = async (req, res) => {
    try {
        const { eventId, amount, receiptUrl, description } = req.body;

        // Verify Event Exists
        const event = await CampEvent.findById(eventId);
        if (!event) return res.status(404).json({ message: 'Event not found' });

        const reimbursement = new Reimbursement({
            eventId,
            volunteerId: req.user.id,
            amount,
            receiptUrl,
            description,
            status: 'Pending'
        });

        await reimbursement.save();

        res.status(201).json({
            success: true,
            reimbursement
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Approve/Reject (Manager/Admin)
exports.updateStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body; // Approved / Rejected

        if (!['Approved', 'Rejected'].includes(status)) {
            return res.status(400).json({ message: 'Invalid status' });
        }

        const reimbursement = await Reimbursement.findById(id);
        if (!reimbursement) return res.status(404).json({ message: 'Reimbursement not found' });

        reimbursement.status = status;
        reimbursement.reviewedBy = req.user.id;
        reimbursement.reviewedAt = new Date();

        await reimbursement.save();

        // Notify Volunteer
        try {
            const { createNotification } = require('./notification.controller');
            await createNotification(
                reimbursement.volunteerId,
                'Approval',
                `Your reimbursement for ₹${reimbursement.amount} was ${status}.`,
                reimbursement._id
            );
        } catch (err) { console.error('Notification Error:', err.message); }

        res.status(200).json({
            success: true,
            message: `Reimbursement ${status}`,
            reimbursement
        });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get My Reimbursements
exports.getMyReimbursements = async (req, res) => {
    try {
        const reimbursements = await Reimbursement.find({ volunteerId: req.user.id }).populate('eventId', 'organizationName');
        res.status(200).json({ success: true, reimbursements });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get Pending (For Managers)
exports.getPendingReimbursements = async (req, res) => {
    try {
        const reimbursements = await Reimbursement.find({ status: 'Pending' })
            .populate('volunteerId', 'name email')
            .populate('eventId', 'organizationName');
        res.status(200).json({ success: true, count: reimbursements.length, reimbursements });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
