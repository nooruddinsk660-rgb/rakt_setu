const User = require('../models/User');
const { generateAccessToken, generateRefreshToken, verifyRefreshToken } = require('../utils/jwt.utils');

// Register User (For testing/seeding purposes)
exports.register = async (req, res) => {
    try {
        const { name, email, password, role, city, bloodGroup, phone } = req.body;

        // Allowed roles for self-registration: VOLUNTEER, DONOR, HELPLINE (Admin should be seeded)
        const allowedRoles = ['VOLUNTEER', 'DONOR', 'HELPLINE'];
        const userRole = allowedRoles.includes(role) ? role : 'VOLUNTEER';

        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ message: 'User already exists' });
        }

        const user = new User({
            name,
            email,
            password,
            role: userRole,
            city,
            bloodGroup,
            phone
        });
        await user.save();

        res.status(201).json({
            success: true,
            message: 'User registered successfully'
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Login User
exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;

        // Find user by email OR phone (assuming 'email' field in body sends the identifier)
        // We check if the input looks like an email, otherwise treat as phone
        const isEmail = email.includes('@');
        const query = isEmail ? { email: email.toLowerCase() } : { phone: email };

        const user = await User.findOne(query);
        if (!user) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        // Check account lock
        if (user.isLocked()) {
            return res.status(403).json({
                message: 'Account is locked. Try again later.',
                lockUntil: user.lockUntil
            });
        }

        // Check password
        const isMatch = await user.comparePassword(password);
        if (!isMatch) {
            await user.incrementLoginAttempts();
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        // Reset failed attempts on successful login
        await user.resetLoginAttempts();

        // Generate tokens
        const accessToken = generateAccessToken(user);
        const refreshToken = generateRefreshToken(user);

        res.status(200).json({
            success: true,
            accessToken,
            refreshToken,
            user: {
                id: user._id,
                name: user.name,
                email: user.email,
                role: user.role
            }
        });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Refresh Token
exports.refreshToken = async (req, res) => {
    try {
        const { refreshToken } = req.body;
        if (!refreshToken) {
            return res.status(401).json({ message: 'Refresh Token is required' });
        }

        const decoded = verifyRefreshToken(refreshToken);
        const user = await User.findById(decoded.id);

        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        const newAccessToken = generateAccessToken(user);

        res.status(200).json({
            success: true,
            accessToken: newAccessToken
        });

    } catch (error) {
        return res.status(403).json({ message: 'Invalid Refresh Token' });
    }
};
