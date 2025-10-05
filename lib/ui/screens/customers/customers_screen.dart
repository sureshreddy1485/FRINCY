import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/customer_provider.dart';
import '../../../core/models/customer_model.dart';
import '../../widgets/customer_card.dart';
import 'add_customer_screen.dart';
import 'customer_detail_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          PopupMenuButton<CustomerSortType>(
            icon: const Icon(Icons.sort),
            onSelected: (sortType) {
              Provider.of<CustomerProvider>(context, listen: false).setSortType(sortType);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: CustomerSortType.name,
                child: Text('Sort by Name'),
              ),
              const PopupMenuItem(
                value: CustomerSortType.balance,
                child: Text('Sort by Balance'),
              ),
              const PopupMenuItem(
                value: CustomerSortType.date,
                child: Text('Sort by Date'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          Consumer<CustomerProvider>(
            builder: (context, provider, child) {
              final balances = provider.getTotalBalances();
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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'You will get',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${balances['credit']!.toStringAsFixed(2)}',
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
                            'You will give',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${balances['debit']!.toStringAsFixed(2)}',
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
              );
            },
          ),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          Provider.of<CustomerProvider>(context, listen: false)
                              .searchCustomers('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                Provider.of<CustomerProvider>(context, listen: false)
                    .searchCustomers(value);
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Customer List
          Expanded(
            child: Consumer<CustomerProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.customers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No customers yet',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first customer to get started',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadCustomers(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.customers.length,
                    itemBuilder: (context, index) {
                      final customer = provider.customers[index];
                      return CustomerCard(
                        customer: customer,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CustomerDetailScreen(customer: customer),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Customer'),
      ),
    );
  }
}
