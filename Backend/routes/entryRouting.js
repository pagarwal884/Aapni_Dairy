import express from "express";
import authMiddleware from "../middleware/authMiddleware.js";
import {
  entry,
  updateEntry,
  listEntriesForUser,
  deleteEntryById,
  listEntriesByCustomerCIdOnly,
  listEntriesByCustomerAndDate,
  getTotalSummary,
  getLifetimeSummary
} from "../controllers/entryController.js";

const entryRoute = express.Router();

entryRoute.post("/milk-entry/:customerId", authMiddleware, entry);

entryRoute.put("/update-entry/:entryId", authMiddleware, updateEntry);

entryRoute.get(
  "/milk-entries/customer/:customer_c_id/all",
  authMiddleware,
  listEntriesByCustomerCIdOnly
);

// NEW: get by date + customer
entryRoute.get(
  "/customer/:customer_c_id/by-date",
  authMiddleware,
  listEntriesByCustomerAndDate
);

entryRoute.get("/all", authMiddleware, listEntriesForUser);

// delete by _id
entryRoute.delete("/:id", authMiddleware, deleteEntryById);

entryRoute.get("/summary/total", authMiddleware, getTotalSummary);
entryRoute.get("/entry/summary/lifetime", authMiddleware, getLifetimeSummary);


export default entryRoute;
