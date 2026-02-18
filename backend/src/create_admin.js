const mongoose = require('mongoose');
const dotenv = require('dotenv');
const User = require('./models/User');

// Load env vars
dotenv.config();

const createAdmin = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected to MongoDB');

        const adminEmail = 'admin@raktsetu.com';
        const existingAdmin = await User.findOne({ email: adminEmail });

        if (existingAdmin) {
            console.log('Admin user already exists:', adminEmail);
            // Optionally update password or just exit
            // existingAdmin.password = 'Admin@123';
            // await existingAdmin.save();
        } else {
            const admin = new User({
                name: 'System Admin',
                email: adminEmail,
                password: 'Admin@123',
                role: 'ADMIN',
                phone: '0000000000',
                city: 'Headquarters',
                bloodGroup: 'O+', // Required by model now if strict, but let's see
                isActive: true
            });

            await admin.save();
            console.log('Admin user created successfully');
            console.log('Email:', adminEmail);
            console.log('Password: Admin@123');
        }

        process.exit(0);
    } catch (error) {
        console.error('Error creating admin:', error);
        process.exit(1);
    }
};

createAdmin();
