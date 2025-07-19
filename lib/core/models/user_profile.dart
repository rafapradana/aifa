class UserProfile {
  final String id;
  final String? email;
  final String? fullName;
  final double? monthlyIncome;
  final String? financialGoal;
  final List<String> spendingCategories;
  final String? userType; // student, freelancer, employee, etc.
  final String currency; // user's preferred currency
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    this.email,
    this.fullName,
    this.monthlyIncome,
    this.financialGoal,
    this.spendingCategories = const [],
    this.userType,
    this.currency = 'USD',
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      monthlyIncome: json['monthly_income']?.toDouble(),
      financialGoal: json['financial_goal'],
      spendingCategories: List<String>.from(json['spending_categories'] ?? []),
      userType: json['user_type'],
      currency: json['currency'] ?? 'USD',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'monthly_income': monthlyIncome,
      'financial_goal': financialGoal,
      'spending_categories': spendingCategories,
      'user_type': userType,
      'currency': currency,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    double? monthlyIncome,
    String? financialGoal,
    List<String>? spendingCategories,
    String? userType,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      financialGoal: financialGoal ?? this.financialGoal,
      spendingCategories: spendingCategories ?? this.spendingCategories,
      userType: userType ?? this.userType,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
