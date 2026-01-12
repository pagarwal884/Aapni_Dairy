import MilkEntry from "../models/entryModel.js";
import Customer from "../models/customerModel.js";
import User from "../models/userModel.js";

/* CREATE ENTRY */
const entry = async (req, res) => {
  try {
    const customer_c_id = Number(req.params.customerId);
    if (isNaN(customer_c_id)) return res.status(400).json({ success: false, message: "Invalid customerId" });

    const { quantity, fat, shift, entryDate, snf, rate, total_amount, SNF_K } = req.body;
    if (!quantity || !fat || !shift)
      return res.status(400).json({ success: false, message: "quantity, fat, and shift are required" });

    const customer = await Customer.findOne({ userId: req.user._id, c_id: customer_c_id });
    if (!customer) return res.status(404).json({ success: false, message: "Customer not found" });

    const user = await User.findById(req.user._id);

    const rateCalc = rate !== undefined ? rate : (fat * user.a + user.b);
    const totalAmountCalc = total_amount !== undefined ? total_amount : (quantity * rateCalc);

    const entryDoc = await MilkEntry.create({
      userId: req.user._id,
      customerId: customer._id,
      customer_c_id: customer.c_id,
      shift,
      quantity,
      fat,
      snf: snf || 8.5,
      entryDate: entryDate ? new Date(entryDate) : new Date(),
      a: user.a,
      b: user.b,
      rate: rateCalc,
      total_amount: totalAmountCalc,
      SNF_K: SNF_K || 0.0
    });

    res.status(201).json({ success: true, message: "Milk entry created successfully", data: entryDoc });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

/* UPDATE ENTRY */
const updateEntry = async (req, res) => {
  try {
    const entryId = req.params.entryId;
    if (!entryId) return res.status(400).json({ success: false, message: "Entry ID is required" });

    const { quantity, fat, snf, entryDate, shift, rate, total_amount, SNF_K } = req.body;

    const entryDoc = await MilkEntry.findOne({
      _id: entryId,
      userId: req.user._id
    });

    if (!entryDoc) return res.status(404).json({ success: false, message: "Entry not found" });

    if (quantity !== undefined) entryDoc.quantity = quantity;
    if (fat !== undefined) entryDoc.fat = fat;
    if (snf !== undefined) entryDoc.snf = snf;
    if (entryDate !== undefined) entryDoc.entryDate = new Date(entryDate);
    if (shift !== undefined) entryDoc.shift = shift;
    if (SNF_K !== undefined) entryDoc.SNF_K = SNF_K;

    const user = await User.findById(req.user._id);
    entryDoc.rate = entryDoc.fat * user.a + user.b;
    entryDoc.a = user.a;
    entryDoc.b = user.b;
    entryDoc.total_amount = entryDoc.quantity * entryDoc.rate;

    await entryDoc.save();

    res.json({ success: true, message: "Entry updated successfully", data: entryDoc });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

/* LIST ENTRIES BY CUSTOMER ONLY */
const listEntriesByCustomerCIdOnly = async (req, res) => {
  try {
    const customer_c_id = Number(req.params.customer_c_id);
    if (isNaN(customer_c_id)) return res.status(400).json({ success: false, message: "Invalid customer_c_id" });

    const customer = await Customer.findOne({ userId: req.user._id, c_id: customer_c_id });
    if (!customer) return res.status(404).json({ success: false, message: "Customer not found" });

    const entries = await MilkEntry.find({ userId: req.user._id, customerId: customer._id }).sort({ entryDate: -1 });

    res.json({ success: true, count: entries.length, data: entries });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

/* NEW: LIST ENTRIES BY CUSTOMER + DATE */
const listEntriesByCustomerAndDate = async (req, res) => {
  try {
    const customer_c_id = Number(req.params.customer_c_id);
    const { entryDate } = req.query;

    if (isNaN(customer_c_id)) return res.status(400).json({ success: false, message: "Invalid customer_c_id" });
    if (!entryDate) return res.status(400).json({ success: false, message: "entryDate is required" });

    const customer = await Customer.findOne({ userId: req.user._id, c_id: customer_c_id });
    if (!customer) return res.status(404).json({ success: false, message: "Customer not found" });

    const start = new Date(entryDate);
    start.setHours(0, 0, 0, 0);
    const end = new Date(start.getTime() + 86400000);

    const entries = await MilkEntry.find({
      userId: req.user._id,
      customerId: customer._id,
      entryDate: { $gte: start, $lt: end }
    }).sort({ entryDate: -1 });

    res.json({ success: true, count: entries.length, data: entries });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

/* DELETE ENTRY */
const deleteEntryById = async (req, res) => {
  try {
    const deleted = await MilkEntry.findByIdAndDelete(req.params.id);
    if (!deleted) return res.status(404).json({ success: false, message: "Entry not found" });

    res.json({ success: true, message: "Entry deleted" });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

/* LIST ALL */
const listEntriesForUser = async (req, res) => {
  try {
    const entries = await MilkEntry.find({ userId: req.user._id })
      .populate({ path: "customerId", select: "c_name c_id" })
      .sort({ entryDate: -1 });

    res.json({
      success: true,
      count: entries.length,
      data: entries.map(e => ({
        _id: e._id,
        customerName: e.customerId?.c_name,
        customerCid: e.customerId?.c_id,
        quantity: e.quantity,
        fat: e.fat,
        snf: e.snf,
        shift: e.shift,
        entryDate: e.entryDate,
        rate: e.rate,
        total_amount: e.total_amount
      }))
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

/* SUMMARY: TOTAL COLLECTION IN DATE RANGE */
const getTotalSummary = async (req, res) => {
  try {
    const { start, end } = req.query;

    if (!start || !end) {
      return res
        .status(400)
        .json({ success: false, message: "start and end dates are required" });
    }

    const startDate = new Date(start);
    startDate.setHours(0, 0, 0, 0);

    const endDate = new Date(end);
    endDate.setHours(23, 59, 59, 999);

    // Aggregate entries by customer for this user
    const result = await MilkEntry.aggregate([
      {
        $match: {
          userId: req.user._id,
          entryDate: { $gte: startDate, $lte: endDate }
        }
      },
      {
        $group: {
          _id: "$customerId",
          totalQty: { $sum: "$quantity" },
          totalAmount: { $sum: "$total_amount" },
          totalSnf: { $sum: { $ifNull: ["$snf", 0] } }
        }
      },
      {
        $lookup: {
          from: "customers",
          localField: "_id",
          foreignField: "_id",
          as: "customer"
        }
      },
      { $unwind: "$customer" },
      {
        $project: {
          _id: 0,
          customerCid: "$customer.c_id",
          name: "$customer.c_name",
          totalQty: 1,
          totalAmount: 1,
          totalSnf: 1
        }
      }
    ]);

    // Calculate grand totals
    let grandQty = 0;
    let grandAmount = 0;
    let grandSnf = 0;

    result.forEach(r => {
      grandQty += r.totalQty;
      grandAmount += r.totalAmount;
      grandSnf += r.totalSnf;
    });

    const payable = grandAmount - grandSnf;

    res.json({
      success: true,
      range: { start, end },
      customers: result,
      grandTotals: {
        qty: grandQty,
        amount: grandAmount,
        snf: grandSnf,
        payable
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

/* SUMMARY: LIFETIME COLLECTION FOR ALL CUSTOMERS */
const getLifetimeSummary = async (req, res) => {
  try {
    let match = { userId: req.user._id };

    const { start, end } = req.query;

    if (start || end) {
      const startDate = start ? new Date(start) : new Date("1970-01-01");
      startDate.setHours(0, 0, 0, 0);

      const endDate = end ? new Date(end) : new Date();
      endDate.setHours(23, 59, 59, 999);

      match.entryDate = { $gte: startDate, $lte: endDate };
    }

    // Aggregate entries grouped by customer
    const result = await MilkEntry.aggregate([
      { $match: match },
      {
        $group: {
          _id: "$customerId",
          totalQty: { $sum: "$quantity" },
          totalAmount: { $sum: "$total_amount" },
          totalSnf: { $sum: { $ifNull: ["$snf", 0] } },
        }
      },
      {
        $lookup: {
          from: "customers",
          localField: "_id",
          foreignField: "_id",
          as: "customer"
        }
      },
      { $unwind: "$customer" },
      {
        $project: {
          _id: 0,
          customerCid: "$customer.c_id",
          name: "$customer.c_name",
          totalQty: 1,
          totalAmount: 1,
          totalSnf: 1
        }
      }
    ]);

    // Calculate grand totals
    let grandQty = 0;
    let grandAmount = 0;
    let grandSnf = 0;

    result.forEach(r => {
      grandQty += r.totalQty;
      grandAmount += r.totalAmount;
      grandSnf += r.totalSnf;
    });

    const payable = grandAmount - grandSnf;

    res.json({
      success: true,
      range: start || end ? { start: start || null, end: end || null } : null,
      customers: result,
      grandTotals: {
        qty: grandQty,
        amount: grandAmount,
        snf: grandSnf,
        payable
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export {
  entry,
  updateEntry,
  listEntriesByCustomerCIdOnly,
  listEntriesByCustomerAndDate,
  listEntriesForUser,
  deleteEntryById,
  getTotalSummary,
  getLifetimeSummary
};
