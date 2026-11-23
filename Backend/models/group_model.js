const mongoose = require("mongoose");

const memberSchema = new mongoose.Schema(
    {
        name: {
            type: String,
            required: true,
            trim: true,
        },

        isAdmin: {
            type: Boolean,
            default: false,
        },

        joinedAt: {
            type: Date,
            default: Date.now,
        },
    },
    {
        _id: false,
    }
);

const groupSchema = new mongoose.Schema(
    {
        groupName: {
            type: String,
            required: true,
            trim: true,
        },

        groupCode: {
            type: String,
            required: true,
            unique: true,
            uppercase: true,
            trim: true,
        },

        members: {
            type: [memberSchema],
            default: [],
        },
    },
    {
        timestamps: true,
    }
);

module.exports = mongoose.model("Group", groupSchema);