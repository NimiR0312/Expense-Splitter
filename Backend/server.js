require("dotenv").config();

const connectDB = require("./db/db_connection");
const express = require("express");
const http = require("http");
const cors = require("cors");
const { initSocket } = require("./utils/socket");

const groupRoutes = require("./routes/group_routes");
const expenseRoutes = require("./routes/expense_routes");

const app = express();
const server = http.createServer(app);

app.use(cors());
app.use(express.json());

app.use("/groups", groupRoutes);
app.use("/expenses", expenseRoutes);

app.get("/", (req, res) => {
    res.send("Expense Splitter Backend is running.");
});

// 404 Handler for unknown routes
app.use((req, res) => {
    res.status(404).json({
        success: false,
        message: `Route not found: ${req.method} ${req.originalUrl}`,
    });
});

// Centralized error handling middleware
app.use((err, req, res, next) => {
    console.error("Server Error:", err);
    res.status(err.status || 500).json({
        success: false,
        message: err.message || "Internal Server Error",
    });
});

// Initialize real-time Socket.IO
initSocket(server);

const PORT = process.env.PORT || 3000;

connectDB();

server.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});