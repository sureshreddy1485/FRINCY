class CustomerModel {
  final String id;
  final String name;
  final String? phoneNumber;
  final String? email;
  final String? address;
  final String? photoUrl;
  final double balance; // Positive = customer owes you, Negative = you owe customer
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notes;
  final bool isActive;

  CustomerModel({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.email,
    this.address,
    this.photoUrl,
    this.balance = 0.0,
    required this.createdAt,
    this.updatedAt,
    this.notes,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'photoUrl': photoUrl,
      'balance': balance,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'notes': notes,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      address: json['address'],
      photoUrl: json['photoUrl'],
      balance: json['balance']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      notes: json['notes'],
      isActive: json['isActive'] == 1,
    );
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? address,
    String? photoUrl,
    double? balance,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    bool? isActive,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      photoUrl: photoUrl ?? this.photoUrl,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }

  String get balanceStatus {
    if (balance > 0) return 'You will get';
    if (balance < 0) return 'You will give';
    return 'Settled';
  }

  String get formattedBalance {
    return balance.abs().toStringAsFixed(2);
  }
}
