import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/budget.dart';
import 'auth_provider.dart';

class BudgetNotifier extends StateNotifier<AsyncValue<List<Budget>>> {
  BudgetNotifier(this._supabase) : super(const AsyncValue.loading());

  final SupabaseClient _supabase;

  Future<void> loadBudgets({DateTime? month}) async {
    state = const AsyncValue.loading();
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final targetMonth = month ?? DateTime.now();
      final monthStart = DateTime(targetMonth.year, targetMonth.month, 1);

      final response = await _supabase
          .from('budgets')
          .select()
          .eq('user_id', user.id)
          .eq('month', monthStart.toIso8601String().split('T')[0])
          .order('category');

      final budgets =
          (response as List).map((json) => Budget.fromJson(json)).toList();

      state = AsyncValue.data(budgets);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createOrUpdateBudget({
    required String category,
    required double allocatedAmount,
    DateTime? month,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final targetMonth = month ?? DateTime.now();
      final monthStart = DateTime(targetMonth.year, targetMonth.month, 1);

      // Check if budget already exists
      final existingBudget =
          await _supabase
              .from('budgets')
              .select()
              .eq('user_id', user.id)
              .eq('category', category)
              .eq('month', monthStart.toIso8601String().split('T')[0])
              .maybeSingle();

      if (existingBudget != null) {
        // Update existing budget
        await _supabase
            .from('budgets')
            .update({
              'allocated_amount': allocatedAmount,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existingBudget['id']);
      } else {
        // Create new budget
        final budget = Budget(
          id: '', // Will be generated by database
          userId: user.id,
          category: category,
          allocatedAmount: allocatedAmount,
          month: monthStart,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _supabase.from('budgets').insert(budget.toJson());
      }

      await loadBudgets(month: targetMonth);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteBudget(String budgetId) async {
    try {
      await _supabase.from('budgets').delete().eq('id', budgetId);

      await loadBudgets();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<Budget?> getBudgetForCategory({
    required String category,
    DateTime? month,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final targetMonth = month ?? DateTime.now();
      final monthStart = DateTime(targetMonth.year, targetMonth.month, 1);

      final response =
          await _supabase
              .from('budgets')
              .select()
              .eq('user_id', user.id)
              .eq('category', category)
              .eq('month', monthStart.toIso8601String().split('T')[0])
              .maybeSingle();

      if (response != null) {
        return Budget.fromJson(response);
      }
      return null;
    } catch (error) {
      throw Exception('Failed to load budget: $error');
    }
  }

  Future<Map<String, double>> getBudgetSummary({DateTime? month}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return {};

      final targetMonth = month ?? DateTime.now();
      final monthStart = DateTime(targetMonth.year, targetMonth.month, 1);
      final monthEnd = DateTime(targetMonth.year, targetMonth.month + 1, 0);

      // Get budgets for the month
      final budgetResponse = await _supabase
          .from('budgets')
          .select()
          .eq('user_id', user.id)
          .eq('month', monthStart.toIso8601String().split('T')[0]);

      final budgets =
          (budgetResponse as List)
              .map((json) => Budget.fromJson(json))
              .toList();

      // Get actual spending for the month
      final transactionResponse = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', user.id)
          .eq('type', 'expense')
          .gte('date', monthStart.toIso8601String().split('T')[0])
          .lte('date', monthEnd.toIso8601String().split('T')[0]);

      final transactions = transactionResponse as List;

      // Calculate spending by category
      final Map<String, double> categorySpending = {};
      for (final transaction in transactions) {
        final category = transaction['category'] as String;
        final amount = (transaction['amount'] as num).toDouble();
        categorySpending[category] = (categorySpending[category] ?? 0) + amount;
      }

      double totalAllocated = 0;
      double totalSpent = 0;
      int overBudgetCategories = 0;

      for (final budget in budgets) {
        totalAllocated += budget.allocatedAmount;
        final spent = categorySpending[budget.category] ?? 0;
        totalSpent += spent;

        if (spent > budget.allocatedAmount) {
          overBudgetCategories++;
        }
      }

      return {
        'totalAllocated': totalAllocated,
        'totalSpent': totalSpent,
        'remaining': totalAllocated - totalSpent,
        'spentPercentage':
            totalAllocated > 0 ? (totalSpent / totalAllocated) * 100 : 0.0,
        'overBudgetCategories': overBudgetCategories.toDouble(),
        'totalCategories': budgets.length.toDouble(),
      };
    } catch (error) {
      throw Exception('Failed to calculate budget summary: $error');
    }
  }

  Future<Map<String, Map<String, double>>> getBudgetVsActual({
    DateTime? month,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return {};

      final targetMonth = month ?? DateTime.now();
      final monthStart = DateTime(targetMonth.year, targetMonth.month, 1);
      final monthEnd = DateTime(targetMonth.year, targetMonth.month + 1, 0);

      // Get budgets for the month
      final budgetResponse = await _supabase
          .from('budgets')
          .select()
          .eq('user_id', user.id)
          .eq('month', monthStart.toIso8601String().split('T')[0]);

      final budgets =
          (budgetResponse as List)
              .map((json) => Budget.fromJson(json))
              .toList();

      // Get actual spending for the month
      final transactionResponse = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', user.id)
          .eq('type', 'expense')
          .gte('date', monthStart.toIso8601String().split('T')[0])
          .lte('date', monthEnd.toIso8601String().split('T')[0]);

      final transactions = transactionResponse as List;

      // Calculate spending by category
      final Map<String, double> categorySpending = {};
      for (final transaction in transactions) {
        final category = transaction['category'] as String;
        final amount = (transaction['amount'] as num).toDouble();
        categorySpending[category] = (categorySpending[category] ?? 0) + amount;
      }

      // Build budget vs actual comparison
      final Map<String, Map<String, double>> budgetComparison = {};

      for (final budget in budgets) {
        final spent = categorySpending[budget.category] ?? 0;
        final remaining = budget.allocatedAmount - spent;
        final percentage =
            budget.allocatedAmount > 0
                ? (spent / budget.allocatedAmount) * 100
                : 0.0;

        budgetComparison[budget.category] = {
          'allocated': budget.allocatedAmount,
          'spent': spent,
          'remaining': remaining,
          'percentage': percentage,
          'isOverBudget': (spent > budget.allocatedAmount ? 1.0 : 0.0),
        };
      }

      return budgetComparison;
    } catch (error) {
      throw Exception('Failed to calculate budget vs actual: $error');
    }
  }

  Future<List<String>> getBudgetAlerts({DateTime? month}) async {
    try {
      final budgetComparison = await getBudgetVsActual(month: month);
      final List<String> alerts = [];

      budgetComparison.forEach((category, data) {
        final percentage = data['percentage'] ?? 0;
        final isOverBudget = data['isOverBudget'] == 1.0;
        final remaining = data['remaining'] ?? 0;

        if (isOverBudget) {
          alerts.add(
            '⚠️ $category: Over budget by \$${(-remaining).toStringAsFixed(2)}',
          );
        } else if (percentage >= 90) {
          alerts.add(
            '🔶 $category: ${percentage.toStringAsFixed(0)}% of budget used',
          );
        } else if (percentage >= 75) {
          alerts.add(
            '🔸 $category: ${percentage.toStringAsFixed(0)}% of budget used',
          );
        }
      });

      return alerts;
    } catch (error) {
      throw Exception('Failed to generate budget alerts: $error');
    }
  }

  void clearBudgets() {
    state = const AsyncValue.data([]);
  }
}

final budgetProvider =
    StateNotifierProvider<BudgetNotifier, AsyncValue<List<Budget>>>((ref) {
      final supabase = ref.watch(supabaseClientProvider);
      final notifier = BudgetNotifier(supabase);

      // Load budgets when auth state changes
      ref.listen(authStateProvider, (previous, next) {
        next.whenData((authState) {
          if (authState.session?.user != null) {
            notifier.loadBudgets();
          } else {
            notifier.clearBudgets();
          }
        });
      });

      return notifier;
    });

// Provider for current month budget summary
final currentMonthBudgetSummaryProvider = FutureProvider<Map<String, double>>((
  ref,
) async {
  final budgetNotifier = ref.watch(budgetProvider.notifier);
  return await budgetNotifier.getBudgetSummary();
});

// Provider for budget vs actual comparison
final budgetVsActualProvider = FutureProvider<Map<String, Map<String, double>>>(
  (ref) async {
    final budgetNotifier = ref.watch(budgetProvider.notifier);
    return await budgetNotifier.getBudgetVsActual();
  },
);

// Provider for budget alerts
final budgetAlertsProvider = FutureProvider<List<String>>((ref) async {
  final budgetNotifier = ref.watch(budgetProvider.notifier);
  return await budgetNotifier.getBudgetAlerts();
});
