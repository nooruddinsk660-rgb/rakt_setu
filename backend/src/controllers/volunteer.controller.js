const VolunteerProfile = require('../models/VolunteerProfile');
const ActivityLog = require('../models/ActivityLog');
const User = require('../models/User');
const mongoose = require('mongoose');

// Onboard Volunteer (Create Profile)
exports.onboardVolunteer = async (req, res) => {
    try {
        const { bloodGroup } = req.body;
        const userId = req.user.id;

        // Check if profile already exists
        let profile = await VolunteerProfile.findOne({ userId });
        if (profile) {
            return res.status(400).json({ message: 'Volunteer profile already exists' });
        }

        // Create new profile (Explicitly set fields to prevent mass assignment)
        profile = new VolunteerProfile({
            userId,
            bloodGroup,
            status: 'Active',
            // Initialize defaults
            availabilityStatus: true,
            totalEvents: 0,
            totalHelplines: 0,
            performanceScore: 0
        });

        await profile.save();

        res.status(201).json({
            success: true,
            message: 'Volunteer onboarded successfully',
            profile
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Update Availability/Status
exports.updateStatus = async (req, res) => {
    try {
        const { availabilityStatus, status } = req.body;
        const userId = req.user.id;

        const profile = await VolunteerProfile.findOne({ userId });
        if (!profile) {
            return res.status(404).json({ message: 'Volunteer profile not found' });
        }

        if (typeof availabilityStatus !== 'undefined') profile.availabilityStatus = availabilityStatus;
        if (status) profile.status = status;

        await profile.save();

        res.status(200).json({
            success: true,
            message: 'Status updated successfully',
            profile
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get Leaderboard (Sorted by Performance Score)
exports.getLeaderboard = async (req, res) => {
    try {
        const limit = parseInt(req.query.limit) || 10;

        const leaderboard = await VolunteerProfile.find({ status: 'Active' })
            .sort({ performanceScore: -1 })
            .limit(limit)
            .populate('userId', 'name email city'); // Populate User details

        res.status(200).json({
            success: true,
            count: leaderboard.length,
            leaderboard
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Log Activity (Admin/System Internal Use - for verifying score calculation)
// In a real app, this would be triggered by Event completion logic
exports.logActivity = async (req, res) => {
    try {
        const { volunteerId, activityType, description } = req.body;

        const profile = await VolunteerProfile.findById(volunteerId);
        if (!profile) {
            return res.status(404).json({ message: 'Volunteer profile not found' });
        }

        let points = 0;
        if (activityType === 'EVENT') {
            profile.totalEvents += 1;
            points = 3;
        } else if (activityType === 'HELPLINE') {
            profile.totalHelplines += 1;
            points = 5;
        }

        // Recalculate score
        await profile.calculateScore();

        // Create Log
        const log = new ActivityLog({
            volunteerId,
            activityType,
            referenceId: new mongoose.Types.ObjectId(), // Dummy ID for now
            pointsEarned: points,
            description
        });
        await log.save();

        res.status(200).json({
            success: true,
            message: 'Activity logged and score updated',
            newScore: profile.performanceScore,
            profile
        });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
