import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class GoalsPage extends ConsumerStatefulWidget {
  const GoalsPage({super.key});

  @override
  ConsumerState<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends ConsumerState<GoalsPage> {
  final List<SavingGoal> _goals = [
    SavingGoal(
      id: '1',
      title: 'New Laptop',
      targetAmount: 15000000,
      currentAmount: 9750000,
      deadline: DateTime.now().add(const Duration(days: 60)),
      icon: Icons.laptop,
      color: Colors.blue,
    ),
    SavingGoal(
      id: '2',
      title: 'Emergency Fund',
      targetAmount: 10000000,
      currentAmount: 6500000,
      deadline: DateTime.now().add(const Duration(days: 120)),
      icon: Icons.security,
      color: Colors.green,
    ),
    SavingGoal(
      id: '3',
      title: 'Vacation to Bali',
      targetAmount: 8000000,
      currentAmount: 2400000,
      deadline: DateTime.now().add(const Duration(days: 180)),
      icon: Icons.flight,
      color: Colors.orange,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddGoalDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGoalsOverview(),
            const SizedBox(height: 24),
            _buildGoalsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsOverview() {
    final totalTarget = _goals.fold<double>(
      0,
      (sum, goal) => sum + goal.targetAmount,
    );
    final totalSaved = _goals.fold<double>(
      0,
      (sum, goal) => sum + goal.currentAmount,
    );
    final overallProgress =
        totalTarget > 0 ? (totalSaved / totalTarget) * 100 : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Goals Overview',
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
                        'Total Target',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(totalTarget),
                        style: const TextStyle(
                          fontSize: 18,
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
                      const Text(
                        'Total Saved',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(totalSaved),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
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
                    const Text(
                      'Overall Progress',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      '${overallProgress.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: overallProgress / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Goals',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _goals.length,
          itemBuilder: (context, index) {
            return _buildGoalCard(_goals[index]);
          },
        ),
      ],
    );
  }

  Widget _buildGoalCard(SavingGoal goal) {
    final progress =
        goal.targetAmount > 0
            ? (goal.currentAmount / goal.targetAmount) * 100
            : 0;
    final remaining = goal.targetAmount - goal.currentAmount;
    final daysLeft = goal.deadline?.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: goal.color.withOpacity(0.2),
                  child: Icon(goal.icon, color: goal.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (goal.deadline != null)
                        Text(
                          daysLeft != null && daysLeft > 0
                              ? '$daysLeft days left'
                              : 'Deadline passed',
                          style: TextStyle(
                            color:
                                daysLeft != null && daysLeft > 0
                                    ? Colors.grey
                                    : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${progress.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: goal.color,
                      ),
                    ),
                    if (progress >= 100)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Saved',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(goal.currentAmount),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Target',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(goal.targetAmount),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Remaining',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(remaining),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(goal.color),
            ),

            const SizedBox(height: 12),

            if (progress >= 100)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.celebration, size: 16, color: Colors.green),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Congratulations! You\'ve reached your goal!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              _buildGoalSuggestion(goal, remaining, daysLeft),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddMoneyDialog(goal),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Money'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditGoalDialog(goal),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Goal'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSuggestion(
    SavingGoal goal,
    double remaining,
    int? daysLeft,
  ) {
    if (daysLeft == null || daysLeft <= 0) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning, size: 16, color: Colors.red),
            SizedBox(width: 4),
            Expanded(
              child: Text(
                'Your deadline has passed. Consider extending it.',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }

    final dailySavingNeeded = remaining / daysLeft;
    final monthlySavingNeeded = remaining / (daysLeft / 30);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 4),
              Text(
                'Saving Suggestion',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Save ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(monthlySavingNeeded)} per month to reach your goal on time.',
            style: TextStyle(fontSize: 12, color: Colors.blue[600]),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add New Goal'),
            content: const Text(
              'Feature coming soon! You\'ll be able to create custom savings goals.',
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

  void _showAddMoneyDialog(SavingGoal goal) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Add Money to ${goal.title}'),
            content: const Text(
              'Feature coming soon! You\'ll be able to add money to your goals.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _showEditGoalDialog(SavingGoal goal) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit ${goal.title}'),
            content: const Text(
              'Feature coming soon! You\'ll be able to edit your goals.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }
}

class SavingGoal {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final IconData icon;
  final Color color;

  SavingGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
    required this.icon,
    required this.color,
  });
}
