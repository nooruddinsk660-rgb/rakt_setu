const User = require('../models/User');

// Request Role Upgrade
exports.requestRole = async (req, res) => {
    try {
        const { requestedRole } = req.body;
        const userId = req.user.id;

        const validRoles = ['MANAGER', 'HR', 'HELPLINE', 'HOSPITAL'];
        if (!validRoles.includes(requestedRole)) {
            return res.status(400).json({ message: 'Invalid role request' });
        }

        const user = await User.findById(userId);
        if (!user) return res.status(404).json({ message: 'User not found' });

        user.roleRequest = requestedRole;
        await user.save();

        res.status(200).json({
            success: true,
            message: `Request to become ${requestedRole} submitted successfully.`
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get Current User (for Splash Screen / Auth Check)
exports.getMe = async (req, res) => {
    try {
        const user = await User.findById(req.user.id).select('-password'); // Exclude password
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        res.status(200).json({
            success: true,
            user: user
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Update Profile
exports.updateProfile = async (req, res) => {
    try {
        const { name, city, phone, availabilityStatus } = req.body;
        const user = await User.findById(req.user.id);

        if (!user) return res.status(404).json({ message: 'User not found' });

        if (name) user.name = name;
        if (city) user.city = city;
        if (phone) user.phone = phone;
        if (availabilityStatus !== undefined) user.availabilityStatus = availabilityStatus;

        await user.save();

        res.status(200).json({
            success: true,
            message: 'Profile updated successfully',
            user: {
                id: user._id,
                name: user.name,
                email: user.email,
                role: user.role,
                city: user.city,
                phone: user.phone,
                availabilityStatus: user.availabilityStatus
            }
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get Pending Role Requests (Admin Only)
exports.getPendingRoleRequests = async (req, res) => {
    try {
        const users = await User.find({
            roleRequest: { $nin: ['NONE'] },
            role: { $ne: 'ADMIN' } // Admins shouldn't be requesting roles this way usually
        }).select('name email role roleRequest city phone createdAt');

        res.status(200).json({
            success: true,
            requests: users
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Action Role Request (Admin Only)
exports.actionRoleRequest = async (req, res) => {
    try {
        const { userId, status } = req.body; // status: 'APPROVED' or 'REJECTED'

        if (!['APPROVED', 'REJECTED'].includes(status)) {
            return res.status(400).json({ message: 'Invalid status. Use APPROVED or REJECTED.' });
        }

        const user = await User.findById(userId);
        if (!user) return res.status(404).json({ message: 'User not found' });

        if (user.roleRequest === 'NONE') {
            return res.status(400).json({ message: 'User has no pending role request.' });
        }

        if (status === 'APPROVED') {
            user.role = user.roleRequest; // Upgrade role
            user.roleRequest = 'NONE'; // Reset request
        } else {
            user.roleRequest = 'NONE'; // Just reset request
        }

        await user.save();

        res.status(200).json({
            success: true,
            message: `Role request ${status === 'APPROVED' ? 'approved' : 'rejected'}.`,
            user: {
                id: user._id,
                name: user.name,
                role: user.role
            }
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
