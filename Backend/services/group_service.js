const Group = require("../models/group_model");

// Create Group
const createGroup = async ({
    groupName,
    userName,
    groupCode,
}) => {
    const group = await Group.create({
        groupName,
        groupCode,
        members: [
            {
                name: userName,
                isAdmin: true,
            },
        ],
    });

    return group;
};

// Join Group
const joinGroup = async (
    groupCode,
    userName
) => {
    const group = await Group.findOne({
        groupCode,
    });

    if (!group) {
        throw new Error("Group not found.");
    }

    const memberExists = group.members.some(
        (member) =>
            member.name.trim().toLowerCase() ===
            userName.trim().toLowerCase()
    );

    if (memberExists) {
        throw new Error(
            "Member already exists."
        );
    }

    group.members.push({
        name: userName,
        isAdmin: false,
        joinedAt: new Date(),
    });

    await group.save();

    return group;
};

// Get Group By Code
const getGroupByCode = async (
    groupCode
) => {
    return await Group.findOne({
        groupCode,
    });
};

module.exports = {
    createGroup,
    joinGroup,
    getGroupByCode,
};