# 🍽️ sample_app1 - Flutter Restaurant Order App

A complete restaurant order management app built using **Flutter**, **SQLite**, and **Riverpod**. It enables waiters to take orders, manage table status, and persist data locally with SQLite.

---

## 🏗️ Architecture Overview

This app follows a simple **MVVM-style architecture** using:

### 📁 `models/`
- `MenuItem`: Represents individual food items
- `OrderItem`: Food items with quantity added to a table
- `TableOrder`: Represents each table’s orders and status

### 📁 `providers/`
- `tablesProvider`: Manages all table-related state (status, items)
- `themeProvider`: Switch between light/dark mode

### 📁 `db/`
- `DatabaseHelper`: SQLite logic for persisting orders and table statuses

### 📁 `screens/`
- `HomeScreen`: List of tables with their status
- `OrderScreen`: Add/remove items and request bills
- `OrdersViewScreen`: View completed orders

---

## 🧠 Assumptions

- The restaurant has **10 static tables**
- All menu items are hardcoded for simplicity
- Table statuses (`Free`, `Occupied`, `Requesting Bill`) are saved in SQLite
- A table becomes `Occupied` when items are added
- Orders are stored in SQLite when bill is requested
- The app works **offline** (no backend)
- Data remains even after app restart

---

## ✅ Features

- View table statuses (Free / Occupied / Requesting Bill)
- Add/remove items to/from a table
- Automatically change table status
- Request bill and persist orders
- View past orders
- Light/dark mode toggle
- SQLite persistence of all table statuses

---

## 🚀 Getting Started

1. **Clone the repo:**
   ```bash
   git clone https://github.com/your-username/sample_app1.git
   cd sample_app1
