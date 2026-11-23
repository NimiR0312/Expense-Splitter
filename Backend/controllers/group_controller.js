const mongoose = require("mongoose");
const Group = require("../models/group_model");
const generateUniqueGroupCode = require("../utils/generateGroupCode");
const { getIO } = require("../utils/socket");

//Create a new group

const createGroup = async (req, res) => {
    try {
        let { groupName, creatorName } = req.body;

        groupName = groupName?.trim();
        creatorName = creatorName?.trim();

        if (!groupName || !creatorName) {
            return res.status(400).json({
                success: false,
                message: "Group name and creator name are required",
            });
        }

        const groupCode = await generateUniqueGroupCode();

        const group = await Group.create({
            groupName,
            groupCode,
            members: [
                {
                    name: creatorName,
                    isAdmin: true,
                },
            ],
        });

        return res.status(201).json({
            success: true,
            message: "Group created successfully",
            data: group,
        });

    } catch (error) {
        console.error(error);

        return res.status(500).json({
            success: false,
            message: "Internal Server Error",
        });
    }
};

//Join an existing group

const joinGroup = async (req, res) => {
    try {
        let { groupCode, memberName } = req.body;

        groupCode = groupCode?.trim().toUpperCase();
        memberName = memberName?.trim();

        if (!groupCode || !memberName) {
            return res.status(400).json({
                success: false,
                message: "Group code and member name are required",
            });
        }

        const group = await Group.findOne({
            groupCode,
        });

        if (!group) {
            return res.status(404).json({
                success: false,
                message: "Group not found",
            });
        }

        const memberExists = group.members.some(
            (member) =>
                member.name.toLowerCase() ===
                memberName.toLowerCase()
        );

        if (memberExists) {
            return res.status(400).json({
                success: false,
                message: "Member already exists",
            });
        }

        group.members.push({
            name: memberName,
            isAdmin: false,
        });

        await group.save();

        // Real-time broadcast
        try {
            getIO().to(`group_${group._id}`).emit("member_joined", {
                groupId: group._id,
                group,
                newMember: memberName,
            });
        } catch (sockErr) {
            console.error("Socket emit error:", sockErr.message);
        }

        return res.status(200).json({
            success: true,
            message: "Joined group successfully",
            data: group,
        });

    } catch (error) {
        console.error(error);

        return res.status(500).json({
            success: false,
            message: "Internal Server Error",
        });
    }
};

// Get group by ID
const getGroupById = async (req, res) => {
    try {
        const { id } = req.params;

        if (!mongoose.Types.ObjectId.isValid(id)) {
            return res.status(400).json({
                success: false,
                message: "Invalid group id",
            });
        }

        const group = await Group.findById(id);

        if (!group) {
            return res.status(404).json({
                success: false,
                message: "Group not found",
            });
        }

        return res.status(200).json({
            success: true,
            data: group,
        });
    } catch (error) {
        console.error(error);
        return res.status(500).json({
            success: false,
            message: error.message || "Internal Server Error",
        });
    }
};

module.exports = {
    createGroup,
    joinGroup,
    getGroupById,
};