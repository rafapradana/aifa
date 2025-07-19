import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/transactions_provider.dart';
import '../../../../core/providers/budget_provider.dart';
import '../../../../core/providers/goals_provider.dart';
import '../../../../core/utils/currency_formatter.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'This Month';

  final List<String> _periods = [
    'This Week',
    'This Month',
    'Last 3 Months',
    'This Year',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder:
                (context) =>
                    _periods.map((period) {
                      return PopupMenuItem(value: period, child: Text(period));
                    }).toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedPeriod),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Spending'),
            Tab(text: 'Trends'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOverviewTab(), _buildSpendingTab(), _buildTrendsTab()],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFinancialSummary(),
          const SizedBox(height: 24),
          _buildInsightsCard(),
          const SizedBox(height: 24),
          _buildTopCategoriesCard(),
        ],
      ),
    );
  }

  Widget _buildSpendingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSpendingChart(),
          const SizedBox(height: 24),
          _buildCategoryBreakdown(),
          const SizedBox(height: 24),
          _buildTransactionHistory(),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTrendChart(),
          const SizedBox(height: 24),
          _buildMonthlyComparison(),
          const SizedBox(height: 24),
          _buildSavingsRate(),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary() {
    final transactionStats = ref.watch(transactionStatsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Summary - $_selectedPeriod',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            transactionStats.when(
              data: (stats) {
                final income = stats['totalIncome'] as double;
                final expenses = stats['totalExpenses'] as double;
                final netIncome = stats['netIncome'] as double;
                final savingsRate = stats['savingsRate'] as double;

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryItem(
                            'Total Income',
                            CurrencyFormatter.format(income),
                            Colors.green,
                            Icons.trending_up,
                          ),
                        ),
                        Expanded(
                          child: _buildSummaryItem(
                            'Total Expenses',
                            CurrencyFormatter.format(expenses),
                            Colors.red,
                            Icons.trending_down,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryItem(
                            'Net Savings',
                            CurrencyFormatter.format(netIncome),
                            netIncome >= 0 ? Colors.blue : Colors.red,
                            Icons.savings,
                          ),
                        ),
                        Expanded(
                          child: _buildSummaryItem(
                            'Savings Rate',
                            '${savingsRate.toStringAsFixed(1)}%',
                            savingsRate >= 20 ? Colors.green : Colors.orange,
                            Icons.percent,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard() {
    final budgetAlerts = ref.watch(budgetAlertsProvider);
    final goalReminders = ref.watch(goalRemindersProvider);
    final transactionStats = ref.watch(transactionStatsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Key Insights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Show savings rate insight
            transactionStats.when(
              data: (stats) {
                final savingsRate = stats['savingsRate'] as double;
                if (savingsRate > 0) {
                  return _buildInsightItem(
                    Icons.trending_up,
                    'Great Progress!',
                    'You\'re saving ${savingsRate.toStringAsFixed(1)}% of your income this month',
                    savingsRate >= 20 ? Colors.green : Colors.orange,
                  );
                } else {
                  return _buildInsightItem(
                    Icons.trending_down,
                    'Spending Alert',
                    'You\'re spending more than you earn this month',
                    Colors.red,
                  );
                }
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Show budget alerts
            budgetAlerts.when(
              data: (alerts) {
                if (alerts.isNotEmpty) {
                  return Column(
                    children:
                        alerts.take(2).map((alert) {
                          IconData icon = Icons.warning;
                          Color color = Colors.orange;

                          if (alert.startsWith('⚠️')) {
                            icon = Icons.error;
                            color = Colors.red;
                          } else if (alert.startsWith('🔶')) {
                            icon = Icons.warning;
                            color = Colors.orange;
                          } else if (alert.startsWith('🔸')) {
                            icon = Icons.info;
                            color = Colors.blue;
                          }

                          return _buildInsightItem(
                            icon,
                            'Budget Alert',
                            alert.replaceAll(RegExp(r'^[⚠️🔶🔸]\s*'), ''),
                            color,
                          );
                        }).toList(),
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Show goal reminders
            goalReminders.when(
              data: (reminders) {
                if (reminders.isNotEmpty) {
                  return Column(
                    children:
                        reminders.take(1).map((reminder) {
                          IconData icon = Icons.flag;
                          Color color = Colors.blue;

                          if (reminder.startsWith('🔴')) {
                            icon = Icons.schedule;
                            color = Colors.red;
                          } else if (reminder.startsWith('🟡')) {
                            icon = Icons.schedule;
                            color = Colors.orange;
                          } else if (reminder.startsWith('🎉')) {
                            icon = Icons.celebration;
                            color = Colors.green;
                          } else if (reminder.startsWith('💪')) {
                            icon = Icons.trending_up;
                            color = Colors.green;
                          }

                          return _buildInsightItem(
                            icon,
                            'Goal Update',
                            reminder.replaceAll(
                              RegExp(r'^[🔴🟡🎉💪⚠️]\s*'),
                              '',
                            ),
                            color,
                          );
                        }).toList(),
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.2),
            radius: 16,
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategoriesCard() {
    final currentMonthTransactions = ref.watch(
      currentMonthTransactionsProvider,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Spending Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            currentMonthTransactions.when(
              data: (transactions) {
                // Calculate category totals for expenses only
                final Map<String, double> categoryTotals = {};
                double totalExpenses = 0;

                for (final transaction in transactions) {
                  if (transaction.type.toString().split('.').last ==
                      'expense') {
                    categoryTotals[transaction.category] =
                        (categoryTotals[transaction.category] ?? 0) +
                        transaction.amount;
                    totalExpenses += transaction.amount;
                  }
                }

                if (categoryTotals.isEmpty) {
                  return const Text(
                    'No expense data available for this period.',
                  );
                }

                // Sort categories by amount and take top 5
                final sortedCategories =
                    categoryTotals.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value));

                final topCategories = sortedCategories.take(5).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topCategories.length,
                  itemBuilder: (context, index) {
                    final category = topCategories[index];
                    final percentage =
                        totalExpenses > 0
                            ? (category.value / totalExpenses) * 100
                            : 0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              category.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            CurrencyFormatter.format(category.value),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error loading categories: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingChart() {
    final currentMonthTransactions = ref.watch(
      currentMonthTransactionsProvider,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spending Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            currentMonthTransactions.when(
              data: (transactions) {
                // Calculate category totals for expenses only
                final Map<String, double> categoryTotals = {};
                double totalExpenses = 0;

                for (final transaction in transactions) {
                  if (transaction.type.toString().split('.').last ==
                      'expense') {
                    categoryTotals[transaction.category] =
                        (categoryTotals[transaction.category] ?? 0) +
                        transaction.amount;
                    totalExpenses += transaction.amount;
                  }
                }

                if (categoryTotals.isEmpty) {
                  return const SizedBox(
                    height: 200,
                    child: Center(
                      child: Text('No expense data available for chart'),
                    ),
                  );
                }

                // Sort categories and take top 5, group others
                final sortedCategories =
                    categoryTotals.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value));

                final List<PieChartSectionData> sections = [];
                final colors = [
                  Colors.purple,
                  Colors.orange,
                  Colors.blue,
                  Colors.teal,
                  Colors.pink,
                  Colors.green,
                ];

                double othersTotal = 0;
                for (int i = 0; i < sortedCategories.length; i++) {
                  final category = sortedCategories[i];
                  final percentage = (category.value / totalExpenses) * 100;

                  if (i < 5 && percentage >= 5) {
                    sections.add(
                      PieChartSectionData(
                        value: percentage,
                        title:
                            '${category.key}\n${percentage.toStringAsFixed(1)}%',
                        color: colors[i % colors.length],
                        radius: 60,
                        titleStyle: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  } else {
                    othersTotal += percentage;
                  }
                }

                // Add "Others" section if there are small categories
                if (othersTotal > 0) {
                  sections.add(
                    PieChartSectionData(
                      value: othersTotal,
                      title: 'Others\n${othersTotal.toStringAsFixed(1)}%',
                      color: Colors.grey,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                );
              },
              loading:
                  () => const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
              error:
                  (error, stack) => SizedBox(
                    height: 200,
                    child: Center(child: Text('Error loading chart: $error')),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Detailed spending analysis coming soon!'),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Transaction history will be displayed here.'),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spending Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 2.2),
                        FlSpot(1, 2.8),
                        FlSpot(2, 2.1),
                        FlSpot(3, 2.5),
                        FlSpot(4, 2.3),
                        FlSpot(5, 2.7),
                        FlSpot(6, 2.4),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyComparison() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Comparison',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Month-to-month comparison charts coming soon!'),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsRate() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Savings Rate Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Your savings rate has been consistently above 40%!'),
          ],
        ),
      ),
    );
  }
}
