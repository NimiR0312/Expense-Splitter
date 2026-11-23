# Expense Splitter 💸

A modern, real-time collaborative group expense splitting application built with **Flutter**, **Node.js**, **Express.js**, **MongoDB**, and **Socket.IO**.

Easily manage shared expenses with roommates, travel groups, friends, and teams. The app automatically calculates net balances and uses a greedy debt simplification algorithm to minimize the number of settlement transactions needed.

---

## ✨ Features

- **Collaborative Groups**: Create groups or join existing groups instantly via a unique 6-character group code.
- **Real-Time Data Synchronization**: Powered by **Socket.IO**. Any added, updated, or deleted expense or new group member syncs live across all connected devices without pulling to refresh.
- **Automated Settlement & Balance Engine**:
  - Automatically computes `totalPaid`, `totalOwed`, and net balances for each member.
  - **Greedy Debt Simplification Algorithm**: Direct settlement pathways (e.g. *"Bob pays Alice ₹250"*).
  - One-tap settlement modal to record debt payments.
- **Dual Modern Themes**:
  - **Default Light Theme**: Royal Navy Blue buttons (`#0F2042` / `#1E3A8A`) and crisp slate cards.
  - **Dark Theme**: Electric Turquoise / Cyan buttons (`#14B8A6` / `#2DD4BF`) and deep charcoal surfaces.
  - Persistent theme mode toggle in the navigation bar.
- **Local Persistence & Dashboard**:
  - Remembers user identity and auto-fills names.
  - **"My Groups" Hub**: Automatically remembers and sorts recently accessed groups on device with offline fallback cache.
- **Modular Architecture**: Clean separation of core themes, features (`expenses`, `groups`, `home`), services, controllers, and models.

---

## 🛠️ Tech Stack

### Frontend (Mobile & Cross-Platform)
- **Framework**: [Flutter](https://flutter.dev) (Dart)
- **Styling & Fonts**: Material 3, [Google Fonts](https://pub.dev/packages/google_fonts) (`Plus Jakarta Sans`)
- **Real-Time Client**: `socket_io_client`
- **Persistence**: `shared_preferences`
- **Networking**: `http`

### Backend (REST API & WebSockets)
- **Runtime**: [Node.js](https://nodejs.org) & [Express.js](https://expressjs.com)
- **Database**: [MongoDB Atlas](https://www.mongodb.com/atlas) with [Mongoose](https://mongoosejs.com) ODM
- **Real-Time Server**: [Socket.IO](https://socket.io) (WebSocket server with room-based group channels)
- **Configuration**: `dotenv`

---

## 📂 Project Structure

```
expense_splitter/
├── Backend/
│   ├── controllers/      # Route controllers (expenses, groups)
│   ├── db/               # MongoDB connection setup
│   ├── models/           # Mongoose schemas (Expense, Group)
│   ├── routes/           # Express REST endpoints
│   ├── services/         # Business logic & settlement algorithms
│   ├── utils/            # Group code generator & Socket.IO server
│   ├── server.js         # HTTP server entry point with WebSockets
│   └── package.json
│
├── Frontend/
│   ├── lib/
│   │   ├── core/         # Themes, AppConfig, SocketService, StorageService
│   │   ├── features/
│   │   │   ├── expenses/ # Models, services, screens (Add, List, Settlements)
│   │   │   ├── groups/   # Models, services, screens (Create, Join, Details)
│   │   │   └── home/     # "My Groups" Dashboard
│   │   └── main.dart     # App entry point with theme listener
│   └── pubspec.yaml
└── README.md
```

---

## 🚀 Getting Started

### 1. Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.12+ recommended)
- [Node.js](https://nodejs.org) (v18+)
- MongoDB Atlas cluster or local MongoDB instance

---

### 2. Backend Setup

1. Navigate to the `Backend` directory:
   ```bash
   cd Backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Configure environment variables in `Backend/.env`:
   ```env
   PORT=3000
   MONGODB_URI=your_mongodb_connection_string
   ```
   *(See `Backend/.env.example` for reference)*

4. Start the server:
   ```bash
   npm start
   # or with live reloading:
   npx nodemon server.js
   ```
   The backend will start on `http://localhost:3000` with Socket.IO enabled.

---

### 3. Frontend Setup

1. Navigate to the `Frontend` directory:
   ```bash
   cd Frontend
   ```

2. Install Flutter packages:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   # Android Emulator (automatically routes to 10.0.2.2:3000)
   flutter run

   # Physical Device / Custom Network IP:
   flutter run --dart-define=API_URL=http://<YOUR_LOCAL_IP>:3000
   ```

---

## 📄 License
This project is open source and available under the [ISC License](LICENSE).
