


const express = require('express');

const connectDB = require('./Config/database');

require('./Config/passport');


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
app.use('/api/auth', authRoutes);


// Admin Routes :

const AdminRoutes = require('./Routes/adminRoutes');
app.use('/api/admin',AdminRoutes);






// Start Server

const PORT = process.env.PORT || 3000; // Uses .env value like PORT=5000 if it exists Otherwise defaults to 3000

app.listen(PORT, () => {  // Starts the server and listens for requests on the chosen port.
  console.log(`Server running on port ${PORT}`);
});


