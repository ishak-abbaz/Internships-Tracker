const express = require('express');
const path = require('path');
const connectDB = require('./Config/database');
const app = express();

require('./Config/passport');
require('dotenv').config();

// Connect to database
connectDB();


// Middleware
app.use(express.json());  // This middleware parses incoming JSON data from the request body and converts it into a JavaScript object.
// It is important When a client sends data we can access that data like:  req.body.name
app.use(express.urlencoded({ extended: true })); // This middleware parses incoming HTML data from the request body and converts it into a JavaScript object.
app.use('/uploads', express.static(path.join(__dirname, '..', 'public', 'uploads')));

// Load cookie-parser BEFORE routes
const cookieParser = require('cookie-parser');
app.use(cookieParser()); // this Read cookies sent by Postman/browser on future requests

// Routes
app.get('/', (req, res) => { // homepage
  res.json({ message: 'API is running' });
});

const passport = require('passport');
app.use(passport.initialize());

// Auth Routes - Login
const loginRoutes = require('./Routes/loginRoutes');
app.use('/api/login', loginRoutes);

// Auth Routes - Register
const registerRoutes = require('./Routes/registerRoutes');
app.use('/api/register', registerRoutes);

// Admin Routes :
// const adminRoutes = require('./Routes/adminRoutes');
// app.use('/api/admin', adminRoutes);

// Start Server
const PORT = process.env.PORT || 3000; // Uses .env value like PORT=5000 if it exists Otherwise defaults to 3000

app.listen(PORT, () => {  // Starts the server and listens for requests on the chosen port.
  console.log(`Server running on port ${PORT}`);
});


