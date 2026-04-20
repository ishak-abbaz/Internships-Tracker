const express = require('express');

const connectDB = require('./Config/database');



require('dotenv').config();

const app = express();

const cors = require('cors');

const allowedOrigins = (process.env.CORS_ORIGINS || '')
  .split(',')
  .map((origin) => origin.trim())
  .filter(Boolean);

const corsOptions = {
  origin: (origin, callback) => {
    if (!origin) return callback(null, true);
    if (allowedOrigins.length === 0 || allowedOrigins.includes(origin)) {
      return callback(null, true);
    }
    return callback(new Error('Not allowed by CORS'));
  },
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: process.env.CORS_CREDENTIALS === 'true',
};



// Connect to database
connectDB();


// Middleware
app.use(cors(corsOptions));
app.options('(.*)', cors(corsOptions));



app.use(express.json());  // This middleware parses incoming JSON data from the request body and converts it into a JavaScript object.
// It is important When a client sends data we can access that data like:  req.body.name

app.use(express.urlencoded({ extended: true })); // This middleware parses incoming HTML data from the request body and converts it into a JavaScript object.

// Load cookie-parser BEFORE routes

const cookieParser = require('cookie-parser');
app.use(cookieParser()); // this Read cookies sent by Postman/browser on future requests



// Routes

app.get('/', (req, res) => { // homepage
  res.json({ message: 'API is running' });
});


// Auth Routes
const passport = require('passport');
app.use(passport.initialize());


const authRoutes = require('./Routes/authRoutes');
app.use('/api/v1/auth', authRoutes);


// Admin Routes :

const AdminRoutes = require('./Routes/adminRoutes');
app.use('/api/v1/admin', AdminRoutes);






// Mentor Routes :
const mentorRoutes = require('./Routes/mentorRoutes');
app.use('/api/v1/mentors', mentorRoutes);

// Evaluation Routes :
const evaluationRoutes = require('./Routes/evaluationRoutes');
app.use('/api/v1/evaluations', evaluationRoutes);

// Admin Department Routes :
const adminDepartementRoutes = require('./Routes/adminDepartementRoutes');
app.use('/api/v1/admin/departments', adminDepartementRoutes);

// Internships Routes :
const internshipRoutes = require('./Routes/internshipRoutes');
app.use('/api/v1/admin/internships', internshipRoutes);

// Admin office routes (policy + schedules uploads)
const adminOfficeRoutes = require('./Routes/AdminOfficeRoutes');
app.use('/api/v1/admin/office', adminOfficeRoutes);

// Intern routes (student self-service views)
const internRoutes = require('./Routes/internRoutes');
app.use('/api/v1/intern', internRoutes);

// Training Module Routes :
const trainingModuleRoutes = require('./Routes/trainingModuleRoutes');
app.use('/api/v1/mentors/training-modules', trainingModuleRoutes);

// Start Server

const PORT = process.env.PORT || 3000; // Uses .env value like PORT=5000 if it exists Otherwise defaults to 3000

app.listen(PORT, () => {  // Starts the server and listens for requests on the chosen port.
  console.log(`Server running on port ${PORT}`);
});


