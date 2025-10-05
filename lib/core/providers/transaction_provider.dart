import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/transaction_model.dart';
import '../services/database_service.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get filterStartDate => _filterStartDate;
  DateTime? get filterEndDate => _filterEndDate;

  Future<void> loadAllTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await DatabaseService.instance.getAllTransactions(
        startDate: _filterStartDate,
        endDate: _filterEndDate,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCustomerTransactions(String customerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await DatabaseService.instance.getCustomerTransactions(customerId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final newTransaction = transaction.copyWith(
        id: const Uuid().v4(),
        createdAt: DateTime.now(),
      );
      
      await DatabaseService.instance.createTransaction(newTransaction);
      _transactions.insert(0, newTransaction);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      final updatedTransaction = transaction.copyWith(updatedAt: DateTime.now());
      await DatabaseService.instance.updateTransaction(updatedTransaction);
      
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = updatedTransaction;
      }
      
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await DatabaseService.instance.deleteTransaction(transactionId);
      _transactions.removeWhere((t) => t.id == transactionId);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void setDateFilter(DateTime? startDate, DateTime? endDate) {
    _filterStartDate = startDate;
    _filterEndDate = endDate;
    loadAllTransactions();
  }

  void clearDateFilter() {
    _filterStartDate = null;
    _filterEndDate = null;
    loadAllTransactions();
  }

  Map<String, double> getTransactionSummary() {
    double totalCredit = 0;
    double totalDebit = 0;

    for (var transaction in _transactions) {
      if (transaction.type == TransactionType.credit) {
        totalCredit += transaction.amount;
      } else {
        totalDebit += transaction.amount;
      }
    }

    return {
      'credit': totalCredit,
      'debit': totalDebit,
      'net': totalCredit - totalDebit,
    };
  }

  List<TransactionModel> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((transaction) {
      return transaction.date.isAfter(start.subtract(const Duration(days: 1))) &&
          transaction.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  Map<String, List<TransactionModel>> groupTransactionsByDate() {
    final Map<String, List<TransactionModel>> grouped = {};

    for (var transaction in _transactions) {
      final dateKey = '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}-${transaction.date.day.toString().padLeft(2, '0')}';
      
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
