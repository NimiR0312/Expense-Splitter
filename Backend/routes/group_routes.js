const express = require("express");

const router = express.Router();

const {
    createGroup,
    joinGroup,
    getGroupById,
} = require("../controllers/group_controller");

router.post("/", createGroup);
router.post("/join", joinGroup);
router.get("/:id", getGroupById);

module.exports = router;