enum TransactionType { credit, debit }

class TransactionModel {
  final String id;
  final String customerId;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String? notes;
  final List<String>? attachments; // Image/receipt URLs
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? category;
  final String? paymentMode;

  TransactionModel({
    required this.id,
    required this.customerId,
    required this.type,
    required this.amount,
    required this.date,
    this.notes,
    this.attachments,
    required this.createdAt,
    this.updatedAt,
    this.category,
    this.paymentMode,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'type': type == TransactionType.credit ? 'credit' : 'debit',
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
      'attachments': attachments?.join(','),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'category': category,
      'paymentMode': paymentMode,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      customerId: json['customerId'],
      type: json['type'] == 'credit' 
          ? TransactionType.credit 
          : TransactionType.debit,
      amount: json['amount']?.toDouble() ?? 0.0,
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      attachments: json['attachments'] != null 
          ? (json['attachments'] as String).split(',') 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      category: json['category'],
      paymentMode: json['paymentMode'],
    );
  }

  TransactionModel copyWith({
    String? id,
    String? customerId,
    TransactionType? type,
    double? amount,
    DateTime? date,
    String? notes,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? category,
    String? paymentMode,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      paymentMode: paymentMode ?? this.paymentMode,
    );
  }

  String get formattedAmount {
    return amount.toStringAsFixed(2);
  }

  String get typeString {
    return type == TransactionType.credit ? 'Credit' : 'Debit';
  }
}
