import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/customer_model.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/providers/transaction_provider.dart';
import '../../../core/providers/customer_provider.dart';
import '../../../core/services/notification_service.dart';
import '../../widgets/transaction_card.dart';
import '../transactions/add_transaction_screen.dart';
import 'add_customer_screen.dart';

class CustomerDetailScreen extends StatefulWidget {
  final CustomerModel customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    await provider.loadCustomerTransactions(widget.customer.id);
  }

  Future<void> _sendReminder() async {
    if (widget.customer.phoneNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer phone number not available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final message = NotificationService.instance.generatePaymentReminderMessage(
      widget.customer,
      widget.customer.balance,
    );

    try {
      await NotificationService.instance.sendWhatsAppMessage(
        widget.customer.phoneNumber!,
        message,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send reminder: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteCustomer() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: const Text('Are you sure you want to delete this customer? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final provider = Provider.of<CustomerProvider>(context, listen: false);
      await provider.deleteCustomer(widget.customer.id);
      
      if (!mounted) return;
      
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer deleted'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddCustomerScreen(customer: widget.customer),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteCustomer,
          ),
        ],
      ),
      body: Column(
        children: [
          // Customer Info Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.customer.balance >= 0 
                  ? Colors.green.shade50 
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.customer.balance >= 0 
                    ? Colors.green.shade200 
                    : Colors.red.shade200,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        widget.customer.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.customer.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (widget.customer.phoneNumber != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.customer.phoneNumber!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.customer.balanceStatus,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '₹${widget.customer.formattedBalance}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: widget.customer.balance >= 0 
                            ? Colors.green.shade700 
                            : Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (widget.customer.balance != 0) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _sendReminder,
                    icon: const Icon(Icons.send),
                    label: const Text('Send Reminder'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Transactions Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transactions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddTransactionScreen(customer: widget.customer),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions yet',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = provider.transactions[index];
                    return TransactionCard(transaction: transaction);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddTransactionScreen(customer: widget.customer),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
