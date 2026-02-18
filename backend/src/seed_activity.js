const mongoose = require('mongoose');
const dotenv = require('dotenv');
const HelplineRequest = require('./models/HelplineRequest');
const User = require('./models/User');

dotenv.config();

const seedActivity = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log('MongoDB Connected');

        // Create a dummy user if needed
        const volunteer = await User.findOne({ role: 'VOLUNTEER' });

        const requests = [
            {
                patientName: "Rahul Kumar",
                bloodGroup: "A+",
                hospital: "Apollo Hospital",
                city: "Delhi",
                unitsRequired: 2,
                urgencyLevel: "Urgent",
                status: "Pending",
                requestedBy: volunteer?._id,
                contactPhone: "9876543210"
            },
            {
                patientName: "Anita Singh",
                bloodGroup: "O-",
                hospital: "Max Hospital",
                city: "Mumbai",
                unitsRequired: 1,
                urgencyLevel: "Critical",
                status: "Assigned",
                requestedBy: volunteer?._id,
                assignedVolunteer: volunteer?._id,
                assignedAt: new Date(),
                contactPhone: "9876543211"
            },
            {
                patientName: "Suresh Gupta",
                bloodGroup: "B+",
                hospital: "Fortis",
                city: "Bangalore",
                unitsRequired: 3,
                urgencyLevel: "Normal",
                status: "Completed",
                requestedBy: volunteer?._id,
                assignedVolunteer: volunteer?._id,
                resolvedAt: new Date(),
                callRemark: "Done",
                contactPhone: "9876543212"
            }
        ];

        await HelplineRequest.insertMany(requests);
        console.log('Seeded 3 Helpline Requests');

        process.exit();
    } catch (error) {
        console.error(error);
        process.exit(1);
    }
};

seedActivity();
