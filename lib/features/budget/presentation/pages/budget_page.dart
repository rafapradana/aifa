import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class BudgetPage extends ConsumerStatefulWidget {
  const BudgetPage({super.key});

  @override
  ConsumerState<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends ConsumerState<BudgetPage> {
  final List<BudgetCategory> _budgetCategories = [
    BudgetCategory(
      name: 'Food & Dining',
      allocated: 1000000,
      spent: 850000,
      icon: Icons.restaurant,
      color: Colors.orange,
    ),
    BudgetCategory(
      name: 'Transportation',
      allocated: 500000,
      spent: 320000,
      icon: Icons.directions_car,
      color: Colors.blue,
    ),
    BudgetCategory(
      name: 'Shopping',
      allocated: 750000,
      spent: 920000,
      icon: Icons.shopping_bag,
      color: Colors.purple,
    ),
    BudgetCategory(
      name: 'Entertainment',
      allocated: 300000,
      spent: 180000,
      icon: Icons.movie,
      color: Colors.pink,
    ),
    BudgetCategory(
      name: 'Bills & Utilities',
      allocated: 800000,
      spent: 750000,
      icon: Icons.receipt,
      color: Colors.teal,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final totalAllocated = _budgetCategories.fold<double>(
      0,
      (sum, category) => sum + category.allocated,
    );
    final totalSpent = _budgetCategories.fold<double>(
      0,
      (sum, category) => sum + category.spent,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddBudgetDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBudgetOverview(totalAllocated, totalSpent),
            const SizedBox(height: 24),
            _buildBudgetSuggestion(),
            const SizedBox(height: 24),
            _buildBudgetCategories(),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetOverview(double totalAllocated, double totalSpent) {
    final remaining = totalAllocated - totalSpent;
    final spentPercentage =
        totalAllocated > 0 ? (totalSpent / totalAllocated) * 100 : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This Month\'s Budget',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Budget',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(totalAllocated),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Spent', style: TextStyle(color: Colors.grey)),
                      Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(totalSpent),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:
                              spentPercentage > 100
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      remaining >= 0 ? 'Remaining' : 'Over Budget',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      '${spentPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: spentPercentage > 100 ? Colors.red : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: remaining >= 0 ? 'Rp ' : '-Rp ',
                    decimalDigits: 0,
                  ).format(remaining.abs()),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: remaining >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: spentPercentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    spentPercentage > 100
                        ? Colors.red
                        : spentPercentage > 80
                        ? Colors.orange
                        : Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSuggestion() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Budget Suggestion',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Based on the 50/30/20 rule, here\'s a suggested budget allocation:',
              style: TextStyle(color: Colors.blue[600]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSuggestionItem(
                    'Needs',
                    '50%',
                    'Rp 2.5M',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildSuggestionItem(
                    'Wants',
                    '30%',
                    'Rp 1.5M',
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildSuggestionItem(
                    'Savings',
                    '20%',
                    'Rp 1M',
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(
    String title,
    String percentage,
    String amount,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(amount, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildBudgetCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Budget Categories',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _budgetCategories.length,
          itemBuilder: (context, index) {
            return _buildBudgetCategoryCard(_budgetCategories[index]);
          },
        ),
      ],
    );
  }

  Widget _buildBudgetCategoryCard(BudgetCategory category) {
    final spentPercentage =
        category.allocated > 0
            ? (category.spent / category.allocated) * 100
            : 0;
    final remaining = category.allocated - category.spent;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: category.color.withOpacity(0.2),
                  child: Icon(category.icon, color: category.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(category.spent)} of ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(category.allocated)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${spentPercentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: spentPercentage > 100 ? Colors.red : Colors.grey,
                      ),
                    ),
                    Text(
                      remaining >= 0 ? 'left' : 'over',
                      style: TextStyle(
                        fontSize: 12,
                        color: remaining >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: spentPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                spentPercentage > 100
                    ? Colors.red
                    : spentPercentage > 80
                    ? Colors.orange
                    : category.color,
              ),
            ),
            if (spentPercentage > 90)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        spentPercentage > 100
                            ? Colors.red[50]
                            : Colors.orange[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        spentPercentage > 100 ? Icons.warning : Icons.info,
                        size: 16,
                        color:
                            spentPercentage > 100 ? Colors.red : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          spentPercentage > 100
                              ? 'You\'ve exceeded your budget for this category'
                              : 'You\'re close to your budget limit',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                spentPercentage > 100
                                    ? Colors.red
                                    : Colors.orange,
                          ),
                        ),
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

  void _showAddBudgetDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Budget Category'),
            content: const Text(
              'Feature coming soon! You\'ll be able to add custom budget categories.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}

class BudgetCategory {
  final String name;
  final double allocated;
  final double spent;
  final IconData icon;
  final Color color;

  BudgetCategory({
    required this.name,
    required this.allocated,
    required this.spent,
    required this.icon,
    required this.color,
  });
}
