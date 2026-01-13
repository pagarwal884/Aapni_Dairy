import Customer from "../models/customerModel.js";

/* CREATE */
export const registerCustomer = async (req, res) => {
  try {
    const { c_name } = req.body;

    if (!c_name) {
      return res.status(400).json({
        success: false,
        message: "Customer name required"
      });
    }

    if (!req.user?._id) {
      return res.status(401).json({
        success: false,
        message: "Unauthorized"
      });
    }

    const customer = await Customer.create({
      c_name,
      userId: req.user._id
    });

    res.status(201).json({
      success: true,
      customer
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: err.message
    });
  }
};

/* LIST */
export const listCustomer = async (req, res) => {
  try {
    const customers = await Customer.find({
      userId: req.user._id
    }).sort({ c_id: 1 });

    res.json({
      success: true,
      customers
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message
    });
  }
};

/* UPDATE */
export const updateCustomer = async (req, res) => {
  try {
    const { _id } = req.params;
    const { c_name } = req.body;

    const customer = await Customer.findOneAndUpdate(
      { _id, userId: req.user._id },
      { c_name },
      { new: true }
    );

    if (!customer) {
      return res.status(404).json({
        success: false,
        message: "Customer not found"
      });
    }

    res.json({
      success: true,
      customer
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message
    });
  }
};

/* DELETE */
export const deleteCustomer = async (req, res) => {
  try {
    const { _id } = req.params;

    const deleted = await Customer.findOneAndDelete({
      _id,
      userId: req.user._id
    });

    if (!deleted) {
      return res.status(404).json({
        success: false,
        message: "Customer not found"
      });
    }

    res.json({
      success: true,
      message: "Customer removed"
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message
    });
  }
};
