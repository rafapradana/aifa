# 📘 Product Requirements Document

## App Name: **AIFA**

**Tagline**: *Finally, money management that doesn't suck.*

---

## 🧩 1. Onboarding & Personal Setup

### Goal:

To gather basic financial context and personalize AIFA from the start.

### Requirements:

* Warm welcome with short intro to AIFA’s capabilities
* Quick questions:

  * Monthly income range
  * Main financial goal (optional)
  * Usual spending categories
* Output:

  * Personalized budget starter plan
  * AIFA’s tone and guidance adapted to user profile (student, freelancer, etc.)

---

## 💸 2. Expense & Income Logging

### Goal:

Allow users to effortlessly track their financial activity.

### Requirements:

* Manual entry for:

  * Amount
  * Type (Income / Expense)
  * Category
  * Date
  * Description (optional)
* Smart Input:

  * Accepts natural language like “paid rent 1.5 million”
  * Instant parsing and categorization

---

## 🧠 3. Auto-Categorization

### Goal:

Make transaction entry feel intelligent and easy.

### Requirements:

* Predicts category based on:

  * Description/keywords
  * Vendor name
  * Amount range
  * User’s past tagging behavior
* Suggests category automatically with confirmation option
* Learns over time (adaptive intelligence)
* Allows manual override and correction
* Applies to both individual entries and batch-imported data

---

## 📊 4. Financial Dashboard

### Goal:

Provide a clear, digestible summary of user’s financial status.

### Requirements:

* Current balance
* Total monthly income & expenses
* Pie/bar charts for category breakdown
* Trend graph over time (weekly/monthly)
* Highlights:

  * “Most spent category this month”
  * “You’re spending 25% below your average”
  * “3 days left in your weekly budget”

---

## 💬 5. AI Chat Assistant – *Talk to AIFA*

### Goal:

Give users direct access to personalized financial guidance.

### Requirements:

* Conversational AI interface
* Accepts natural questions like:

  * “How much can I save this month?”
  * “Help me cut down on food spending”
  * “Create a saving plan for a trip”
* Responds empathetically, intelligently, and clearly
* Offers:

  * Suggestions
  * Feedback
  * Budget adjustments
  * Planning support

---

## 📈 6. Budget Planner

### Goal:

Empower users to allocate their income with clarity and control.

### Requirements:

* Auto-generated plan (e.g. 50/30/20 rule)
* Users can adjust per category
* Real-time tracking vs. budget
* Alerts or gentle reminders when over budget
* Monthly review prompt: “Want to refine your budget for next month?”

---

## 🎯 7. Goal Saving Tracker

### Goal:

Help users save for specific dreams and commitments.

### Requirements:

* Users define:

  * Goal title (e.g. “Laptop”)
  * Amount needed
  * Deadline (optional)
* Neira suggests:

  * Weekly/monthly saving target
  * Adjustment based on income
* Progress bar & motivational messages:

  > “You're 65% there. Amazing progress!”

---

## 📥 8. Financial Reports & History

### Goal:

Let users explore, filter, and learn from their past financial data.

### Requirements:

* Monthly & weekly summaries
* Filter by category, date range, or keywords
* Export to PDF (summary or detailed)
* Insightful highlights:

  * “Your average weekly spending on Transport is 90k”
  * “Your savings rate increased by 12%”

---

## 🔔 9. Notifications & Reminders

### Goal:

Keep users gently informed and engaged.

### Requirements:

* Optional daily/weekly check-in reminders
* Budget nearing alert
* Bill due dates (if user inputs them)
* Encouraging messages (not judgmental):

  * “Want to log today’s expenses?”
  * “You’re staying on track. Great job!”

---

## 🧬 10. Personality & Tone of Voice

### Goal:

Establish AIFA as more than a tool — a trustworthy and calming financial companion.

### Personality Traits:

* Calm
* Thoughtful
* Non-judgmental
* Encouraging
* Wise, but never pushy

### Voice Examples:

> “Hey, you’ve done well this week. You spent mindfully and stayed under budget.”
> “Let’s explore a plan to help you reach that vacation goal faster. You’ve got this.”

---

## 🔒 11. User Data & Privacy Principles

### Goal:

Ensure trust through transparency and user control.

### Requirements:

* User owns their data
* No sharing or monetizing personal financial info
* Clear, optional consent for AI insights
* All insights generated purely for user’s benefit

---

## ✅ 12. Success Criteria

* Users feel more in control of their money
* Daily/weekly engagement with expense logging
* Users report positive behavioral change in finances
* AI feels helpful, not intrusive
* AIFA feels like *“a friend who gets it”*

---

## 🔧 13. Tech Stack

**Platform:**

* Flutter (cross-platform mobile app)
* Supabase (auth, database, storage, realtime, edge function)

**AI Layer:**

* Gemma (LLM/AI, via google gemini API, model=gemma-3-27b-it)
* LangChain.dart (AI agent & tools orchestration)

---

## 🎨 14. Design Language

**Vibe:**

* modern, Calm, clean, and human — like a friendly financial guide

**Colors:**

* Green (primary color)

**Fonts:**

* Inter

**UI Style:**

* Chat + visual interface (graphs, cards, widgets)
* Simple language, minimal clutter
* 3 taps max to get things done
* Motivational tone, personalized suggestions
