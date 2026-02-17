const express = require('express');
const router = express.Router();
const campController = require('../controllers/camp.controller');
const { authenticate } = require('../middlewares/auth.middleware');

// Create Camp (Protected)
router.post('/', authenticate, campController.createCamp);

// List Camps
router.get('/', authenticate, campController.getCamps);

// Update Status (Protected, Creator only)
router.put('/:id/status', authenticate, campController.updateStatus);

// Update Donation Count (Protected)
router.put('/:id/stats', authenticate, campController.updateDonationCount);

module.exports = router;
