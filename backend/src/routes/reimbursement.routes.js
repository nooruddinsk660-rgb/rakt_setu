const express = require('express');
const router = express.Router();
const reimbursementController = require('../controllers/reimbursement.controller');
const { authenticate, authorize } = require('../middlewares/auth.middleware');

// Create Request (Volunteer)
router.post('/', authenticate, reimbursementController.createReimbursement);

// Get My Requests
router.get('/my', authenticate, reimbursementController.getMyReimbursements);

// Get Pending Requests (Admin/Manager only)
// Assuming we have 'MANAGER' or using 'ADMIN' for simplicity now. 
// Adding 'HELPLINE' temporarily or 'ADMIN' as allowed roles.
router.get('/pending', authenticate, authorize(['ADMIN', 'HELPLINE']), reimbursementController.getPendingReimbursements);

// Approve/Reject (Admin/Manager)
router.put('/:id/status', authenticate, authorize(['ADMIN', 'HELPLINE']), reimbursementController.updateStatus);

module.exports = router;
