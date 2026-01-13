import mongoose from "mongoose";

/* =========================
   Counter Schema
========================= */
const counterSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    unique: true
  },
  value: {
    type: Number,
    default: 0
  }
});

const Counter =
  mongoose.models.Counter || mongoose.model("Counter", counterSchema);

/* =========================
   Customer Schema
========================= */
const customerSchema = new mongoose.Schema(
  {
    c_name: {
      type: String,
      required: true,
      trim: true
    },

    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },

    c_id: {
      type: Number,
      required: true
    }
  },
  { timestamps: true }
);

/* =========================
   Unique per-user customer ID
========================= */
customerSchema.index(
  { userId: 1, c_id: 1 },
  { unique: true }
);

/* =========================
   Auto-increment c_id per user
========================= */
customerSchema.pre("validate", async function (next) {
  if (this.c_id) return next();

  if (!this.userId) {
    return next(new Error("userId is required"));
  }

  // Ensure counter is synced with existing customers
  let counter = await Counter.findOne({ userId: this.userId });

  if (!counter) {
    const lastCustomer = await mongoose
      .model("Customer")
      .findOne({ userId: this.userId })
      .sort({ c_id: -1 });

    counter = await Counter.create({
      userId: this.userId,
      value: lastCustomer?.c_id || 0
    });
  }

  const updatedCounter = await Counter.findOneAndUpdate(
    { userId: this.userId },
    { $inc: { value: 1 } },
    { new: true }
  );

  this.c_id = updatedCounter.value;
  next();
});

const Customer =
  mongoose.models.Customer || mongoose.model("Customer", customerSchema);

export default Customer;
