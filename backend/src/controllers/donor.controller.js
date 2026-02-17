const Donor = require('../models/Donor');
const DonorAccessLog = require('../models/DonorAccessLog');
const { encrypt, decrypt } = require('../utils/encryption.utils');

// Create Donor
exports.createDonor = async (req, res) => {
    try {
        const { name, bloodGroup, phone, city, lastDonationDate } = req.body;

        // Basic Validation
        if (!name || !bloodGroup || !phone || !city) {
            return res.status(400).json({ message: 'Missing required fields' });
        }

        // Encrypt Phone
        const encryptedPhone = encrypt(phone);

        const donor = new Donor({
            name,
            bloodGroup,
            phoneEncrypted: encryptedPhone,
            city,
            lastDonationDate: lastDonationDate ? new Date(lastDonationDate) : undefined,
            createdBy: req.user.id
        });

        await donor.save();

        res.status(201).json({
            success: true,
            message: 'Donor created successfully',
            donorId: donor._id
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Search Donors (Public/Protected - Returns Masked Info)
exports.searchDonors = async (req, res) => {
    try {
        const { bloodGroup, city } = req.query;
        const query = { availabilityStatus: true };

        if (bloodGroup) query.bloodGroup = bloodGroup;
        if (city) query.city = new RegExp(city, 'i'); // Case-insensitive search

        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const skip = (page - 1) * limit;

        // Exclude phoneEncrypted by default, or return it but we won't decrypt it here
        const donors = await Donor.find(query)
            .select('-phoneEncrypted')
            .skip(skip)
            .limit(limit)
            .lean();

        const total = await Donor.countDocuments(query);

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

        const donor = await Donor.findById(id);
        if (!donor) {
            return res.status(404).json({ message: 'Donor not found' });
        }

        // Decrypt Phone
        const decryptedPhone = decrypt(donor.phoneEncrypted);

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
                phone: decryptedPhone
            }
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
