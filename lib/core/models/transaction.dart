enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String userId;
  final double amount;
  final TransactionType type;
  final String category;
  final String? description;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    this.description,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['user_id'],
      amount: json['amount'].toDouble(),
      type: TransactionType.values.firstWhere((e) => e.name == json['type']),
      category: json['category'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'type': type.name,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Transaction copyWith({
    String? id,
    String? userId,
    double? amount,
    TransactionType? type,
    String? category,
    String? description,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
