const express = require('express');
const router = express.Router();
const volunteerController = require('../controllers/volunteer.controller');
const { authenticate, authorize } = require('../middlewares/auth.middleware');

// Public/Protected Routes
router.get('/leaderboard', authenticate, volunteerController.getLeaderboard);

// Volunteer Protected Routes
router.post('/onboard', authenticate, volunteerController.onboardVolunteer);
router.put('/status', authenticate, volunteerController.updateStatus);

// Admin Routes (For activity logging simulation)
router.post('/log-activity', authenticate, authorize(['ADMIN']), volunteerController.logActivity);

module.exports = router;
