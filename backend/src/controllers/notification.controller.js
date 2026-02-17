const Notification = require('../models/Notification');

// Get My Notifications
exports.getMyNotifications = async (req, res) => {
    try {
        const notifications = await Notification.find({ recipient: req.user.id })
            .sort({ createdAt: -1 })
            .limit(50); // Limit to last 50

        res.status(200).json({
            success: true,
            count: notifications.length,
            notifications
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Mark as Read
exports.markAsRead = async (req, res) => {
    try {
        const { id } = req.params;

        const notification = await Notification.findOneAndUpdate(
            { _id: id, recipient: req.user.id },
            { isRead: true },
            { new: true }
        );

        if (!notification) return res.status(404).json({ message: 'Notification not found' });

        res.status(200).json({ success: true, notification });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Internal Helper to Create Notification
exports.createNotification = async (recipient, type, message, relatedId) => {
    try {
        await Notification.create({ recipient, type, message, relatedId });
    } catch (error) {
        console.error('Notification Creation Failed:', error.message);
        // Don't crash the main flow if notification fails
    }
};
