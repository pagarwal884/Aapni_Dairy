import mongoose from "mongoose";

/* Counter Schema: increments c_id per user */
const counterSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true
  },
  value: {
    type: Number,
    default: 0
  }
});

const Counter =
  mongoose.models.Counter || mongoose.model("Counter", counterSchema);

const customerSchema = new mongoose.Schema({
  c_name: {
    type: String,
    required: true
  },

  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },

  c_id: {
    type: Number
  }
});

/* Auto-generate incremental c_id per user */
customerSchema.pre("save", async function () {
  if (this.c_id) return;

  if (!this.userId) {
    throw new Error("userId is required to generate customer c_id");
  }

  const counter = await Counter.findOneAndUpdate(
    { userId: this.userId },
    { $inc: { value: 1 } },
    { new: true, upsert: true, setDefaultsOnInsert: true }
  );

  this.c_id = counter.value;
});

const Customer =
  mongoose.models.Customer || mongoose.model("Customer", customerSchema);

export default Customer;
