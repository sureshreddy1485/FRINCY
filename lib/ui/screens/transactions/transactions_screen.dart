import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/transaction_provider.dart';
import '../../../core/providers/customer_provider.dart';
import '../../widgets/transaction_card.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    await provider.loadAllTransactions();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
    );

    if (picked != null) {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      provider.setDateFilter(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
          Consumer<TransactionProvider>(
            builder: (context, provider, child) {
              if (provider.filterStartDate != null) {
                return IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => provider.clearDateFilter(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          Consumer<TransactionProvider>(
            builder: (context, provider, child) {
              final summary = provider.getTransactionSummary();
              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (provider.filterStartDate != null) ...[
                      Text(
                        '${DateFormat('MMM dd, yyyy').format(provider.filterStartDate!)} - ${DateFormat('MMM dd, yyyy').format(provider.filterEndDate!)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Credit',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${summary['credit']!.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Debit',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${summary['debit']!.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // Transactions List
          Expanded(
            child: Consumer2<TransactionProvider, CustomerProvider>(
              builder: (context, transactionProvider, customerProvider, child) {
                if (transactionProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (transactionProvider.transactions.isEmpty) {
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

                final groupedTransactions = transactionProvider.groupTransactionsByDate();
                final sortedDates = groupedTransactions.keys.toList()..sort((a, b) => b.compareTo(a));

                return RefreshIndicator(
                  onRefresh: _loadTransactions,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sortedDates.length,
                    itemBuilder: (context, index) {
                      final dateKey = sortedDates[index];
                      final transactions = groupedTransactions[dateKey]!;
                      final date = DateTime.parse(dateKey);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              DateFormat('EEEE, MMMM dd, yyyy').format(date),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          ...transactions.map((transaction) {
                            final customer = customerProvider.getCustomerById(transaction.customerId);
                            return TransactionCard(
                              transaction: transaction,
                              customer: customer,
                            );
                          }).toList(),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
