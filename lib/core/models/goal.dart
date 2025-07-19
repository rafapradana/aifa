class Goal {
  final String id;
  final String userId;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;

  Goal({
    required this.id,
    required this.userId,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.deadline,
    required this.createdAt,
    required this.updatedAt,
  });

  double get progressPercentage =>
      targetAmount > 0 ? (currentAmount / targetAmount) * 100 : 0;
  double get remainingAmount => targetAmount - currentAmount;
  bool get isCompleted => currentAmount >= targetAmount;

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      targetAmount: json['target_amount'].toDouble(),
      currentAmount: json['current_amount']?.toDouble() ?? 0.0,
      deadline:
          json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'deadline': deadline?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Goal copyWith({
    String? id,
    String? userId,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
