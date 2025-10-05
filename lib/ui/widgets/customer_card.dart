import 'package:flutter/material.dart';
import '../../core/models/customer_model.dart';

class CustomerCard extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback onTap;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  customer.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
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
                      customer.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (customer.phoneNumber != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        customer.phoneNumber!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      customer.balanceStatus,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: customer.balance >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${customer.formattedBalance}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: customer.balance >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
