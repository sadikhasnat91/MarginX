# MarginX

MarginX is a Profit Intelligence and Profit Leak Detection Platform for Bangladesh F-Commerce Sellers.

## 🚀 Core Product Promise
> “Sales দেখায় সবাই। MarginX দেখাবে—তোমার profit কোথায় হারাচ্ছে।”

Help an online seller understand their REAL profit after all expenses (product, courier, advertising, packaging, discounts, returns/RTOs) — then identify where their profit is leaking.

## 🛠️ Tech Stack
- **Framework:** Flutter
- **State Management:** GetX
- **Backend/Database:** Supabase (PostgreSQL)
- **Authentication:** Supabase Auth
- **Architecture:** Feature-based Clean Architecture

## 📁 Architecture
```text
lib/
 ├── core/
 │   ├── constants/
 │   ├── theme/
 │   ├── routes/
 │   ├── utils/
 │   ├── errors/
 │   └── services/
 ├── data/
 │   ├── models/
 │   ├── repositories/
 │   └── datasources/
 ├── features/
 │   ├── auth/
 │   ├── onboarding/
 │   ├── dashboard/
 │   ├── products/
 │   ├── orders/
 │   ├── expenses/
 │   ├── analytics/
 │   ├── profit_leaks/
 │   ├── ai_insights/
 │   ├── reports/
 │   ├── notifications/
 │   └── settings/
 └── main.dart
```

## 🔐 Environment Variables
Create a `.env` file at the root of the project with the following (see `.env.example`):
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

## ⚙️ Running Locally
1. Clone the repository.
2. Run `flutter pub get`
3. Set up your `.env` file.
4. Run `flutter run`
