const cron = require('node-cron');
const HelplineRequest = require('../models/HelplineRequest');

// Run every 10 minutes: '*/10 * * * *'
const escalationJob = cron.schedule('*/10 * * * *', async () => {
    console.log('Running Escalation Job...');
    try {
        const thirtyMinutesAgo = new Date(Date.now() - 30 * 60 * 1000);

        const escalationList = await HelplineRequest.find({
            status: 'Assigned',
            assignedAt: { $lt: thirtyMinutesAgo },
            firstResponseAt: null // No response yet
        });

        if (escalationList.length > 0) {
            console.log(`Found ${escalationList.length} requests to escalate.`);
            for (const req of escalationList) {
                req.status = 'Escalated';
                await req.save();
                // In real app: Notify Manager (Email/SMS)
                console.log(`[ESCALATION] Request ID: ${req._id} escalated to Manager.`);
            }
        } else {
            console.log('No requests to escalate.');
        }

    } catch (error) {
        console.error('Escalation Job Failed:', error.message);
    }
});

const triggerEscalationManual = async () => {
    console.log('Manual Escalation Triggered...');
    try {
        const thirtyMinutesAgo = new Date(Date.now() - 30 * 60 * 1000);

        const requests = await HelplineRequest.find({
            status: 'Assigned',
            assignedAt: { $lt: thirtyMinutesAgo },
            firstResponseAt: null
        });

        for (const req of requests) {
            req.status = 'Escalated';
            await req.save();
        }
        return requests.length;
    } catch (error) {
        throw error;
    }
};

module.exports = {
    escalationJob,
    triggerEscalationManual
};
