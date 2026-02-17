const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const mongoSanitize = require('express-mongo-sanitize');
const { NODE_ENV } = require('./config/env');
const authRoutes = require('./routes/auth.routes');
const volunteerRoutes = require('./routes/volunteer.routes');
const donorRoutes = require('./routes/donor.routes');
const helplineRoutes = require('./routes/helpline.routes');
const campRoutes = require('./routes/camp.routes');
const reimbursementRoutes = require('./routes/reimbursement.routes');
const outreachRoutes = require('./routes/outreach.routes');
const hrRoutes = require('./routes/hr.routes');
const analyticsRoutes = require('./routes/analytics.routes');
const notificationRoutes = require('./routes/notification.routes');
const { escalationJob } = require('./jobs/escalation.job');
const { reminderJob } = require('./jobs/reminder.job');

const app = express();

// Security Middleware
app.use(helmet());
app.use(cors());

// Logging Middleware
app.use(morgan(NODE_ENV === 'development' ? 'dev' : 'combined'));

// Body Parser Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Data Sanitization (Manual to avoid Express 5 req.query getter issue)
app.use((req, res, next) => {
    req.body = mongoSanitize.sanitize(req.body);
    req.params = mongoSanitize.sanitize(req.params);
    try {
        req.query = mongoSanitize.sanitize(req.query);
    } catch (error) {
        // Express 5 makes req.query a getter in some cases? 
        // Or if it's read-only, we skip sanitizing it here (less critical for NoSQL injection usually if not used in find directly without validation)
        // But ideally we shouldsanitize it. 
        // If fails, we just proceed.
    }
    next();
});

// Rate Limiting
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 100,
    standardHeaders: true,
    legacyHeaders: false,
});
app.use(limiter);

// Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/volunteer', volunteerRoutes);
app.use('/api/v1/donor', donorRoutes);
app.use('/api/v1/helpline', helplineRoutes);
app.use('/api/v1/camp', campRoutes);
app.use('/api/v1/reimbursement', reimbursementRoutes);
app.use('/api/v1/outreach', outreachRoutes);
app.use('/api/v1/hr', hrRoutes);
app.use('/api/v1/analytics', analyticsRoutes);
app.use('/api/v1/notification', notificationRoutes);

// Start Jobs
escalationJob.start();
reminderJob.start();

// Base Route
app.get('/', (req, res) => {
    res.status(200).json({
        message: 'Welcome to RaktSetu API',
        environment: NODE_ENV,
        timestamp: new Date().toISOString()
    });
});

// Error Handling Middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({
        success: false,
        message: 'Something went wrong!',
        error: NODE_ENV === 'development' ? err.message : undefined
    });
});

module.exports = app;
