import mongoose from "mongoose";
import User from "./userModel.js";

const milkEntrySchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    customerId: { type: mongoose.Schema.Types.ObjectId, ref: "Customer", required: true },
    customer_c_id: { type: Number, required: true },
    shift: { type: String, required: true },
    quantity: { type: Number, required: true },
    fat: { type: Number, required: true },
    a: { type: Number },
    b: { type: Number },
    rate: { type: Number },
    total_amount: { type: Number },
    snf: { type: Number, default: 8.5 },
    SNF_K: { type: Number, default: 0 },
    entryDate: { type: Date, default: Date.now }
  },
  { timestamps: true }
);

milkEntrySchema.pre("save", async function (next) {
  if (!this.a || !this.b) {
    const user = await User.findById(this.userId);
    this.a = user.a;
    this.b = user.b;
  }
  this.rate = this.fat * this.a + this.b;
  this.total_amount = this.quantity * this.rate;
});

const MilkEntry = mongoose.models.MilkEntry || mongoose.model("MilkEntry", milkEntrySchema);
export default MilkEntry;
