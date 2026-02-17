const express = require('express');
const router = express.Router();
const outreachController = require('../controllers/outreach.controller');
const { authenticate } = require('../middlewares/auth.middleware');

// All routes are protected
router.use(authenticate);

// Create Lead
router.post('/', outreachController.createLead);

// Get Leads (Filtered)
router.get('/', outreachController.getLeads);

// Get History
router.get('/history/:orgName', outreachController.getOrganizationHistory);

// Update Lead
router.put('/:id', outreachController.updateLead);

// Explicit Status Route (Alias for update)
router.put('/:id/status', outreachController.updateLead);

module.exports = router;
