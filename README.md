# GameZone Manager

GameZone Manager is a modern Flutter application designed for gaming café and zone owners to efficiently manage PCs, consoles, customers, sessions, and billing.  
It features a clean, adaptive Material Design UI with a dark theme by default.

## Features

- **User Management**
  - Add, edit, and delete customer profiles
  - Track playtime and billing (hourly rates)
  - Membership plans (daily, weekly, monthly)

- **Machine/Console Management**
  - Add PCs/consoles with specifications
  - Mark as available, in-use, or under maintenance
  - Timer system for tracking play sessions

- **Billing & Payments**
  - Automatic billing based on session time
  - Prepaid and postpaid session options
  - Generate invoices/receipts

- **Admin Dashboard**
  - Overview of active users and machines
  - Daily/weekly/monthly revenue stats
  - Session history tracking

- **Modern UI**
  - Clean, dark Material Design
  - Simple navigation tabs: Dashboard, Customers, Machines, Billing, Settings
  - Adaptive layouts for all screen sizes

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Any Flutter-compatible IDE (VS Code, Android Studio, etc.)

### Installation

1. **Clone the repository:**
    ```sh
    git clone https://github.com/haxeeb71/gamezonemanager.git
    cd gamezonemanager
    ```

2. **Install dependencies:**
    ```sh
    flutter pub get
    ```

3. **Run the app:**
    ```sh
    flutter run
    ```

## Project Structure

```
lib/
├── main.dart
├── screens/
│   └── home_screen.dart
├── services/
│   └── database_service.dart
├── models/
│   └── (customer.dart, machine.dart, session.dart, etc.)
```

- **screens/**: UI screens and navigation
- **services/**: Database and business logic
- **models/**: Data models

## Contributing

Contributions are welcome! Please open issues and submit pull requests for new features, bug fixes, or improvements.

## License

This project is licensed under the MIT License.

---

**GameZone Manager** – The complete solution for gaming café management.
