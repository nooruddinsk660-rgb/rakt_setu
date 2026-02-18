const express = require('express');
const router = express.Router();
const analyticsController = require('../controllers/analytics.controller');
const { authenticate, authorize } = require('../middlewares/auth.middleware');

// Protected Route (Admin/Manager/Helpline)
// Allowing HELPLINE and VOLUNTEER roles as they need dashboard access
router.get('/', authenticate, authorize(['ADMIN', 'HELPLINE', 'VOLUNTEER']), analyticsController.getAnalytics);

module.exports = router;
