
const User = require('../Models/userModel');

// Create new user
exports.CreateUser = async (req, res) => {
  const { full_name, email, password, phone_number, user_role } = req.body;
  
  const user = await adminService.createUser({
    full_name,
    email,
    password,
    phone_number,
    user_role
  });

  res.status(201).json({
    msg: 'User created successfully. Welcome email sent.',
    user
  });
};

exports.FindUsers_byID = async (req,res) => {

try{

const { id } = req.params;

if (!id) return res.status(400).json({ msg: 'ID is required' });

const user = await User.findOne({ _id : id});
if (!user) return res.status(400).json({ msg: 'User Does not Exist' });

res.status(200).json({
 msg: 'User Exist',
user: {
    id: user._id,
    full_name: user.full_name,
    email: user.email,
    user_role: user.user_role
},

});

}catch(err){
    res.status(500).json({ msg: 'Sreach failed', error: err.message });

}
}

