import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/transaction_model.dart';
import '../../core/models/customer_model.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final CustomerModel? customer;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.customer,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == TransactionType.credit;
    final color = isCredit ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (customer != null) ...[
                        Text(
                          customer!.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        DateFormat('MMM dd, yyyy - hh:mm a').format(transaction.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isCredit ? '+' : '-'}₹${transaction.formattedAmount}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (transaction.paymentMode != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        transaction.paymentMode!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            if (transaction.notes != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.note, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        transaction.notes!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (transaction.attachments != null && transaction.attachments!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    avatar: const Icon(Icons.attach_file, size: 16),
                    label: Text('${transaction.attachments!.length} attachment(s)'),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
