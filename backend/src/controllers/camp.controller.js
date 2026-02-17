const CampEvent = require('../models/CampEvent');
const { createNotification } = require('./notification.controller');


const WORKFLOW_STEPS = [
    'LeadReceived',
    'ContactingPOC',
    'BloodBankBooked',
    'VolunteersAssigned',
    'CampCompleted',
    'FollowupPending',
    'Closed'
];

// Create Camp
exports.createCamp = async (req, res) => {
    try {
        console.log('[DEBUG] createCamp called');
        console.log('[DEBUG] User:', req.user);
        console.log('[DEBUG] Body:', req.body);
        const { organizationName, poc, location, bloodBank, eventDate } = req.body;

        const camp = new CampEvent({
            organizationName,
            poc,
            location,
            bloodBank,
            eventDate,
            createdBy: req.user.id,
            workflowStatus: 'LeadReceived'
        });

        await camp.save();

        res.status(201).json({
            success: true,
            camp
        });
    } catch (error) {
        console.error('[DEBUG] Create Camp Error:', error);
        res.status(500).json({ message: error.message });
    }
};

// Update Status (Strict Workflow)
exports.updateStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;

        const camp = await CampEvent.findById(id);
        if (!camp) return res.status(404).json({ message: 'Camp not found' });

        // Authorization: Only Creator (or Admin)
        // Assuming Admin role check is done in middleware or here
        if (camp.createdBy.toString() !== req.user.id && req.user.role !== 'ADMIN') {
            return res.status(403).json({ message: 'Not authorized to update this camp' });
        }

        const currentIndex = WORKFLOW_STEPS.indexOf(camp.workflowStatus);
        const newIndex = WORKFLOW_STEPS.indexOf(status);

        if (newIndex === -1) return res.status(400).json({ message: 'Invalid status' });

        // Strict Step-wise: Only Allow Current + 1
        // Allow staying on same step? Yes.
        // Allow going back? No.
        if (newIndex !== currentIndex + 1 && newIndex !== currentIndex) {
            return res.status(400).json({
                message: `Invalid transition. Can only move from ${camp.workflowStatus} to ${WORKFLOW_STEPS[currentIndex + 1]}`
            });
        }

        camp.workflowStatus = status;
        await camp.save();

        // Notify Creator
        try {
            const { createNotification } = require('./notification.controller');
            await createNotification(
                camp.createdBy,
                'Workflow',
                `Camp "${camp.organizationName}" status updated to ${status}.`,
                camp._id
            );
        } catch (err) { console.error('Notification Error:', err.message); }

        res.status(200).json({
            success: true,
            message: `Camp workflow updated to ${status}`,
            camp
        });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Update Donation Count
exports.updateDonationCount = async (req, res) => {
    try {
        const { id } = req.params;
        const { count } = req.body;

        const camp = await CampEvent.findById(id);
        if (!camp) return res.status(404).json({ message: 'Camp not found' });

        // Only allow if Camp is Completed or later
        const completedIndex = WORKFLOW_STEPS.indexOf('CampCompleted');
        const currentIndex = WORKFLOW_STEPS.indexOf(camp.workflowStatus);

        if (currentIndex < completedIndex) {
            return res.status(400).json({ message: 'Cannot update donation count before CampCompleted status' });
        }

        camp.donationCount = count;
        await camp.save();

        res.status(200).json({ success: true, camp });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get Camps
exports.getCamps = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const skip = (page - 1) * limit;

        const camps = await CampEvent.find()
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit)
            .lean();

        const total = await CampEvent.countDocuments();

        res.status(200).json({
            success: true,
            count: camps.length,
            total,
            page,
            pages: Math.ceil(total / limit),
            camps
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
