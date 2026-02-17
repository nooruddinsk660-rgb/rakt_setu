const OutreachLead = require('../models/OutreachLead');

// Create Lead
exports.createLead = async (req, res) => {
    try {
        const { organizationName, pocDetails, purpose, type, location } = req.body;

        const lead = new OutreachLead({
            organizationName,
            pocDetails,
            purpose,
            type,
            location,
            createdBy: req.user.id
        });

        await lead.save();

        res.status(201).json({
            success: true,
            lead
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Update Lead (Status/Details)
exports.updateLead = async (req, res) => {
    try {
        const { id } = req.params;
        const updates = req.body;

        // Prevent updating createdBy
        delete updates.createdBy;

        const lead = await OutreachLead.findByIdAndUpdate(id, updates, { new: true, runValidators: true });

        if (!lead) return res.status(404).json({ message: 'Lead not found' });

        res.status(200).json({
            success: true,
            lead
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get Leads with Filtering
exports.getLeads = async (req, res) => {
    try {
        const { type, location, status, startDate, endDate, search } = req.query;

        let query = {};

        // Compound Filters
        if (type) query.type = type;
        if (location) query.location = { $regex: location, $options: 'i' }; // Case-insensitive partial match
        if (status) query.status = status;

        // Date Range Filter
        if (startDate || endDate) {
            query.createdAt = {};
            if (startDate) query.createdAt.$gte = new Date(startDate);
            if (endDate) query.createdAt.$lte = new Date(endDate);
        }

        // Text Search (Optional override or addition)
        if (search) {
            query.$text = { $search: search };
        }

        const leads = await OutreachLead.find(query).sort({ createdAt: -1 });

        res.status(200).json({
            success: true,
            count: leads.length,
            leads
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get Historical Data for Organization
exports.getOrganizationHistory = async (req, res) => {
    try {
        const { orgName } = req.params;

        const history = await OutreachLead.find({
            organizationName: { $regex: new RegExp(`^${orgName}$`, 'i') }
        }).sort({ createdAt: -1 });

        res.status(200).json({
            success: true,
            count: history.length,
            history
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
