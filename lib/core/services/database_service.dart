import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../models/user_model.dart';
import '../models/customer_model.dart';
import '../models/transaction_model.dart';
import '../models/reminder_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('frincy.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT';
    const intType = 'INTEGER';
    const realType = 'REAL';

    // Users table
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        name $textType,
        email $textType,
        phoneNumber $textType,
        photoUrl $textType,
        businessName $textType,
        address $textType,
        createdAt $textType NOT NULL,
        lastLoginAt $textType,
        isPinEnabled $intType DEFAULT 0,
        isBiometricEnabled $intType DEFAULT 0
      )
    ''');

    // Customers table
    await db.execute('''
      CREATE TABLE customers (
        id $idType,
        name $textType NOT NULL,
        phoneNumber $textType,
        email $textType,
        address $textType,
        photoUrl $textType,
        balance $realType DEFAULT 0,
        createdAt $textType NOT NULL,
        updatedAt $textType,
        notes $textType,
        isActive $intType DEFAULT 1
      )
    ''');

    // Transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id $idType,
        customerId $textType NOT NULL,
        type $textType NOT NULL,
        amount $realType NOT NULL,
        date $textType NOT NULL,
        notes $textType,
        attachments $textType,
        createdAt $textType NOT NULL,
        updatedAt $textType,
        category $textType,
        paymentMode $textType,
        FOREIGN KEY (customerId) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');

    // Reminders table
    await db.execute('''
      CREATE TABLE reminders (
        id $idType,
        customerId $textType NOT NULL,
        type $textType NOT NULL,
        scheduledDate $textType NOT NULL,
        message $textType NOT NULL,
        status $textType DEFAULT 'pending',
        sendSMS $intType DEFAULT 0,
        sendWhatsApp $intType DEFAULT 1,
        sendPushNotification $intType DEFAULT 1,
        createdAt $textType NOT NULL,
        sentAt $textType,
        FOREIGN KEY (customerId) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_customer_name ON customers(name)');
    await db.execute('CREATE INDEX idx_transaction_customer ON transactions(customerId)');
    await db.execute('CREATE INDEX idx_transaction_date ON transactions(date)');
    await db.execute('CREATE INDEX idx_reminder_scheduled ON reminders(scheduledDate)');
  }

  Future<void> initialize() async {
    await database;
  }

  // User CRUD operations
  Future<void> createUser(UserModel user) async {
    final db = await database;
    await db.insert('users', user.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserModel?> getUser(String id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return UserModel.fromJson(maps.first);
  }

  Future<void> updateUser(UserModel user) async {
    final db = await database;
    await db.update('users', user.toJson(), where: 'id = ?', whereArgs: [user.id]);
  }

  // Customer CRUD operations
  Future<String> createCustomer(CustomerModel customer) async {
    final db = await database;
    await db.insert('customers', customer.toJson());
    return customer.id;
  }

  Future<CustomerModel?> getCustomer(String id) async {
    final db = await database;
    final maps = await db.query('customers', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return CustomerModel.fromJson(maps.first);
  }

  Future<List<CustomerModel>> getAllCustomers({bool activeOnly = true}) async {
    final db = await database;
    final maps = await db.query(
      'customers',
      where: activeOnly ? 'isActive = ?' : null,
      whereArgs: activeOnly ? [1] : null,
      orderBy: 'name ASC',
    );
    return maps.map((map) => CustomerModel.fromJson(map)).toList();
  }

  Future<List<CustomerModel>> searchCustomers(String query) async {
    final db = await database;
    final maps = await db.query(
      'customers',
      where: 'name LIKE ? OR phoneNumber LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map((map) => CustomerModel.fromJson(map)).toList();
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    final db = await database;
    await db.update('customers', customer.toJson(), where: 'id = ?', whereArgs: [customer.id]);
  }

  Future<void> deleteCustomer(String id) async {
    final db = await database;
    await db.update('customers', {'isActive': 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateCustomerBalance(String customerId, double newBalance) async {
    final db = await database;
    await db.update(
      'customers',
      {'balance': newBalance, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [customerId],
    );
  }

  // Transaction CRUD operations
  Future<String> createTransaction(TransactionModel transaction) async {
    final db = await database;
    await db.insert('transactions', transaction.toJson());
    
    // Update customer balance
    final customer = await getCustomer(transaction.customerId);
    if (customer != null) {
      final balanceChange = transaction.type == TransactionType.credit 
          ? transaction.amount 
          : -transaction.amount;
      await updateCustomerBalance(transaction.customerId, customer.balance + balanceChange);
    }
    
    return transaction.id;
  }

  Future<List<TransactionModel>> getCustomerTransactions(String customerId) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'customerId = ?',
      whereArgs: [customerId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => TransactionModel.fromJson(map)).toList();
  }

  Future<List<TransactionModel>> getAllTransactions({DateTime? startDate, DateTime? endDate}) async {
    final db = await database;
    String? where;
    List<dynamic>? whereArgs;

    if (startDate != null && endDate != null) {
      where = 'date BETWEEN ? AND ?';
      whereArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    }

    final maps = await db.query(
      'transactions',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );
    return maps.map((map) => TransactionModel.fromJson(map)).toList();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    
    // Get old transaction to calculate balance difference
    final oldMaps = await db.query('transactions', where: 'id = ?', whereArgs: [transaction.id]);
    if (oldMaps.isNotEmpty) {
      final oldTransaction = TransactionModel.fromJson(oldMaps.first);
      final customer = await getCustomer(transaction.customerId);
      
      if (customer != null) {
        // Reverse old transaction
        final oldBalanceChange = oldTransaction.type == TransactionType.credit 
            ? -oldTransaction.amount 
            : oldTransaction.amount;
        
        // Apply new transaction
        final newBalanceChange = transaction.type == TransactionType.credit 
            ? transaction.amount 
            : -transaction.amount;
        
        await updateCustomerBalance(
          transaction.customerId, 
          customer.balance + oldBalanceChange + newBalanceChange
        );
      }
    }
    
    await db.update('transactions', transaction.toJson(), where: 'id = ?', whereArgs: [transaction.id]);
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    
    // Get transaction to update customer balance
    final maps = await db.query('transactions', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      final transaction = TransactionModel.fromJson(maps.first);
      final customer = await getCustomer(transaction.customerId);
      
      if (customer != null) {
        final balanceChange = transaction.type == TransactionType.credit 
            ? -transaction.amount 
            : transaction.amount;
        await updateCustomerBalance(transaction.customerId, customer.balance + balanceChange);
      }
    }
    
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // Reminder CRUD operations
  Future<String> createReminder(ReminderModel reminder) async {
    final db = await database;
    await db.insert('reminders', reminder.toJson());
    return reminder.id;
  }

  Future<List<ReminderModel>> getCustomerReminders(String customerId) async {
    final db = await database;
    final maps = await db.query(
      'reminders',
      where: 'customerId = ?',
      whereArgs: [customerId],
      orderBy: 'scheduledDate DESC',
    );
    return maps.map((map) => ReminderModel.fromJson(map)).toList();
  }

  Future<List<ReminderModel>> getPendingReminders() async {
    final db = await database;
    final maps = await db.query(
      'reminders',
      where: 'status = ? AND scheduledDate <= ?',
      whereArgs: ['pending', DateTime.now().toIso8601String()],
      orderBy: 'scheduledDate ASC',
    );
    return maps.map((map) => ReminderModel.fromJson(map)).toList();
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    final db = await database;
    await db.update('reminders', reminder.toJson(), where: 'id = ?', whereArgs: [reminder.id]);
  }

  Future<void> deleteReminder(String id) async {
    final db = await database;
    await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  // Analytics and Reports
  Future<Map<String, double>> getTotalBalances() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN balance > 0 THEN balance ELSE 0 END) as totalCredit,
        SUM(CASE WHEN balance < 0 THEN balance ELSE 0 END) as totalDebit
      FROM customers
      WHERE isActive = 1
    ''');
    
    return {
      'totalCredit': result.first['totalCredit'] as double? ?? 0.0,
      'totalDebit': (result.first['totalDebit'] as double? ?? 0.0).abs(),
    };
  }

  Future<Map<String, double>> getTransactionSummary(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN type = 'credit' THEN amount ELSE 0 END) as totalCredit,
        SUM(CASE WHEN type = 'debit' THEN amount ELSE 0 END) as totalDebit
      FROM transactions
      WHERE date BETWEEN ? AND ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    
    return {
      'totalCredit': result.first['totalCredit'] as double? ?? 0.0,
      'totalDebit': result.first['totalDebit'] as double? ?? 0.0,
    };
  }

  // Database backup and restore
  Future<String> exportDatabase() async {
    final db = await database;
    final customers = await getAllCustomers(activeOnly: false);
    final transactions = await getAllTransactions();
    
    final data = {
      'customers': customers.map((c) => c.toJson()).toList(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
    };
    
    return jsonEncode(data);
  }

  Future<void> importDatabase(String jsonData) async {
    final data = jsonDecode(jsonData);
    final db = await database;
    
    // Clear existing data
    await db.delete('transactions');
    await db.delete('customers');
    
    // Import customers
    for (var customerJson in data['customers']) {
      await db.insert('customers', customerJson);
    }
    
    // Import transactions
    for (var transactionJson in data['transactions']) {
      await db.insert('transactions', transactionJson);
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
