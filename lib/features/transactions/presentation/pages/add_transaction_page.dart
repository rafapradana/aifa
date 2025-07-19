import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/transactions_provider.dart';
import '../../../../core/providers/user_profile_provider.dart';
import '../../../../core/models/transaction.dart';
import '../../../../core/utils/currency_formatter.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isExpense = true;
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _expenseCategories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Healthcare',
    'Education',
    'Groceries',
    'Other',
  ];

  final List<String> _incomeCategories = [
    'Salary',
    'Freelance',
    'Business',
    'Investment',
    'Gift',
    'Other',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final transactionsNotifier = ref.read(transactionsProvider.notifier);
      final amount = double.parse(_amountController.text.replaceAll(',', ''));

      await transactionsNotifier.addTransaction(
        amount: amount,
        type: _isExpense ? TransactionType.expense : TransactionType.income,
        category: _selectedCategory!,
        description:
            _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
        date: _selectedDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTransaction,
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction Type Toggle
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transaction Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Expense'),
                              selected: _isExpense,
                              onSelected: (selected) {
                                setState(() {
                                  _isExpense = true;
                                  _selectedCategory = null;
                                });
                              },
                              selectedColor: Colors.red[100],
                              labelStyle: TextStyle(
                                color: _isExpense ? Colors.red : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Income'),
                              selected: !_isExpense,
                              onSelected: (selected) {
                                setState(() {
                                  _isExpense = false;
                                  _selectedCategory = null;
                                });
                              },
                              selectedColor: Colors.green[100],
                              labelStyle: TextStyle(
                                color: !_isExpense ? Colors.green : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Amount Input
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Consumer(
                        builder: (context, ref, child) {
                          final userProfile = ref.watch(userProfileProvider);
                          final currency = userProfile.when(
                            data: (profile) => profile?.currency ?? 'USD',
                            loading: () => 'USD',
                            error: (_, __) => 'USD',
                          );
                          final currencySymbol =
                              currency == 'USD'
                                  ? '\$'
                                  : currency == 'EUR'
                                  ? '€'
                                  : currency == 'IDR'
                                  ? 'Rp'
                                  : '\$';

                          return TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixText: '$currencySymbol ',
                              hintText:
                                  currency == 'USD'
                                      ? '100'
                                      : currency == 'EUR'
                                      ? '90'
                                      : currency == 'IDR'
                                      ? '100,000'
                                      : '100',
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an amount';
                              }
                              if (double.tryParse(value.replaceAll(',', '')) ==
                                  null) {
                                return 'Please enter a valid amount';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Category Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            (_isExpense
                                    ? _expenseCategories
                                    : _incomeCategories)
                                .map((category) {
                                  return ChoiceChip(
                                    label: Text(category),
                                    selected: _selectedCategory == category,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedCategory =
                                            selected ? category : null;
                                      });
                                    },
                                  );
                                })
                                .toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Date Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _selectedDate = date;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat(
                                  'EEEE, MMM dd, yyyy',
                                ).format(_selectedDate),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Description
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description (Optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintText: 'Add a note about this transaction...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Smart Input Suggestion
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Smart Input',
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
                        'Try typing naturally like "paid rent 1.5 million" or "lunch 45k"',
                        style: TextStyle(color: Colors.blue[600]),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'e.g., "bought groceries 150k"',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.auto_fix_high),
                            onPressed: () {
                              // TODO: Implement natural language processing
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Smart parsing coming soon!'),
                                ),
                              );
                            },
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
      ),
    );
  }
}
