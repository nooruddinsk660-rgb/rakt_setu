const express = require('express');
const router = express.Router();
const donorController = require('../controllers/donor.controller');
const { authenticate, authorize } = require('../middlewares/auth.middleware');

// Create Donor (Protected)
router.post('/', authenticate, donorController.createDonor);

// Search Donors (Protected - Basic Info)
// Mapping root / to search as well since frontend uses it
router.get('/', authenticate, donorController.searchDonors);
router.get('/search', authenticate, donorController.searchDonors);

// Get Contact Info (High Security - Logs Access)
router.post('/:id/contact', authenticate, donorController.getDonorContact);

module.exports = router;
