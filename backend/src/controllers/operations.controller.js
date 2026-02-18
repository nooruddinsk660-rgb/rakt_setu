const CampEvent = require('../models/CampEvent');
const HelplineRequest = require('../models/HelplineRequest');
const Reimbursement = require('../models/Reimbursement');
const User = require('../models/User');

exports.getOperationsOverview = async (req, res) => {
    try {
        // 1. Assigned Camps (Active)
        // For a generic Operations view, we might show ALL active camps.
        // For a Manager specific view, filter by createdBy or assignedTo (if we had assignment logic).
        // Let's assume generic Ops view for now -> All camps not closed.
        const assignedCampsCount = await CampEvent.countDocuments({
            workflowStatus: { $ne: 'Closed' }
        });

        // 2. Workflow Requests (Urgent / Pending)
        const pendingRequests = await HelplineRequest.countDocuments({
            status: { $in: ['Pending', 'Assigned'] },
            isUrgent: true // Assuming we have an urgent flag, or high priority
        });

        // 3. Pending Pay (Reimbursements)
        const pendingReimbursements = await Reimbursement.aggregate([
            { $match: { status: 'Pending' } },
            { $group: { _id: null, total: { $sum: "$amount" } } }
        ]);
        const pendingPayAmount = pendingReimbursements.length > 0 ? pendingReimbursements[0].total : 0;

        // 4. Low Inventory (Placeholder logic for now as we don't have Inventory model)
        const lowInventoryAlerts = 2; // Mocked

        res.status(200).json({
            success: true,
            overview: {
                assignedCamps: assignedCampsCount,
                workflowUrgent: pendingRequests,
                pendingPay: pendingPayAmount,
                lowInventory: lowInventoryAlerts
            }
        });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
