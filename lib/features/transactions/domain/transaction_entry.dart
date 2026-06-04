enum TransactionType {
  expense,
  income,
}

class TransactionEntry {
  const TransactionEntry({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.createdAt,
    this.note,
  });

  final String id;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final DateTime createdAt;
  final String? note;

  bool get isExpense => type == TransactionType.expense;

  TransactionEntry copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? categoryId,
    DateTime? createdAt,
    String? note,
  }) {
    return TransactionEntry(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.name,
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
      'note': note,
    };
  }

  static TransactionEntry fromJson(Map<String, dynamic> json) {
    return TransactionEntry(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (item) => item.name == json['type'],
      ),
      categoryId: json['categoryId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      note: json['note'] as String?,
    );
  }
}
