const cron = require('node-cron');
const CampEvent = require('../models/CampEvent');
const { createNotification } = require('../controllers/notification.controller');

const reminderJob = cron.schedule('0 9 * * *', async () => { // Run every day at 9 AM
    console.log('Running Follow-up Reminder Job...');
    try {
        const twoDaysAgo = new Date();
        twoDaysAgo.setDate(twoDaysAgo.getDate() - 2);

        // Find completed camps older than 2 days that are not Closed
        const pendingCamps = await CampEvent.find({
            workflowStatus: 'CampCompleted',
            eventDate: { $lte: twoDaysAgo }
        });

        for (const camp of pendingCamps) {
            // Update status to indicate follow-up is pending if not already
            // Actually, if it's 'CampCompleted' and old, we remind them to move to 'FollowupPending' or 'Closed'

            await createNotification(
                camp.createdBy,
                'Reminder',
                `Action Required: Camp "${camp.organizationName}" was completed 2 days ago. Please complete follow-up and close the event.`,
                camp._id
            );
            console.log(`Reminder sent for Camp: ${camp.organizationName}`);
        }
    } catch (error) {
        console.error('Reminder Job Failed:', error.message);
    }
});

module.exports = { reminderJob };
