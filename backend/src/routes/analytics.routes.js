const express = require('express');
const router = express.Router();
const analyticsController = require('../controllers/analytics.controller');
const { authenticate, authorize } = require('../middlewares/auth.middleware');

// Protected Route (Admin/Manager/Helpline)
// Allowing HELPLINE role as they might need dashboard too
router.get('/', authenticate, authorize(['ADMIN', 'HELPLINE']), analyticsController.getAnalytics);

module.exports = router;
