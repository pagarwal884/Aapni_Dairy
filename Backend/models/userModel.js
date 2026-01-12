import mongoose from "mongoose";

const userSchema = new mongoose.Schema({
  o_name: { type: String, required: true },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  password: { type: String, required: true },
  Dairy_name: { type: String, required: true },
  Mobile_no: {
    type: String,
    required: true,
    unique: true,
    validate: {
      validator: function (v) {
        return /^[0-9]{10}$/.test(v);
      },
      message: "Mobile number must be exactly 10 digits"
    }
  },
  a: { type: Number, default: 8 },   // <-- store user's default a
  b: { type: Number, default: 2 }    // <-- store user's default b
});

const userModel = mongoose.models.User || mongoose.model("User", userSchema);
export default userModel;
