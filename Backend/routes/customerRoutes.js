import express from "express";
import {
  registerCustomer,
  listCustomer,
  updateCustomer,
  deleteCustomer
} from "../controllers/customerController.js";
import authMiddleware from "../middleware/authMiddleware.js";

const router = express.Router();

router.post("/register", authMiddleware, registerCustomer);
router.get("/list", authMiddleware, listCustomer);
router.put("/update/:_id", authMiddleware, updateCustomer);
router.delete("/remove/:_id", authMiddleware, deleteCustomer);

export default router;
