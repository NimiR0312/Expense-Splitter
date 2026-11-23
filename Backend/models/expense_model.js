const mongoose = require("mongoose");

const expenseSchema = new mongoose.Schema({
    title: {
        type: String,
        required: true,
        trim: true,
    },

    amount: {
        type: Number,
        required: true,
        min: 0,
    },

    paidBy: {
        type: String,
        required: true,
    },

    splitBetween: [
        {
            type: String,
            required: true,
        },
    ],

    notes: {
        type: String,
        default: "",
    },

    groupId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Group",
        required: true,
    },

    isSettlement: {
        type: Boolean,
        default: false,
    },

    createdAt: {
        type: Date,
        default: Date.now,
    },
});

module.exports = mongoose.model(
    "Expense",
    expenseSchema
);