

const mongoose = require('mongoose'); // Import the Mongoose library (ODM)

require('dotenv').config(); // Loads environment variables from .env file 
 

const connectDb = async () => { // we use Asynchronous function because we use iside it the wait
                                //  because we should wait untill the connection is done

try{

    const conn = await mongoose.connect(process.env.MONGO_URI,{
      useNewUrlParser: true,    // Tells Mongoose to use the new versions of reading (Parse) the connection string (URI)
      useUnifiedTopology: true,  // Tells Mongoose to use new topologies in connection

    })

    console.log('✅ MongoDB Connected');
      
  } catch (error) {
    console.error('Database connection failed:', error.message);
    process.exit(1);
  }
};




module.exports = connectDb;