const Group = require("../models/group_model");

const generateUniqueGroupCode = async () => {
    const characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    while (true) {
        let code = "";

        for (let i = 0; i < 6; i++) {
            code += characters.charAt(
                Math.floor(Math.random() * characters.length)
            );
        }

        const existingGroup = await Group.findOne({
            groupCode: code,
        });

        if (!existingGroup) {
            return code;
        }
    }
};

module.exports = generateUniqueGroupCode;

