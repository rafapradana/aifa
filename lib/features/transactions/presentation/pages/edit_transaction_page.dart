import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/transaction.dart';
import '../../../../core/providers/transactions_provider.dart';

class EditTransactionPage extends ConsumerStatefulWidget {
  final Transaction transaction;

  const EditTransactionPage({super.key, required this.transaction});

  @override
  ConsumerState<EditTransactionPage> createState() =>
      _EditTransactionPageState();
}

class _EditTransactionPageState extends ConsumerState<EditTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  late TransactionType _selectedType;
  late String _selectedCategory;
  late DateTime _selectedDate;

  final List<String> _expenseCategories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Healthcare',
    'Education',
    'Travel',
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
  void initState() {
    super.initState();
    _amountController.text = widget.transaction.amount.toString();
    _descriptionController.text = widget.transaction.description ?? '';
    _selectedType = widget.transaction.type;
    _selectedCategory = widget.transaction.category;
    _selectedDate = widget.transaction.date;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<String> get _availableCategories {
    return _selectedType == TransactionType.expense
        ? _expenseCategories
        : _incomeCategories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Transaction'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _showDeleteConfirmation,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Transaction Type
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Transaction Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<TransactionType>(
                            title: const Text('Income'),
                            value: TransactionType.income,
                            groupValue: _selectedType,
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value!;
                                // Reset category when type changes
                                _selectedCategory = _availableCategories.first;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<TransactionType>(
                            title: const Text('Expense'),
                            value: TransactionType.expense,
                            groupValue: _selectedType,
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value!;
                                // Reset category when type changes
                                _selectedCategory = _availableCategories.first;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Amount
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    return null;
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  value:
                      _availableCategories.contains(_selectedCategory)
                          ? _selectedCategory
                          : _availableCategories.first,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      _availableCategories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Date
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _saveTransaction,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Save Changes', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedTransaction = widget.transaction.copyWith(
          amount: double.parse(_amountController.text),
          type: _selectedType,
          category: _selectedCategory,
          description:
              _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
          date: _selectedDate,
        );

        await ref
            .read(transactionsProvider.notifier)
            .updateTransaction(updatedTransaction);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating transaction: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Transaction'),
            content: const Text(
              'Are you sure you want to delete this transaction? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _deleteTransaction();
    }
  }

  Future<void> _deleteTransaction() async {
    try {
      await ref
          .read(transactionsProvider.notifier)
          .deleteTransaction(widget.transaction.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting transaction: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
