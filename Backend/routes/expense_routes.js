const express = require("express");

const router = express.Router();

const expenseController = require("../controllers/expense_controller");

// Create Expense
router.post("/", expenseController.createExpense);

// Record settlement
router.post("/settle", expenseController.settleExpense);

// Get balances & suggested settlements for a group
router.get("/balances/:groupId", expenseController.getGroupBalances);
router.get("/:groupId/balances", expenseController.getGroupBalances);

// Get single expense
router.get("/details/:id", expenseController.getExpenseById);

// Get all expenses of a group
router.get("/:groupId", expenseController.getExpensesByGroup);

// Update expense
router.put("/:id", expenseController.updateExpense);

// Delete expense
router.delete("/:id", expenseController.deleteExpense);

module.exports = router;