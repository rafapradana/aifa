class Budget {
  final String id;
  final String userId;
  final String category;
  final double allocatedAmount;
  final double spentAmount;
  final DateTime month;
  final DateTime createdAt;
  final DateTime updatedAt;

  Budget({
    required this.id,
    required this.userId,
    required this.category,
    required this.allocatedAmount,
    this.spentAmount = 0.0,
    required this.month,
    required this.createdAt,
    required this.updatedAt,
  });

  double get remainingAmount => allocatedAmount - spentAmount;
  double get spentPercentage =>
      allocatedAmount > 0 ? (spentAmount / allocatedAmount) * 100 : 0;
  bool get isOverBudget => spentAmount > allocatedAmount;

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      userId: json['user_id'],
      category: json['category'],
      allocatedAmount: json['allocated_amount'].toDouble(),
      spentAmount: json['spent_amount']?.toDouble() ?? 0.0,
      month: DateTime.parse(json['month']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category': category,
      'allocated_amount': allocatedAmount,
      'spent_amount': spentAmount,
      'month': month.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Budget copyWith({
    String? id,
    String? userId,
    String? category,
    double? allocatedAmount,
    double? spentAmount,
    DateTime? month,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      month: month ?? this.month,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
