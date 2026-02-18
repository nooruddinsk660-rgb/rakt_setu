const User = require('../models/User');
// const Donor = require('../models/Donor'); // Deprecated for online users
const DonorAccessLog = require('../models/DonorAccessLog');
const { encrypt, decrypt } = require('../utils/encryption.utils');

// Create Donor
// Create Donor -> Now handled via Auth Registration
exports.createDonor = async (req, res) => {
    res.status(400).json({
        message: 'Direct donor creation is deprecated. Please register a new user with blood group details.'
    });
};

// Search Donors (Public/Protected - Returns Masked Info)
exports.searchDonors = async (req, res) => {
    try {
        const { bloodGroup, city } = req.query;
        // Search in Users collection where bloodGroup is set and user is available
        const query = {
            bloodGroup: { $exists: true, $ne: null },
            availabilityStatus: true
        };

        if (bloodGroup) query.bloodGroup = bloodGroup;
        if (city) query.city = new RegExp(city, 'i'); // Case-insensitive search

        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const skip = (page - 1) * limit;

        const donors = await User.find(query)
            .select('name bloodGroup city nextEligibleDate') // Exclude contact info
            .skip(skip)
            .limit(limit)
            .lean();

        const total = await User.countDocuments(query);

        // Check eligibility
        const today = new Date();
        const formattedDonors = donors.map(d => ({
            _id: d._id,
            name: d.name,
            bloodGroup: d.bloodGroup,
            city: d.city,
            isEligible: !d.nextEligibleDate || d.nextEligibleDate <= today,
            nextEligibleDate: d.nextEligibleDate
        }));

        res.status(200).json({
            success: true,
            count: formattedDonors.length,
            total,
            page,
            pages: Math.ceil(total / limit),
            donors: formattedDonors
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get Donor Contact (Protected - Logs Access)
exports.getDonorContact = async (req, res) => {
    try {
        const { id } = req.params;
        const { purpose } = req.body;

        if (!purpose) {
            return res.status(400).json({ message: 'Purpose is required to access contact info' });
        }

        const donor = await User.findById(id);
        if (!donor) {
            return res.status(404).json({ message: 'Donor not found' });
        }

        // User phone is NOT encrypted in User model (assumed standard auth)
        // If it starts using encryption, we need to decrypt here.
        // Assuming plain text for User model as per current User.js
        const phone = donor.phone;

        // Log Access
        await DonorAccessLog.create({
            donorId: donor._id,
            accessedBy: req.user.id,
            purpose
        });

        res.status(200).json({
            success: true,
            contact: {
                name: donor.name,
                phone: phone
            }
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
