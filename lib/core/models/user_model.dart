class UserModel {
  final String id;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? photoUrl;
  final String? businessName;
  final String? address;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isPinEnabled;
  final bool isBiometricEnabled;

  UserModel({
    required this.id,
    this.name,
    this.email,
    this.phoneNumber,
    this.photoUrl,
    this.businessName,
    this.address,
    required this.createdAt,
    this.lastLoginAt,
    this.isPinEnabled = false,
    this.isBiometricEnabled = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'businessName': businessName,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isPinEnabled': isPinEnabled ? 1 : 0,
      'isBiometricEnabled': isBiometricEnabled ? 1 : 0,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      photoUrl: json['photoUrl'],
      businessName: json['businessName'],
      address: json['address'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt']) 
          : null,
      isPinEnabled: json['isPinEnabled'] == 1,
      isBiometricEnabled: json['isBiometricEnabled'] == 1,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? photoUrl,
    String? businessName,
    String? address,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isPinEnabled,
    bool? isBiometricEnabled,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      businessName: businessName ?? this.businessName,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isPinEnabled: isPinEnabled ?? this.isPinEnabled,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
    );
  }
}
