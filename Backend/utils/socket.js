const { Server } = require("socket.io");

let io;

const initSocket = (httpServer) => {
    io = new Server(httpServer, {
        cors: {
            origin: "*",
            methods: ["GET", "POST", "PUT", "DELETE"],
        },
    });

    io.on("connection", (socket) => {
        console.log(`[Socket.IO] Client connected: ${socket.id}`);

        socket.on("join_group", (groupId) => {
            if (groupId) {
                const room = `group_${groupId}`;
                socket.join(room);
                console.log(`[Socket.IO] Client ${socket.id} joined ${room}`);
            }
        });

        socket.on("leave_group", (groupId) => {
            if (groupId) {
                const room = `group_${groupId}`;
                socket.leave(room);
                console.log(`[Socket.IO] Client ${socket.id} left ${room}`);
            }
        });

        socket.on("disconnect", (reason) => {
            console.log(`[Socket.IO] Client disconnected (${socket.id}): ${reason}`);
        });
    });

    return io;
};

const getIO = () => {
    if (!io) {
        throw new Error("Socket.IO has not been initialized!");
    }
    return io;
};

module.exports = {
    initSocket,
    getIO,
};
