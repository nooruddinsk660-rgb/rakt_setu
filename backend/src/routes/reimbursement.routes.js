const express = require('express');
const router = express.Router();
const reimbursementController = require('../controllers/reimbursement.controller');
const { authenticate, authorize } = require('../middlewares/auth.middleware');

// Create Request (Volunteer)
router.post('/', authenticate, reimbursementController.createReimbursement);

// Get My Requests
router.get('/my', authenticate, reimbursementController.getMyReimbursements);

// Get Pending Requests (Admin/Manager/HR authorized)
router.get('/pending', authenticate, authorize(['ADMIN', 'MANAGER', 'HR']), reimbursementController.getPendingReimbursements);

// Approve/Reject (Admin/Manager/HR authorized)
router.put('/:id/status', authenticate, authorize(['ADMIN', 'MANAGER', 'HR']), reimbursementController.updateStatus);


module.exports = router;
