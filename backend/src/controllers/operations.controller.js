const CampEvent = require('../models/CampEvent');
const HelplineRequest = require('../models/HelplineRequest');
const Reimbursement = require('../models/Reimbursement');
const User = require('../models/User');

exports.getOperationsOverview = async (req, res) => {
    try {
        const { role, id: userId } = req.user;
        let overview = {};

        if (role === 'ADMIN') {
            const totalUsers = await User.countDocuments();
            const totalCamps = await CampEvent.countDocuments();
            const activeRequests = await HelplineRequest.countDocuments({ status: { $ne: 'Completed' } });
            const verificationPending = await User.countDocuments({ roleRequest: { $exists: true, $ne: null } });

            overview = {
                totalUsers,
                totalCamps,
                activeRequests,
                verificationPending
            };
        } else if (role === 'HR') {
            const totalVolunteers = await User.countDocuments({ role: 'VOLUNTEER' });
            const onlineVolunteers = await User.countDocuments({ role: 'VOLUNTEER', availabilityStatus: true });
            const newRoleRequests = await User.countDocuments({ roleRequest: { $exists: true, $ne: null } });
            const pendingInterview = await User.countDocuments({ role: 'VOLUNTEER', status: 'Pending' });

            overview = {
                totalVolunteers,
                onlineVolunteers,
                newRoleRequests,
                pendingInterview
            };
        } else if (role === 'MANAGER') {
            const assignedCamps = await CampEvent.countDocuments({ workflowStatus: { $ne: 'Closed' } });
            const workflowUrgent = await HelplineRequest.countDocuments({
                status: { $in: ['Pending', 'Assigned', 'InProgress'] },
                urgencyLevel: 'Critical'
            });
            const pendingReimbursements = await Reimbursement.aggregate([
                { $match: { status: 'Pending' } },
                { $group: { _id: null, total: { $sum: "$amount" } } }
            ]);
            const pendingPay = pendingReimbursements.length > 0 ? pendingReimbursements[0].total : 0;
            const openReports = await HelplineRequest.countDocuments({ status: 'Assigned' });

            overview = {
                assignedCamps,
                workflowUrgent,
                pendingPay,
                openReports
            };
        } else if (role === 'VOLUNTEER') {
            const myTasks = await HelplineRequest.countDocuments({ assignedVolunteer: userId, status: { $ne: 'Completed' } });
            const completedTasks = await HelplineRequest.countDocuments({ assignedVolunteer: userId, status: 'Completed' });
            const upcomingCamps = await CampEvent.countDocuments({ date: { $gte: new Date() } });
            const messages = 5; // Placeholder

            overview = {
                myTasks,
                completedTasks,
                upcomingCamps,
                messages
            };
        }

        res.status(200).json({
            success: true,
            overview
        });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

