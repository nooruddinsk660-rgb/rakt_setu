const HelplineRequest = require('../models/HelplineRequest');
const VolunteerProfile = require('../models/VolunteerProfile');
const User = require('../models/User');

// Create Request & Smart Assignment
exports.createRequest = async (req, res) => {
    try {
        const { patientName, bloodGroup, unitsRequired, hospital, city, urgencyLevel } = req.body;

        // 1. Create Request Object
        const request = new HelplineRequest({
            patientName,
            bloodGroup,
            unitsRequired,
            hospital,
            city,
            urgencyLevel,
            requestedBy: req.user.id
        });

        // 2. Smart Assignment Logic
        // Find active volunteers in the same city
        const candidates = await VolunteerProfile.aggregate([
            {
                $lookup: {
                    from: 'users',
                    localField: 'userId',
                    foreignField: '_id',
                    as: 'userDetails'
                }
            },
            { $unwind: '$userDetails' },
            {
                $match: {
                    'userDetails.city': new RegExp(`^${city}$`, 'i'), // Case-insensitive
                    status: 'Active',
                    availabilityStatus: true
                }
            },
            {
                $lookup: {
                    from: 'helplinerequests',
                    let: { volunteerId: '$_id' },
                    pipeline: [
                        {
                            $match: {
                                $expr: {
                                    $and: [
                                        { $eq: ['$assignedVolunteer', '$$volunteerId'] },
                                        { $in: ['$status', ['Assigned', 'InProgress']] }
                                    ]
                                }
                            }
                        },
                        { $count: 'activeCount' }
                    ],
                    as: 'activeRequests'
                }
            },
            {
                $addFields: {
                    load: { $ifNull: [{ $arrayElemAt: ['$activeRequests.activeCount', 0] }, 0] }
                }
            },
            { $sort: { load: 1 } }, // Least loaded first
            { $limit: 1 }
        ]);

        let assignedVolunteerId = null;
        let status = 'Pending';

        if (candidates.length > 0) {
            assignedVolunteerId = candidates[0]._id;
            status = 'Assigned';
            request.assignedVolunteer = assignedVolunteerId;
            request.assignedAt = new Date();
        }

        request.status = status;
        await request.save();

        // Notify Volunteer
        if (status === 'Assigned') {
            try {
                const { createNotification } = require('./notification.controller');
                await createNotification(
                    assignedVolunteerId,
                    'Assignment',
                    `You have been assigned to: ${patientName} (${urgencyLevel})`,
                    request._id
                );
            } catch (err) { console.error('Notification Error:', err.message); }
        }

        res.status(201).json({
            success: true,
            message: status === 'Assigned' ? 'Request created and Volunteer assigned' : 'Request created, pending assignment',
            request,
            assignedTo: assignedVolunteerId ? candidates[0].userDetails.name : null
        });

    } catch (error) {
        console.error('Error in createRequest:', error);
        res.status(500).json({ message: error.message });
    }
};

// Update Status (Volunteer Interaction)
exports.updateStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { status, callRemark, assignedVolunteer } = req.body; // Extract callRemark and assignedVolunteer from body

        const request = await HelplineRequest.findById(id);
        if (!request) {
            return res.status(404).json({ message: 'Request not found' });
        }

        // HACKATHON RULE ENFORCEMENT: Compulsory remark before closing
        if (status === 'Completed') {
            if (!callRemark || callRemark.trim() === '') {
                return res.status(400).json({
                    success: false,
                    message: 'A remark/update is strictly required to close this call.'
                });
            }
            request.status = 'Completed';
            request.resolvedAt = new Date();
            request.callRemark = callRemark; // Save the remark
        }
        else if (status === 'InProgress' && request.status === 'Assigned') {
            request.status = 'InProgress';
            request.firstResponseAt = new Date();
        }
        else if (status === 'Cancelled') {
            request.status = 'Cancelled';
            if (callRemark) request.callRemark = callRemark; // Optional note for cancellation
        }
        else {
            request.status = status;
        }

        // Manual Assignment override
        if (assignedVolunteer) {
            request.assignedVolunteer = assignedVolunteer;
            if (status === 'Assigned') {
                request.assignedAt = new Date();
                // TODO: Send notification to new volunteer
            }
        }

        await request.save();

        res.status(200).json({
            success: true,
            message: 'Status updated',
            request
        });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
}

// Get Requests (Filters)
exports.getRequests = async (req, res) => {
    try {
        const { status, city } = req.query;
        const query = {};

        if (status) query.status = status;
        if (city) query.city = new RegExp(city, 'i');

        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const skip = (page - 1) * limit;

        const requests = await HelplineRequest.find(query)
            .populate('assignedVolunteer')
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit)
            .lean(); // Faster read

        const total = await HelplineRequest.countDocuments(query);

        res.status(200).json({
            success: true,
            count: requests.length,
            total,
            page,
            pages: Math.ceil(total / limit),
            requests
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
