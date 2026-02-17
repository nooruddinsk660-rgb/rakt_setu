const User = require('../models/User');
const HelplineRequest = require('../models/HelplineRequest');
const CampEvent = require('../models/CampEvent');

exports.getAnalytics = async (req, res) => {
    try {
        // 1. Total Volunteers
        const totalVolunteers = await User.countDocuments({ role: 'VOLUNTEER' });

        // 2. Active Helplines (Pending, Assigned, InProgress)
        const activeHelplines = await HelplineRequest.countDocuments({
            status: { $in: ['Pending', 'Assigned', 'InProgress'] }
        });

        // 3. Camps Per City
        const campsPerCity = await CampEvent.aggregate([
            { $group: { _id: "$location", count: { $sum: 1 } } },
            { $sort: { count: -1 } }
        ]);

        // 4. Avg Response Time (Time to First Response)
        // We look for requests that have a firstResponseAt
        const responseTimeStats = await HelplineRequest.aggregate([
            { $match: { firstResponseAt: { $exists: true, $ne: null } } },
            {
                $project: {
                    waitTimeMs: { $subtract: ["$firstResponseAt", "$createdAt"] }
                }
            },
            {
                $group: {
                    _id: null,
                    avgResponseTimeMs: { $avg: "$waitTimeMs" }
                }
            }
        ]);

        let avgResponseTime = 0;
        if (responseTimeStats.length > 0) {
            // Convert ms to hours or minutes for display flexibility, sending ms for now
            avgResponseTime = Math.round(responseTimeStats[0].avgResponseTimeMs / 1000 / 60); // minutes
        }

        // 5. Task Completion % (Completed vs Total)
        const totalRequests = await HelplineRequest.countDocuments();
        const completedRequests = await HelplineRequest.countDocuments({ status: 'Completed' });

        const taskCompletionRate = totalRequests > 0
            ? ((completedRequests / totalRequests) * 100).toFixed(2)
            : 0;

        res.status(200).json({
            success: true,
            analytics: {
                totalVolunteers,
                activeHelplines,
                campsPerCity,
                avgResponseTimeMinutes: avgResponseTime,
                taskCompletionRate: `${taskCompletionRate}%`,
                totalRequests,
                completedRequests
            }
        });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
