import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/goal.dart';
import '../utils/currency_formatter.dart';

class ExportService {
  /// Export transactions to CSV format
  static Future<String> exportTransactionsToCSV(
    List<Transaction> transactions,
  ) async {
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln('Date,Type,Category,Amount,Description');

    // CSV Data
    for (final transaction in transactions) {
      final date =
          '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}';
      final type = transaction.type.toString().split('.').last;
      final category = transaction.category;
      final amount = transaction.amount.toString();
      final description = transaction.description ?? '';

      buffer.writeln('$date,$type,$category,$amount,"$description"');
    }

    return buffer.toString();
  }

  /// Export budget summary to CSV format
  static Future<String> exportBudgetToCSV(
    List<Budget> budgets,
    Map<String, Map<String, double>> budgetVsActual,
  ) async {
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln('Category,Allocated,Spent,Remaining,Percentage,Status');

    // CSV Data
    for (final budget in budgets) {
      final actual = budgetVsActual[budget.category];
      if (actual != null) {
        final allocated = actual['allocated']?.toString() ?? '0';
        final spent = actual['spent']?.toString() ?? '0';
        final remaining = actual['remaining']?.toString() ?? '0';
        final percentage = actual['percentage']?.toStringAsFixed(1) ?? '0';
        final status =
            (actual['isOverBudget'] == 1.0) ? 'Over Budget' : 'On Track';

        buffer.writeln(
          '${budget.category},$allocated,$spent,$remaining,$percentage%,$status',
        );
      }
    }

    return buffer.toString();
  }

  /// Export goals to CSV format
  static Future<String> exportGoalsToCSV(List<Goal> goals) async {
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln(
      'Title,Target Amount,Current Amount,Progress,Deadline,Status',
    );

    // CSV Data
    for (final goal in goals) {
      final title = goal.title;
      final target = goal.targetAmount.toString();
      final current = goal.currentAmount.toString();
      final progress =
          goal.targetAmount > 0
              ? ((goal.currentAmount / goal.targetAmount) * 100)
                  .toStringAsFixed(1)
              : '0';
      final deadline = goal.deadline?.toString().split(' ')[0] ?? 'No deadline';
      final status = goal.isCompleted ? 'Completed' : 'In Progress';

      buffer.writeln('"$title",$target,$current,$progress%,$deadline,$status');
    }

    return buffer.toString();
  }

  /// Generate comprehensive financial report
  static Future<String> generateFinancialReport({
    required List<Transaction> transactions,
    required List<Budget> budgets,
    required List<Goal> goals,
    required Map<String, dynamic> stats,
    required Map<String, Map<String, double>> budgetVsActual,
  }) async {
    final buffer = StringBuffer();
    final now = DateTime.now();

    buffer.writeln('AIFA Financial Report');
    buffer.writeln('Generated on: ${now.day}/${now.month}/${now.year}');
    buffer.writeln('=' * 50);
    buffer.writeln();

    // Financial Summary
    buffer.writeln('FINANCIAL SUMMARY');
    buffer.writeln('-' * 20);
    buffer.writeln(
      'Total Income: ${CurrencyFormatter.format(stats['totalIncome'] ?? 0)}',
    );
    buffer.writeln(
      'Total Expenses: ${CurrencyFormatter.format(stats['totalExpenses'] ?? 0)}',
    );
    buffer.writeln(
      'Net Income: ${CurrencyFormatter.format(stats['netIncome'] ?? 0)}',
    );
    buffer.writeln(
      'Savings Rate: ${(stats['savingsRate'] ?? 0).toStringAsFixed(1)}%',
    );
    buffer.writeln('Total Transactions: ${stats['totalTransactions'] ?? 0}');
    buffer.writeln();

    // Budget Performance
    buffer.writeln('BUDGET PERFORMANCE');
    buffer.writeln('-' * 20);
    for (final budget in budgets) {
      final actual = budgetVsActual[budget.category];
      if (actual != null) {
        final percentage = actual['percentage']?.toStringAsFixed(1) ?? '0';
        final status =
            (actual['isOverBudget'] == 1.0) ? 'OVER BUDGET' : 'On Track';
        buffer.writeln('${budget.category}: $percentage% used - $status');
      }
    }
    buffer.writeln();

    // Goals Progress
    buffer.writeln('GOALS PROGRESS');
    buffer.writeln('-' * 15);
    for (final goal in goals) {
      final progress =
          goal.targetAmount > 0
              ? ((goal.currentAmount / goal.targetAmount) * 100)
                  .toStringAsFixed(1)
              : '0';
      final status = goal.isCompleted ? 'COMPLETED' : 'In Progress';
      buffer.writeln('${goal.title}: $progress% - $status');
    }
    buffer.writeln();

    // Recent Transactions (last 10)
    buffer.writeln('RECENT TRANSACTIONS');
    buffer.writeln('-' * 20);
    final recentTransactions = transactions.take(10);
    for (final transaction in recentTransactions) {
      final date = '${transaction.date.day}/${transaction.date.month}';
      final type = transaction.type.toString().split('.').last.toUpperCase();
      final amount = CurrencyFormatter.format(transaction.amount);
      buffer.writeln('$date - $type - ${transaction.category} - $amount');
    }

    return buffer.toString();
  }

  /// Save and share file
  static Future<void> saveAndShareFile(String content, String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(content);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'AIFA Financial Export - $filename');
    } catch (e) {
      throw Exception('Failed to save and share file: $e');
    }
  }

  /// Copy to clipboard
  static Future<void> copyToClipboard(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
  }
}
