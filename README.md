# MoneyTrace AI — Intelligent Financial Ledger & Expense Tracker

MoneyTrace AI is an enterprise-grade financial tracking platform featuring automated OCR receipt extraction, UPI transaction parsing, intelligent monthly budget tracking, multi-chart spending analytics, and behavioral insights powered by Google Gemini 3.6 Flash.

---

## 🏛️ Project Architecture

The project consists of a high-performance **Flutter** multiplatform client and a robust **Spring Boot** Java backend with Gemini AI integration:

```
├── flutter_app/           # Cross-Platform Flutter Client (Web, Android, iOS, Desktop)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/        # Category, Expense, PaymentMethod, ScannedReceipt, ScannedUPI
│   │   ├── providers/     # ExpenseProvider (State management, Budget & Auth)
│   │   ├── screens/       # Dashboard, Add Expense, Receipt Scan, UPI Scan, Analytics, Insights, Settings, Login
│   │   └── services/      # ApiService (REST integration with Spring Boot)
│   └── pubspec.yaml
│
└── backend/               # Spring Boot 3.3.4 (Java 17) REST API
    ├── pom.xml
    └── src/main/java/com/moneytrace/backend/
        ├── controller/    # ExpenseController, AiExtractionController
        ├── service/       # ExpenseService, GeminiAiService, ReceiptExtractionService
        └── model/         # Expense, Category, PaymentMethod
```

---

## ✨ Features

1. **🔐 Authentication & Guest Mode**:
   - Google Sign-In support.
   - One-click Interactive Demo Mode for instant testing without OAuth configuration.

2. **📊 Dynamic Dashboard & Target Budget Tracking**:
   - Monthly target budget tracking with real-time utilization progress bar.
   - Dynamic alert badges (`Over Budget`, `% Budget Left`).
   - Inline target budget editor.
   - All-time totals, monthly totals, and recent transaction log with category badges.

3. **🧾 Gemini Receipt OCR**:
   - Upload receipt photos or take photos directly with your camera.
   - Extracts merchant name, total amount, tax amount, and date with high precision.
   - Automatic category resolution mapping to system categories.

4. **📱 UPI Screenshot Parser**:
   - Upload GPay, PhonePe, or Paytm screenshots.
   - Auto-extracts receiver name, paid amount, transaction ID, date, and category.

5. **📈 Interactive Analytics & Multi-Chart Reports**:
   - **Distribution**: Interactive Pie Chart of category percentage share.
   - **Bar View**: Category-by-category comparative bar chart.
   - **Trends**: Historical monthly spending line chart.
   - Category breakdown cards with percentages and totals.

6. **💡 AI Spending Insights**:
   - Powered by **Google Gemini 3.6 Flash**.
   - Generates actionable financial advice and saving strategies customized to your ledger.

7. **⚙️ Settings & Dynamic Configuration**:
   - Live backend URL configuration.
   - Session management and architecture overview.

---

## 🚀 Getting Started

### 1. Start the Spring Boot Backend

```bash
cd backend
mvn spring-boot:run
```
Backend runs at: `http://localhost:8080` (H2 Console: `http://localhost:8080/h2-console`)

### 2. Start the Flutter App

```bash
cd flutter_app
flutter pub get
flutter run -d chrome
```
*(Or specify `-d edge`, `-d windows`, or an Android device/emulator)*
