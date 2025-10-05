import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/customer_model.dart';
import '../services/database_service.dart';

class CustomerProvider extends ChangeNotifier {
  List<CustomerModel> _customers = [];
  List<CustomerModel> _filteredCustomers = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  CustomerSortType _sortType = CustomerSortType.name;
  bool _sortAscending = true;

  List<CustomerModel> get customers => _filteredCustomers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  Future<void> loadCustomers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _customers = await DatabaseService.instance.getAllCustomers();
      _applyFiltersAndSort();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCustomer(CustomerModel customer) async {
    try {
      final newCustomer = customer.copyWith(
        id: const Uuid().v4(),
        createdAt: DateTime.now(),
      );
      
      await DatabaseService.instance.createCustomer(newCustomer);
      _customers.add(newCustomer);
      _applyFiltersAndSort();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      final updatedCustomer = customer.copyWith(updatedAt: DateTime.now());
      await DatabaseService.instance.updateCustomer(updatedCustomer);
      
      final index = _customers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        _customers[index] = updatedCustomer;
        _applyFiltersAndSort();
      }
      
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      await DatabaseService.instance.deleteCustomer(customerId);
      _customers.removeWhere((c) => c.id == customerId);
      _applyFiltersAndSort();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  CustomerModel? getCustomerById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  void searchCustomers(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setSortType(CustomerSortType sortType) {
    if (_sortType == sortType) {
      _sortAscending = !_sortAscending;
    } else {
      _sortType = sortType;
      _sortAscending = true;
    }
    _applyFiltersAndSort();
    notifyListeners();
  }

  void _applyFiltersAndSort() {
    // Apply search filter
    if (_searchQuery.isEmpty) {
      _filteredCustomers = List.from(_customers);
    } else {
      _filteredCustomers = _customers.where((customer) {
        return customer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (customer.phoneNumber?.contains(_searchQuery) ?? false) ||
            (customer.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    // Apply sorting
    _filteredCustomers.sort((a, b) {
      int comparison;
      
      switch (_sortType) {
        case CustomerSortType.name:
          comparison = a.name.compareTo(b.name);
          break;
        case CustomerSortType.balance:
          comparison = a.balance.compareTo(b.balance);
          break;
        case CustomerSortType.date:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }
      
      return _sortAscending ? comparison : -comparison;
    });
  }

  Map<String, double> getTotalBalances() {
    double totalCredit = 0;
    double totalDebit = 0;

    for (var customer in _customers) {
      if (customer.balance > 0) {
        totalCredit += customer.balance;
      } else if (customer.balance < 0) {
        totalDebit += customer.balance.abs();
      }
    }

    return {
      'credit': totalCredit,
      'debit': totalDebit,
    };
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

enum CustomerSortType {
  name,
  balance,
  date,
}
