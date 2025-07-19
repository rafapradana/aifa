import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/goal.dart';

class AIService {
  static GenerativeModel? _model;

  static GenerativeModel get model {
    if (_model == null) {
      final apiKey = dotenv.env['GOOGLE_AI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('Google AI API key not found in environment variables');
      }

      _model = GenerativeModel(
        model: 'gemma-3-27b-it',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
      );
    }
    return _model!;
  }

  /// Analyze spending patterns and provide insights
  static Future<String> analyzeSpendingPatterns({
    required List<Transaction> transactions,
    required Map<String, double> categoryTotals,
    required double totalIncome,
    required double totalExpenses,
  }) async {
    try {
      final prompt = '''
You are AIFA, a friendly AI financial assistant. Analyze the following financial data and provide personalized insights in a conversational, encouraging tone.

Financial Summary:
- Total Income: \$${totalIncome.toStringAsFixed(2)}
- Total Expenses: \$${totalExpenses.toStringAsFixed(2)}
- Net Income: \$${(totalIncome - totalExpenses).toStringAsFixed(2)}

Category Spending:
${categoryTotals.entries.map((e) => '- ${e.key}: \$${e.value.toStringAsFixed(2)}').join('\n')}

Recent Transactions (last 5):
${transactions.take(5).map((t) => '- ${t.date.day}/${t.date.month}: ${t.type.toString().split('.').last} - ${t.category} - \$${t.amount}').join('\n')}

Please provide:
1. A brief, encouraging summary of their financial health
2. 2-3 specific insights about their spending patterns
3. 1-2 actionable recommendations
4. Keep it friendly, personal, and under 200 words

Use a conversational tone like you're talking to a friend, not a formal financial advisor.
''';

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to generate insights at this time.';
    } catch (e) {
      return 'I\'m having trouble analyzing your data right now. Please try again later.';
    }
  }

  /// Provide budget recommendations based on income and spending
  static Future<String> generateBudgetRecommendations({
    required double monthlyIncome,
    required Map<String, double> currentSpending,
    required List<String> userCategories,
  }) async {
    try {
      final prompt = '''
You are AIFA, a friendly AI financial assistant. Help create a personalized budget recommendation.

User's Financial Profile:
- Monthly Income: \$${monthlyIncome.toStringAsFixed(2)}
- Current Spending by Category:
${currentSpending.entries.map((e) => '- ${e.key}: \$${e.value.toStringAsFixed(2)}').join('\n')}

User's Preferred Categories: ${userCategories.join(', ')}

Please provide:
1. A suggested budget allocation using the 50/30/20 rule as a baseline
2. Specific recommendations for each category
3. Tips for optimizing their current spending
4. Keep it encouraging and actionable

Format as a friendly conversation, under 250 words.
''';

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ??
          'Unable to generate budget recommendations at this time.';
    } catch (e) {
      return 'I\'m having trouble creating budget recommendations right now. Please try again later.';
    }
  }

  /// Provide goal achievement strategies
  static Future<String> generateGoalStrategy({
    required Goal goal,
    required double monthlyIncome,
    required double monthlyExpenses,
  }) async {
    try {
      final remainingAmount = goal.targetAmount - goal.currentAmount;
      final monthsRemaining =
          goal.deadline != null
              ? goal.deadline!.difference(DateTime.now()).inDays / 30.0
              : 12.0; // Default to 12 months if no deadline

      final prompt = '''
You are AIFA, a friendly AI financial assistant. Help create a strategy to achieve this savings goal.

Goal Details:
- Goal: ${goal.title}
- Target Amount: \$${goal.targetAmount.toStringAsFixed(2)}
- Current Amount: \$${goal.currentAmount.toStringAsFixed(2)}
- Remaining: \$${remainingAmount.toStringAsFixed(2)}
- Time Remaining: ${monthsRemaining.toStringAsFixed(1)} months

Financial Context:
- Monthly Income: \$${monthlyIncome.toStringAsFixed(2)}
- Monthly Expenses: \$${monthlyExpenses.toStringAsFixed(2)}
- Available for Savings: \$${(monthlyIncome - monthlyExpenses).toStringAsFixed(2)}

Please provide:
1. A realistic monthly savings target
2. 2-3 specific strategies to reach this goal
3. Encouragement and motivation
4. Tips for staying on track

Keep it personal, encouraging, and under 200 words.
''';

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to generate goal strategy at this time.';
    } catch (e) {
      return 'I\'m having trouble creating a goal strategy right now. Please try again later.';
    }
  }

  /// Categorize transaction automatically
  static Future<String> categorizeTransaction({
    required String description,
    required double amount,
    required List<String> availableCategories,
  }) async {
    try {
      final prompt = '''
Categorize this transaction into one of the available categories.

Transaction: "$description" - \$${amount.toStringAsFixed(2)}

Available Categories: ${availableCategories.join(', ')}

Rules:
1. Return ONLY the category name, nothing else
2. Choose the most appropriate category from the list
3. If unsure, choose "Other"
4. Be consistent with similar transactions

Category:''';

      final response = await model.generateContent([Content.text(prompt)]);
      final category = response.text?.trim() ?? 'Other';

      // Validate that the returned category is in the available list
      if (availableCategories.contains(category)) {
        return category;
      } else {
        return 'Other';
      }
    } catch (e) {
      return 'Other';
    }
  }

  /// Generate financial tips based on user behavior
  static Future<List<String>> generateFinancialTips({
    required Map<String, dynamic> userStats,
    required List<Transaction> recentTransactions,
  }) async {
    try {
      final prompt = '''
You are AIFA, a friendly AI financial assistant. Generate 3-5 personalized financial tips.

User Statistics:
- Savings Rate: ${userStats['savingsRate']?.toStringAsFixed(1) ?? '0'}%
- Top Expense Category: ${userStats['topExpenseCategory'] ?? 'Unknown'}
- Average Daily Spending: \$${(userStats['totalExpenses'] / 30)?.toStringAsFixed(2) ?? '0'}

Recent Spending Patterns:
${recentTransactions.take(10).map((t) => '- ${t.category}: \$${t.amount}').join('\n')}

Generate 3-5 specific, actionable tips that are:
1. Personalized to their spending patterns
2. Encouraging and positive
3. Practical and easy to implement
4. Each tip should be one sentence

Format as a simple list, one tip per line.
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';

      // Parse the response into individual tips
      final tips =
          text
              .split('\n')
              .where((line) => line.trim().isNotEmpty)
              .map((line) => line.replaceAll(RegExp(r'^[-•*]\s*'), '').trim())
              .where((tip) => tip.isNotEmpty)
              .take(5)
              .toList();

      return tips.isNotEmpty
          ? tips
          : [
            'Keep tracking your expenses - you\'re building great financial habits!',
            'Consider setting up automatic savings to reach your goals faster.',
            'Review your subscriptions monthly to avoid unnecessary charges.',
          ];
    } catch (e) {
      return [
        'Keep tracking your expenses - you\'re building great financial habits!',
        'Consider setting up automatic savings to reach your goals faster.',
        'Review your subscriptions monthly to avoid unnecessary charges.',
      ];
    }
  }

  /// Chat with AIFA about financial questions
  static Future<String> chatWithAIFA({
    required String userMessage,
    required Map<String, dynamic> userContext,
  }) async {
    try {
      final prompt = '''
You are AIFA, a friendly AI financial assistant. The user is asking: "$userMessage"

User's Financial Context:
- Monthly Income: \$${userContext['monthlyIncome']?.toStringAsFixed(2) ?? 'Unknown'}
- Monthly Expenses: \$${userContext['monthlyExpenses']?.toStringAsFixed(2) ?? 'Unknown'}
- Savings Rate: ${userContext['savingsRate']?.toStringAsFixed(1) ?? '0'}%
- Active Goals: ${userContext['activeGoals'] ?? 0}
- Budget Categories: ${userContext['budgetCategories']?.join(', ') ?? 'None set'}

Guidelines:
1. Be friendly, encouraging, and conversational
2. Provide specific, actionable advice when possible
3. Reference their financial context when relevant
4. Keep responses under 150 words
5. If you don't have enough context, ask clarifying questions
6. Never give investment advice or guarantee returns

Respond as AIFA:''';

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ??
          'I\'m having trouble understanding your question right now. Could you try rephrasing it?';
    } catch (e) {
      return 'I\'m having some technical difficulties right now. Please try again in a moment!';
    }
  }
}
