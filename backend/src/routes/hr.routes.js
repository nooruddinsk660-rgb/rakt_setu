const express = require('express');
const router = express.Router();
const hrController = require('../controllers/hr.controller');
const { authenticate, authorize } = require('../middlewares/auth.middleware');

// --- Schedule Routes ---

// Volunteer manages own schedule
router.get('/schedule', authenticate, hrController.getMySchedule);
router.put('/schedule', authenticate, hrController.updateMySchedule);

// HR/Admin managing locks
// Assuming 'HELPLINE' role acts as Manager/HR here or just 'ADMIN'
const HR_ROLES = ['ADMIN', 'HELPLINE'];

router.put('/schedule-lock/:userId', authenticate, authorize(HR_ROLES), hrController.toggleLock);

// --- Dashboard & Stats ---

router.get('/dashboard', authenticate, authorize(HR_ROLES), hrController.getDashboardStats);
router.get('/burnout', authenticate, authorize(HR_ROLES), hrController.getBurnoutRisk);

module.exports = router;
