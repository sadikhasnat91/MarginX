<div align="center">
  <h1>🚀 MarginX</h1>
  <p><strong>Profit Intelligence and Profit Leak Detection Platform for Bangladesh F-Commerce Sellers.</strong></p>
  
  > *"Sales দেখায় সবাই। MarginX দেখাবে—তোমার profit কোথায় হারাচ্ছে।"*
</div>

---

## 📖 About MarginX

MarginX helps online sellers understand their **REAL** profit after deducting all hidden expenses (product costs, courier charges, advertising, packaging, discounts, and return/RTO losses). It empowers sellers by pinpointing exactly where their hard-earned profit is leaking.

## ✨ Core Features

- **📊 Profit Analytics:** Real-time visualization of sales, expenses, and true net profit.
- **💧 Leak Detection:** Identify top money-draining areas (e.g., high RTO rates, ad spend vs revenue mismatch).
- **📦 Order & Product Management:** Track inventory, product costs, and order statuses seamlessly.
- **💸 Expense Tracking:** Log every minor expense (packaging, courier, overhead) accurately.
- **📑 Reports:** Export detailed financial reports in PDF and Excel formats.
- **🤖 AI Insights:** Smart recommendations to optimize profit margins (Upcoming).

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (v3.13+)
- **State Management & Routing:** [GetX](https://pub.dev/packages/get)
- **Backend & Auth:** [Supabase](https://supabase.com/) (PostgreSQL)
- **Data Visualization:** [fl_chart](https://pub.dev/packages/fl_chart)
- **Reporting:** `pdf`, `printing`, `excel`
- **Architecture:** Feature-based Clean Architecture

## 📁 Architecture Overview

```text
lib/
 ├── core/           # Constants, theme, routes, utils, errors, services
 ├── data/           # Data models, repositories, external datasources
 ├── features/       # Independent feature modules
 │   ├── auth/
 │   ├── dashboard/
 │   ├── expenses/
 │   ├── products/
 │   ├── profit_leaks/
 │   └── ...
 └── main.dart       # App entry point
```

## 🚀 Getting Started

Follow these steps to run the project locally on your machine.

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (^3.13.2)
- [Supabase](https://supabase.com/) project credentials
- Git

### Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/MarginX.git
   cd MarginX
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables:**
   Create a `.env` file at the root of the project (you can use `.env.example` as a template):
   ```env
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. **Run the Application:**
   ```bash
   flutter run
   ```



## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page if you want to contribute.

## 📝 License

This project is proprietary and not open for unauthorized distribution.

---
<div align="center">
  <b>Built for BD F-Commerce Entrepreneurs 🇧🇩</b>
</div>
