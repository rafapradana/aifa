import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/user_profile_provider.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Onboarding data
  double? _monthlyIncome;
  String? _financialGoal;
  List<String> _selectedCategories = [];
  String? _userType;
  String _selectedCurrency = 'USD';

  final List<String> _availableCategories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Healthcare',
    'Education',
    'Travel',
    'Groceries',
    'Other',
  ];

  final List<String> _userTypes = [
    'Student',
    'Employee',
    'Freelancer',
    'Business Owner',
    'Retired',
    'Other',
  ];

  final Map<String, Map<String, String>> _availableCurrencies = {
    'IDR': {'name': 'Indonesian Rupiah', 'symbol': 'Rp'},
    'USD': {'name': 'US Dollar', 'symbol': '\$'},
    'EUR': {'name': 'Euro', 'symbol': '€'},
    'GBP': {'name': 'British Pound', 'symbol': '£'},
    'JPY': {'name': 'Japanese Yen', 'symbol': '¥'},
    'SGD': {'name': 'Singapore Dollar', 'symbol': 'S\$'},
    'MYR': {'name': 'Malaysian Ringgit', 'symbol': 'RM'},
    'THB': {'name': 'Thai Baht', 'symbol': '฿'},
    'AUD': {'name': 'Australian Dollar', 'symbol': 'A\$'},
    'CAD': {'name': 'Canadian Dollar', 'symbol': 'C\$'},
  };

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    if (_monthlyIncome == null ||
        _userType == null ||
        _selectedCategories.isEmpty) {
      return;
    }

    final userProfileNotifier = ref.read(userProfileProvider.notifier);

    try {
      await userProfileNotifier.createUserProfile(
        monthlyIncome: _monthlyIncome!,
        financialGoal: _financialGoal,
        spendingCategories: _selectedCategories,
        userType: _userType!,
        fullName: null, // Will use name from auth metadata
        currency: _selectedCurrency,
      );

      if (mounted) {
        context.go('/dashboard');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / 4,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF4CAF50),
                ),
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildWelcomePage(),
                  _buildIncomePage(),
                  _buildGoalPage(),
                  _buildCategoriesPage(),
                ],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox(),

                  ElevatedButton(
                    onPressed: _canProceed() ? _nextPage : null,
                    child: Text(_currentPage == 3 ? 'Get Started' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return true;
      case 1:
        return _monthlyIncome != null && _userType != null;
      case 2:
        return true; // Goal is optional
      case 3:
        return _selectedCategories.isNotEmpty;
      default:
        return false;
    }
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.waving_hand, size: 80, color: Color(0xFF4CAF50)),
          const SizedBox(height: 24),
          Text(
            'Welcome to AIFA!',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Let\'s set up your personalized financial companion. This will only take a few minutes.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.security, color: Color(0xFF4CAF50)),
                  SizedBox(height: 8),
                  Text(
                    'Your data is private and secure',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'We never share your financial information',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us about yourself',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us personalize AIFA for your situation',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          Text(
            'What\'s your monthly income range?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          // Currency Selection
          Text(
            'Select your currency',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            value: _selectedCurrency,
            decoration: const InputDecoration(
              labelText: 'Currency',
              prefixIcon: Icon(Icons.attach_money),
            ),
            items:
                _availableCurrencies.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Row(
                      children: [
                        Text(
                          entry.value['symbol']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${entry.key} - ${entry.value['name']}'),
                      ],
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCurrency = value!;
              });
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Monthly Income',
              prefixText:
                  '${_availableCurrencies[_selectedCurrency]!['symbol']} ',
              hintText:
                  _selectedCurrency == 'USD'
                      ? '3,000'
                      : _selectedCurrency == 'EUR'
                      ? '2,800'
                      : _selectedCurrency == 'IDR'
                      ? '5,000,000'
                      : _selectedCurrency == 'SGD'
                      ? '4,000'
                      : '3,000',
            ),
            onChanged: (value) {
              setState(() {
                _monthlyIncome = double.tryParse(value.replaceAll(',', ''));
              });
            },
          ),

          const SizedBox(height: 32),

          Text(
            'Which best describes you?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _userTypes.map((type) {
                  return ChoiceChip(
                    label: Text(type),
                    selected: _userType == type,
                    onSelected: (selected) {
                      setState(() {
                        _userType = selected ? type : null;
                      });
                    },
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s your main financial goal?',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'This is optional, but helps us give better advice',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Financial Goal (Optional)',
              hintText: 'Save for vacation, buy a laptop, emergency fund...',
            ),
            maxLines: 3,
            onChanged: (value) {
              setState(() {
                _financialGoal = value.isEmpty ? null : value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What do you usually spend on?',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your common spending categories',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _availableCategories.length,
              itemBuilder: (context, index) {
                final category = _availableCategories[index];
                final isSelected = _selectedCategories.contains(category);

                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
