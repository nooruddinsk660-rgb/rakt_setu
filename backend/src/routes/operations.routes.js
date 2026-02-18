const express = require('express');
const router = express.Router();
const operationsController = require('../controllers/operations.controller');
const { authenticate, authorize } = require('../middlewares/auth.middleware');

// Generic Operations Overview (Manager/Admin)
router.get('/overview', authenticate, authorize(['MANAGER', 'ADMIN', 'VOLUNTEER']), operationsController.getOperationsOverview);

module.exports = router;
