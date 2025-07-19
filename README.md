# AIFA - AI Financial Assistant

**Tagline**: _Finally, money management that doesn't suck._

AIFA is an AI-powered financial management application designed to make money management easy, personal, and engaging. With a friendly and non-judgmental approach, AIFA helps users take better control of their finances.

---

## 🎯 Problem Statement

### Problems We Solve:

- **Complex and boring financial apps** - most finance apps feel like complicated spreadsheets
- **Lack of personalization** - generic financial advice that doesn't fit individual situations
- **Difficulty in expense tracking** - complicated and time-consuming input processes
- **No empathetic guidance** - apps that judge users when they overspend
- **Lack of motivation for consistency** - no system that encourages good financial habits

### Target Users:

- **Millennials and Gen Z** who want to start managing their finances
- **Freelancers and workers** with irregular income
- **Students** learning to manage their allowances
- **Anyone** who feels overwhelmed by traditional finance apps

---

## 💡 Solution Overview

AIFA uses an **AI conversational interface** that allows users to interact with their finances naturally, like talking to a financially-savvy friend.

### Unique Approach:

- **Natural Language Processing** - inputs like "paid rent $1500" are instantly understood
- **Adaptive Learning** - AI learns from user habits to provide more personalized advice
- **Empathetic Guidance** - supportive tone, not judgmental
- **Gamification Elements** - motivational progress tracking
- **Conversational AI** - chat with AIFA to get insights and advice

---

## ✨ Key Features

### 🧩 **1. Smart Onboarding**

- Set up personal finances in 3 simple steps
- Personalization based on income range and goals
- Auto-generate budget starter plan

### � e**2. Intelligent Expense Tracking**

- **Natural language input**: "lunch $25 at local restaurant"
- **Auto-categorization** with machine learning
- **Smart suggestions** based on user patterns
- Support multiple currencies (USD, EUR, IDR, etc.)

### 🧠 **3. AI Chat Assistant**

Chat directly with AIFA for:

- "How much can I save this month?"
- "Help me reduce my food expenses"
- "Create a savings plan for vacation"
- Personal spending pattern analysis

### 📊 **4. Financial Dashboard**

- **Real-time balance** and cash flow
- **Visual charts** for category breakdown
- **Trend analysis** weekly/monthly
- **Smart insights**: "You saved 25% compared to last month's average"

### 📈 **5. Smart Budget Planner**

- **Auto-generated budget** (50/30/20 rule or custom)
- **Real-time tracking** vs budget
- **Gentle alerts** when approaching limits
- **Monthly review** with improvement suggestions

### 🎯 **6. Goal Saving Tracker**

- Set goals with deadlines (laptop, vacation, emergency fund)
- **Progress visualization** with motivational messages
- **Smart saving suggestions** based on income patterns
- **Milestone celebrations** to maintain motivation

### 📥 **7. Financial Reports & Analytics**

- **Monthly/weekly summaries** with insights
- **Export to PDF** for record keeping
- **Spending pattern analysis**: "Average transport per week: $90"
- **Savings rate tracking** and improvement suggestions

### 🔔 **8. Smart Notifications**

- **Gentle reminders** to input expenses
- **Non-judgmental budget alerts**
- **Bill due date** reminders
- **Motivational messages**: "Great job staying on track!"

### 🎨 **9. Personalized Experience**

- **Adaptive tone** based on user profile (student, freelancer, etc.)
- **Custom categories** suited to lifestyle
- **Flexible currency** support
- **Dark/light mode** preference

---

## 🛠️ Tech Stack

### **Frontend:**

- **Flutter** - Cross-platform mobile development
- **Riverpod** - State management
- **Go Router** - Navigation
- **FL Chart** - Data visualization

### **Backend:**

- **Supabase** - Database, Authentication, Real-time, Storage

### **AI Integration:**

- **Google Gemini API (Gemma)** - Natural language processing
- **LangChain.dart** - AI agent orchestration

---

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.7.2+)
- Dart SDK
- Supabase account

### 🔒 Security Setup (Required)

1. **Environment Configuration**:

   ```bash
   # Windows
   scripts\setup_env.bat

   # macOS/Linux
   chmod +x scripts/setup_env.sh
   ./scripts/setup_env.sh
   ```

2. **Configure Credentials**:
   - Edit `.env` file with your actual Supabase credentials
   - Never commit `.env` to version control
   - Use `.env.example` as a template for new team members

### 📱 Installation

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## 🏗️ Project Structure

```
lib/
├── app/                    # App configuration & routing
├── core/                   # Core utilities, models, providers
│   ├── config/            # Environment & app configuration
│   ├── models/            # Data models (Transaction, Budget, Goal)
│   ├── providers/         # State management (Riverpod)
│   ├── theme/             # App theming & styling
│   └── utils/             # Utilities & helpers
├── features/              # Feature modules
│   ├── auth/              # Authentication (login, signup)
│   ├── onboarding/        # User onboarding flow
│   ├── dashboard/         # Main financial dashboard
│   ├── transactions/      # Transaction management
│   ├── budget/            # Budget planning & tracking
│   ├── goals/             # Savings goal tracking
│   ├── reports/           # Financial reports & analytics
│   └── chat/              # AI chat assistant
└── main.dart              # App entry point
```

---

## 📚 Documentation

- [Product Requirements Document](docs/prd.md)

---

## 🛠️ Development

### **Setup Development Environment:**

```bash
# Get dependencies
flutter pub get

# Run security check
scripts\security_check.bat

# Run the app in debug mode
flutter run

# Run tests
flutter test

# Build for production
flutter build apk --release
```

### **Code Quality:**

```bash
# Analyze code
flutter analyze

# Format code
flutter format .

# Run integration tests
flutter test integration_test/
```

---

## 🤝 Contributing

We welcome contributions from the developer community!

### **How to Contribute:**

1. Fork this repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Follow security guidelines and coding standards
4. Write tests for new features
5. Submit pull request with clear description

### **Development Guidelines:**

- Follow Flutter best practices
- Write comprehensive tests
- Update documentation
- Follow security protocols
- Use conventional commit messages

---

## 🙏 Acknowledgments

- **Flutter Team** - for the amazing cross-platform framework
- **Supabase** - for the powerful backend-as-a-service
- **Google** - for Gemma that enables conversational AI
- **Open Source Community** - for the packages and tools used

---

**Made with ❤️ for better financial wellness**

_AIFA - Finally, money management that doesn't suck._
