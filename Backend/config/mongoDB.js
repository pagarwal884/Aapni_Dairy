import mongoose from "mongoose";

const connectDB = async () => {
  try {
    const uri = process.env.MONGODB_API;

    await mongoose.connect(`${uri}/Aani_dairy`);
    console.log("DB Connected");

  } catch (error) {
    console.error("Database connection failed:", error);
  }
};

export default connectDB;
