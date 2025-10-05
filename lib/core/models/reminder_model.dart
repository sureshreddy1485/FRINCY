enum ReminderType { payment, custom }
enum ReminderStatus { pending, sent, cancelled }

class ReminderModel {
  final String id;
  final String customerId;
  final ReminderType type;
  final DateTime scheduledDate;
  final String message;
  final ReminderStatus status;
  final bool sendSMS;
  final bool sendWhatsApp;
  final bool sendPushNotification;
  final DateTime createdAt;
  final DateTime? sentAt;

  ReminderModel({
    required this.id,
    required this.customerId,
    required this.type,
    required this.scheduledDate,
    required this.message,
    this.status = ReminderStatus.pending,
    this.sendSMS = false,
    this.sendWhatsApp = true,
    this.sendPushNotification = true,
    required this.createdAt,
    this.sentAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'type': type == ReminderType.payment ? 'payment' : 'custom',
      'scheduledDate': scheduledDate.toIso8601String(),
      'message': message,
      'status': status.toString().split('.').last,
      'sendSMS': sendSMS ? 1 : 0,
      'sendWhatsApp': sendWhatsApp ? 1 : 0,
      'sendPushNotification': sendPushNotification ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'sentAt': sentAt?.toIso8601String(),
    };
  }

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'],
      customerId: json['customerId'],
      type: json['type'] == 'payment' 
          ? ReminderType.payment 
          : ReminderType.custom,
      scheduledDate: DateTime.parse(json['scheduledDate']),
      message: json['message'],
      status: ReminderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ReminderStatus.pending,
      ),
      sendSMS: json['sendSMS'] == 1,
      sendWhatsApp: json['sendWhatsApp'] == 1,
      sendPushNotification: json['sendPushNotification'] == 1,
      createdAt: DateTime.parse(json['createdAt']),
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : null,
    );
  }

  ReminderModel copyWith({
    String? id,
    String? customerId,
    ReminderType? type,
    DateTime? scheduledDate,
    String? message,
    ReminderStatus? status,
    bool? sendSMS,
    bool? sendWhatsApp,
    bool? sendPushNotification,
    DateTime? createdAt,
    DateTime? sentAt,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      type: type ?? this.type,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      message: message ?? this.message,
      status: status ?? this.status,
      sendSMS: sendSMS ?? this.sendSMS,
      sendWhatsApp: sendWhatsApp ?? this.sendWhatsApp,
      sendPushNotification: sendPushNotification ?? this.sendPushNotification,
      createdAt: createdAt ?? this.createdAt,
      sentAt: sentAt ?? this.sentAt,
    );
  }
}
