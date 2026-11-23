const mongoose = require("mongoose");
const expenseService = require("../services/expense_service");
const { getIO } = require("../utils/socket");

// Create Expense
const createExpense = async (req, res) => {
    try {
        const {
            title,
            amount,
            paidBy,
            splitBetween,
            notes,
            groupId,
        } = req.body;

        if (
            !title ||
            amount == null ||
            !paidBy ||
            !groupId ||
            !Array.isArray(splitBetween) ||
            splitBetween.length === 0
        ) {
            return res.status(400).json({
                success: false,
                message: "Please provide all required fields.",
            });
        }

        if (!mongoose.Types.ObjectId.isValid(groupId)) {
            return res.status(400).json({
                success: false,
                message: "Invalid group id.",
            });
        }

        const expense = await expenseService.createExpense({
            title,
            amount,
            paidBy,
            splitBetween,
            notes,
            groupId,
        });

        // Real-time broadcast
        try {
            getIO().to(`group_${groupId}`).emit("expense_created", expense);
        } catch (sockErr) {
            console.error("Socket emit error:", sockErr.message);
        }

        return res.status(201).json({
            success: true,
            message: "Expense created successfully.",
            data: expense,
        });

    } catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message,
        });
    }
};

// Get all expenses of a group
const getExpensesByGroup = async (req, res) => {
    try {
        const { groupId } = req.params;

        if (!mongoose.Types.ObjectId.isValid(groupId)) {
            return res.status(400).json({
                success: false,
                message: "Invalid group id.",
            });
        }

        const expenses =
            await expenseService.getExpensesByGroup(groupId);

        return res.status(200).json({
            success: true,
            count: expenses.length,
            data: expenses,
        });

    } catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message,
        });
    }
};

// Get single expense
const getExpenseById = async (req, res) => {
    try {
        const { id } = req.params;

        if (!mongoose.Types.ObjectId.isValid(id)) {
            return res.status(400).json({
                success: false,
                message: "Invalid expense id.",
            });
        }

        const expense =
            await expenseService.getExpenseById(id);

        if (!expense) {
            return res.status(404).json({
                success: false,
                message: "Expense not found.",
            });
        }

        return res.status(200).json({
            success: true,
            data: expense,
        });

    } catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message,
        });
    }
};

// Update expense
const updateExpense = async (req, res) => {
    try {
        const { id } = req.params;

        if (!mongoose.Types.ObjectId.isValid(id)) {
            return res.status(400).json({
                success: false,
                message: "Invalid expense id.",
            });
        }

        const updatedExpense =
            await expenseService.updateExpense(
                id,
                req.body
            );

        if (!updatedExpense) {
            return res.status(404).json({
                success: false,
                message: "Expense not found.",
            });
        }

        // Real-time broadcast
        try {
            getIO().to(`group_${updatedExpense.groupId}`).emit("expense_updated", updatedExpense);
        } catch (sockErr) {
            console.error("Socket emit error:", sockErr.message);
        }

        return res.status(200).json({
            success: true,
            message: "Expense updated successfully.",
            data: updatedExpense,
        });

    } catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message,
        });
    }
};

// Delete expense
const deleteExpense = async (req, res) => {
    try {
        const { id } = req.params;

        if (!mongoose.Types.ObjectId.isValid(id)) {
            return res.status(400).json({
                success: false,
                message: "Invalid expense id.",
            });
        }

        const deletedExpense =
            await expenseService.deleteExpense(id);

        if (!deletedExpense) {
            return res.status(404).json({
                success: false,
                message: "Expense not found.",
            });
        }

        // Real-time broadcast
        try {
            getIO().to(`group_${deletedExpense.groupId}`).emit("expense_deleted", {
                expenseId: id,
                groupId: deletedExpense.groupId,
            });
        } catch (sockErr) {
            console.error("Socket emit error:", sockErr.message);
        }

        return res.status(200).json({
            success: true,
            message: "Expense deleted successfully.",
        });

    } catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message,
        });
    }
};

// Get Group Balances & Settlement Calculations
const getGroupBalances = async (req, res) => {
    try {
        const { groupId } = req.params;

        if (!mongoose.Types.ObjectId.isValid(groupId)) {
            return res.status(400).json({
                success: false,
                message: "Invalid group id.",
            });
        }

        const data = await expenseService.calculateGroupBalances(groupId);

        return res.status(200).json({
            success: true,
            data,
        });
    } catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message,
        });
    }
};

// Record Settlement
const settleExpense = async (req, res) => {
    try {
        const { groupId, from, to, amount, notes } = req.body;

        if (!groupId || !from || !to || amount == null) {
            return res.status(400).json({
                success: false,
                message: "Please provide groupId, from, to, and amount.",
            });
        }

        if (!mongoose.Types.ObjectId.isValid(groupId)) {
            return res.status(400).json({
                success: false,
                message: "Invalid group id.",
            });
        }

        if (Number(amount) <= 0) {
            return res.status(400).json({
                success: false,
                message: "Amount must be greater than 0.",
            });
        }

        if (from.trim().toLowerCase() === to.trim().toLowerCase()) {
            return res.status(400).json({
                success: false,
                message: "Payer and payee cannot be the same member.",
            });
        }

        const settlement = await expenseService.recordSettlement({
            groupId,
            from: from.trim(),
            to: to.trim(),
            amount: Number(amount),
            notes: notes ? notes.trim() : "",
        });

        // Real-time broadcast
        try {
            getIO().to(`group_${groupId}`).emit("settlement_recorded", settlement);
        } catch (sockErr) {
            console.error("Socket emit error:", sockErr.message);
        }

        return res.status(201).json({
            success: true,
            message: "Settlement recorded successfully.",
            data: settlement,
        });
    } catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message,
        });
    }
};

module.exports = {
    createExpense,
    getExpensesByGroup,
    getExpenseById,
    updateExpense,
    deleteExpense,
    getGroupBalances,
    settleExpense,
};