

const passport = require('passport'); //  gérer l’authentification dans l’application.


const GoogleStrategy = require('passport-google-oauth20').Strategy; //  On importe la stratégie Google OAuth 2.0 que Passport utilise pour se connecter via un compte Google.

const User = require('../Models/userModel'); // adjust your path

passport.use(new GoogleStrategy({
  clientID: process.env.GOOGLE_CLIENT_ID,
  clientSecret: process.env.GOOGLE_CLIENT_SECRET,
  callbackURL: '/api/auth/google/callback' //  Redirects the user to Google to log in. 
},

// Receives their profile info from Google:

async (accessToken, refreshToken, profile, done) => {
// profile : The Google profile info of the user

  try {

    const email = profile.emails[0].value;

    const googleUser = await User.findOne({ google_id: profile.id });
    if (googleUser) {
      return done(null, false, { message: 'Account already exists' });
    }

     const emailUser = await User.findOne({ email });
    if (emailUser) {
      return done(null, false, { message: 'Email already exists' });
    }

    
    
      const user = await User.create({
        googleId: profile.id,
        full_name: profile.displayName,
        email: profile.emails[0].value,
        password: 'GOOGLE_USER',          // dummy value
        phone_number: '0000000000',     // dummy value
        is_email_verified: true,
        google_access_token: accessToken,
        google_refresh_token: refreshToken || null,
        google_token_expiry: profile._json.exp ? new Date(profile._json.exp * 1000) : null,
        password_changed_at: null,
        email_verification_token: null,
        email_verification_expires: null,
        reset_code: null,
        reset_code_expires_at: null,
      });
    

    return done(null, user); // Logs them into my app
  } catch (err) {
    return done(err, null);
  }
}));
