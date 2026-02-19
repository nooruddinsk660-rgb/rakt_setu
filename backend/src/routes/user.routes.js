const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const { authenticate } = require('../middlewares/auth.middleware');

// Request Role Upgrade
router.post('/request-role', authenticate, userController.requestRole);

// Get Current User
router.get('/me', authenticate, userController.getMe);

module.exports = router;
