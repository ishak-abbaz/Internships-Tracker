const express = require('express');

const connectDB = require('./Config/database');



require('dotenv').config();

const app = express();



// Connect to database
connectDB();


// Middleware
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
app.use('/api/v1/mentors/internships', internshipRoutes);

// Training Module Routes :
const trainingModuleRoutes = require('./Routes/trainingModuleRoutes');
app.use('/api/v1/mentors/training-modules', trainingModuleRoutes);

// Start Server

const PORT = process.env.PORT || 3000; // Uses .env value like PORT=5000 if it exists Otherwise defaults to 3000

app.listen(PORT, () => {  // Starts the server and listens for requests on the chosen port.
  console.log(`Server running on port ${PORT}`);
});


