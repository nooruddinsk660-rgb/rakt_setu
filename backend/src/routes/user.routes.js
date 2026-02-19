const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const { authenticate, authorize } = require('../middlewares/auth.middleware');

// Request Role Upgrade
router.post('/request-role', authenticate, userController.requestRole);

// Get Current User
router.get('/me', authenticate, userController.getMe);

// Update Profile
router.put('/update-profile', authenticate, userController.updateProfile);

// Admin: Get Pending Requests
router.get('/role-requests', authenticate, authorize(['ADMIN']), userController.getPendingRoleRequests);

// Admin: Action Request
router.put('/role-requests', authenticate, authorize(['ADMIN']), userController.actionRoleRequest);

module.exports = router;

