import validator from "validator";
import bcrypt from "bcrypt";
import userModel from "../models/userModel.js";
import jwt from "jsonwebtoken";

/* ================= LOGIN USER ================= */
const LoginUser = async (req, res) => {
    try {
        const { Mobile_no, password } = req.body;

        if (!Mobile_no || !password) {
            return res.status(400).json({
                success: false,
                message: "Mobile number and password are required"
            });
        }

        const user = await userModel.findOne({ Mobile_no: Mobile_no.trim() });

        if (!user) {
            return res.status(404).json({
                success: false,
                message: "User not found"
            });
        }

        const isMatch = await bcrypt.compare(password, user.password);

        if (!isMatch) {
            return res.status(401).json({
                success: false,
                message: "Invalid password"
            });
        }

        const token = jwt.sign(
            { id: user._id },
            process.env.JWT_SECRET,
            { expiresIn: "7d" }
        );

        res.json({ success: true, token });

    } catch (error) {
        console.error(error);
        res.status(500).json({
            success: false,
            message: "Server error"
        });
    }
};

/* ================= REGISTER USER ================= */
const RegisterUser = async (req, res) => {
    try {
        let { o_name, email, password, Dairy_name, Mobile_no, a, b } = req.body;

        if (!o_name || !email || !password || !Dairy_name || !Mobile_no) {
            return res.status(400).json({
                success: false,
                message: "All fields are required"
            });
        }

        a = Number(a);
        b = Number(b);
        a = isNaN(a) ? 8 : a;
        b = isNaN(b) ? 2 : b;

        const exists = await userModel.findOne({
            $or: [{ email: email.trim() }, { Mobile_no: Mobile_no.trim() }]
        });

        if (exists) {
            return res.status(409).json({
                success: false,
                message: "Email or mobile number already registered"
            });
        }

        if (!validator.isEmail(email)) {
            return res.status(400).json({
                success: false,
                message: "Invalid email address"
            });
        }

        if (!validator.isMobilePhone(Mobile_no, "en-IN")) {
            return res.status(400).json({
                success: false,
                message: "Invalid mobile number"
            });
        }

        if (password.length < 8) {
            return res.status(400).json({
                success: false,
                message: "Password must be at least 8 characters long"
            });
        }

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        const newUser = new userModel({
            o_name,
            email: email.trim(),
            password: hashedPassword,
            Dairy_name,
            Mobile_no: Mobile_no,
            a,
            b
        });

        const user = await newUser.save();

        const token = jwt.sign(
            { id: user._id },
            process.env.JWT_SECRET,
            { expiresIn: "7d" }
        );

        res.status(201).json({ success: true, token });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: error.message });
    }
};

const UpdateAB = async (req, res) => {
  try {
    const { a, b } = req.body;

    if (a == null || b == null) {
      return res.status(400).json({ success: false, message: "Both a and b are required" });
    }

    // userId is always from token
    const userId = req.user._id;

    const user = await userModel.findByIdAndUpdate(
      userId,
      { a: Number(a), b: Number(b) },
      { new: true }
    );

    if (!user) return res.status(404).json({ success: false, message: "User not found" });

    res.status(200).json({ success: true, a: user.a, b: user.b });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const userProfile = async (req, res) => {
  try {
    if (!req.user || !req.user._id) {
      return res.status(401).json({
        success: false,
        message: "Unauthorized"
      });
    }

    const user = await userModel.findById(
      req.user._id,
      "o_name Mobile_no Dairy_name"
    );

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found"
      });
    }

    res.json({
      success: true,
      profile: user
    });

  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message
    });
  }
};

const getAB = async (req, res) => {
  try {
    const user = await userModel.findById(req.user._id, "a b");

    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    res.json({ success: true, a: user.a, b: user.b });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};



export { LoginUser, RegisterUser, userProfile, UpdateAB, getAB };
