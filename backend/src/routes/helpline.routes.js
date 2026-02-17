const express = require('express');
const router = express.Router();
const helplineController = require('../controllers/helpline.controller');
const { authenticate } = require('../middlewares/auth.middleware');
const { triggerEscalationManual } = require('../jobs/escalation.job');

// Create Request (Protected)
router.post('/', authenticate, helplineController.createRequest);

// Update Status (Protected)
router.put('/:id/status', authenticate, helplineController.updateStatus);

// List Requests (Protected)
router.get('/', authenticate, helplineController.getRequests);

// Manual Trigger for Escalation (Protected - for verification)
router.post('/trigger-escalation', authenticate, async (req, res) => {
    try {
        const count = await triggerEscalationManual();
        res.json({ success: true, escalatedCount: count });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
