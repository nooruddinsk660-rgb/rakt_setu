const User = require('../models/User');

// Request Role Upgrade
exports.requestRole = async (req, res) => {
    try {
        const { requestedRole } = req.body;
        const userId = req.user.id;

        const validRoles = ['MANAGER', 'HR', 'HELPLINE'];
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
