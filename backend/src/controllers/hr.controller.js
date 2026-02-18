const Schedule = require('../models/Schedule');
const CampEvent = require('../models/CampEvent');
const HelplineRequest = require('../models/HelplineRequest');
const User = require('../models/User');

// --- Schedule Management ---

// Get My Schedule
exports.getMySchedule = async (req, res) => {
    try {
        let schedule = await Schedule.findOne({ userId: req.user.id });
        if (!schedule) {
            schedule = new Schedule({ userId: req.user.id }); // Return draft if not exists
        }
        res.status(200).json({ success: true, schedule });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Update My Schedule
exports.updateMySchedule = async (req, res) => {
    try {
        const { availableDays, timeSlots } = req.body;

        let schedule = await Schedule.findOne({ userId: req.user.id });

        if (schedule && schedule.isLocked) {
            return res.status(403).json({ message: 'Schedule is locked by HR. Cannot edit.' });
        }

        if (!schedule) {
            schedule = new Schedule({ userId: req.user.id });
        }

        schedule.availableDays = availableDays;
        schedule.timeSlots = timeSlots;
        await schedule.save();

        res.status(200).json({ success: true, schedule });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Lock/Unlock Schedule (HR/Admin)
exports.toggleLock = async (req, res) => {
    try {
        const { userId } = req.params;
        const { isLocked } = req.body;

        let schedule = await Schedule.findOne({ userId });
        if (!schedule) {
            // Create empty schedule to lock if needed
            schedule = new Schedule({ userId });
        }

        schedule.isLocked = isLocked;
        await schedule.save();

        res.status(200).json({ success: true, message: `Schedule ${isLocked ? 'Locked' : 'Unlocked'}`, schedule });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Add Team Member (Admin/HR)
exports.addTeamMember = async (req, res) => {
    try {
        const { name, email, phone, role } = req.body;

        // Valid roles that can be added via this portal
        const allowedRoles = ['MANAGER', 'HR', 'HELPLINE', 'VOLUNTEER'];
        if (!allowedRoles.includes(role)) {
            return res.status(400).json({ message: 'Invalid role selection' });
        }

        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ message: 'User already exists' });
        }

        // Default password for manual creation (should be changed on first login)
        const defaultPassword = 'Password@123';

        const user = new User({
            name,
            email,
            password: defaultPassword,
            role,
            phone,
            city: 'Agartala', // Default city for now, or add to form
            isActive: true
        });

        await user.save();

        res.status(201).json({
            success: true,
            message: `User created as ${role}`,
            user: { id: user._id, name: user.name, role: user.role }
        });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get All Volunteers (For Assignment)
exports.getAllVolunteers = async (req, res) => {
    try {
        const volunteers = await User.find({ role: 'VOLUNTEER' })
            .select('_id name email city phone availabilityStatus')
            .lean();

        res.status(200).json({
            success: true,
            count: volunteers.length,
            volunteers
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// --- Dashboard & Stats ---

exports.getDashboardStats = async (req, res) => {
    try {
        // 1. Camps per Manager
        const campsPerManager = await CampEvent.aggregate([
            { $group: { _id: '$createdBy', count: { $sum: 1 } } },
            { $lookup: { from: 'users', localField: '_id', foreignField: '_id', as: 'manager' } },
            { $unwind: '$manager' },
            { $project: { managerName: '$manager.name', count: 1 } }
        ]);

        // 2. Count Stats
        const totalVolunteers = await User.countDocuments({ role: 'VOLUNTEER' });
        const totalCamps = await CampEvent.countDocuments();
        const totalHelplines = await HelplineRequest.countDocuments();

        res.status(200).json({
            success: true,
            stats: {
                totalVolunteers,
                totalCamps,
                totalHelplines,
                campsPerManager
            }
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// --- Burnout Detection ---

exports.getBurnoutRisk = async (req, res) => {
    try {
        // "High Load" Criteria:
        // 1. Active Helplines >= 5 (Status: Assigned or In_Progress) or...
        // 2. Camps in last 7 days >= 3

        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

        // Fetch Volunteers
        const volunteers = await User.find({ role: 'VOLUNTEER' }).select('_id name email');
        const highLoadVolunteers = [];

        for (const vol of volunteers) {
            // 1. Count Active Helplines
            const activeHelplines = await HelplineRequest.countDocuments({
                assignedVolunteer: vol._id,
                status: { $in: ['Assigned', 'In_Progress'] }
            });

            // 2. Count Recent Camps
            const recentCamps = await CampEvent.countDocuments({
                volunteers: vol._id,
                eventDate: { $gte: sevenDaysAgo }
            });

            if (activeHelplines >= 5 || recentCamps >= 3) {
                highLoadVolunteers.push({
                    volunteer: vol,
                    riskFactors: {
                        activeHelplines,
                        recentCamps
                    }
                });
            }
        }

        res.status(200).json({
            success: true,
            highLoadCount: highLoadVolunteers.length,
            highLoadVolunteers
        });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
