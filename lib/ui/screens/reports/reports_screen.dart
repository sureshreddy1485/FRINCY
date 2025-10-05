import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/providers/customer_provider.dart';
import '../../../core/providers/transaction_provider.dart';
import '../../../core/services/database_service.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'This Month';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  final List<String> _periods = [
    'Today',
    'This Week',
    'This Month',
    'This Year',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();
    _updateDateRange(_selectedPeriod);
  }

  void _updateDateRange(String period) {
    final now = DateTime.now();
    
    switch (period) {
      case 'Today':
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'This Week':
        _startDate = now.subtract(Duration(days: now.weekday - 1));
        _endDate = now;
        break;
      case 'This Month':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
        break;
      case 'This Year':
        _startDate = DateTime(now.year, 1, 1);
        _endDate = now;
        break;
      case 'Custom':
        _selectCustomDateRange();
        return;
    }
    
    setState(() {
      _selectedPeriod = period;
    });
  }

  Future<void> _selectCustomDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedPeriod = 'Custom';
      });
    }
  }

  Future<void> _exportToPDF() async {
    final pdf = pw.Document();
    
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    
    final customers = customerProvider.customers;
    final summary = transactionProvider.getTransactionSummary();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Frincy Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              '${DateFormat('MMM dd, yyyy').format(_startDate)} - ${DateFormat('MMM dd, yyyy').format(_endDate)}',
              style: const pw.TextStyle(fontSize: 14),
            ),
            pw.Divider(),
            pw.SizedBox(height: 16),
            
            pw.Text(
              'Summary',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Credit:'),
                pw.Text('₹${summary['credit']!.toStringAsFixed(2)}'),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Debit:'),
                pw.Text('₹${summary['debit']!.toStringAsFixed(2)}'),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Net Balance:'),
                pw.Text('₹${summary['net']!.toStringAsFixed(2)}'),
              ],
            ),
            
            pw.SizedBox(height: 24),
            pw.Text(
              'Customer Balances',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Customer', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Balance', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                ...customers.map((customer) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(customer.name),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('₹${customer.formattedBalance}'),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  Future<void> _exportToExcel() async {
    // This would require the excel package implementation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Excel export coming soon')),
    );
  }

  Future<void> _shareReport() async {
    final summary = Provider.of<TransactionProvider>(context, listen: false).getTransactionSummary();
    
    final text = '''
Frincy Report
${DateFormat('MMM dd, yyyy').format(_startDate)} - ${DateFormat('MMM dd, yyyy').format(_endDate)}

Summary:
Total Credit: ₹${summary['credit']!.toStringAsFixed(2)}
Total Debit: ₹${summary['debit']!.toStringAsFixed(2)}
Net Balance: ₹${summary['net']!.toStringAsFixed(2)}
''';

    await Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'pdf':
                  _exportToPDF();
                  break;
                case 'excel':
                  _exportToExcel();
                  break;
                case 'share':
                  _shareReport();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf),
                    SizedBox(width: 8),
                    Text('Export to PDF'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'excel',
                child: Row(
                  children: [
                    Icon(Icons.table_chart),
                    SizedBox(width: 8),
                    Text('Export to Excel'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share Report'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Period Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Period',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _periods.map((period) {
                        return ChoiceChip(
                          label: Text(period),
                          selected: _selectedPeriod == period,
                          onSelected: (selected) {
                            if (selected) {
                              _updateDateRange(period);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    if (_selectedPeriod == 'Custom') ...[
                      const SizedBox(height: 12),
                      Text(
                        '${DateFormat('MMM dd, yyyy').format(_startDate)} - ${DateFormat('MMM dd, yyyy').format(_endDate)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Transaction Summary
            Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                final summary = provider.getTransactionSummary();
                
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transaction Summary',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Divider(height: 24),
                        _buildSummaryRow('Total Credit', summary['credit']!, Colors.green),
                        const SizedBox(height: 12),
                        _buildSummaryRow('Total Debit', summary['debit']!, Colors.red),
                        const Divider(height: 24),
                        _buildSummaryRow(
                          'Net Balance',
                          summary['net']!,
                          summary['net']! >= 0 ? Colors.green : Colors.red,
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Customer Balances
            Consumer<CustomerProvider>(
              builder: (context, provider, child) {
                final balances = provider.getTotalBalances();
                
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer Balances',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Divider(height: 24),
                        _buildSummaryRow('You will get', balances['credit']!, Colors.green),
                        const SizedBox(height: 12),
                        _buildSummaryRow('You will give', balances['debit']!, Colors.red),
                        const Divider(height: 24),
                        _buildSummaryRow(
                          'Net Balance',
                          balances['credit']! - balances['debit']!,
                          balances['credit']! >= balances['debit']! ? Colors.green : Colors.red,
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Top Customers
            Consumer<CustomerProvider>(
              builder: (context, provider, child) {
                final topCustomers = provider.customers
                    .where((c) => c.balance != 0)
                    .toList()
                  ..sort((a, b) => b.balance.abs().compareTo(a.balance.abs()));

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Top Customers by Balance',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Divider(height: 24),
                        if (topCustomers.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('No customer balances'),
                            ),
                          )
                        else
                          ...topCustomers.take(10).map((customer) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Text(
                                  customer.name[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(customer.name),
                              subtitle: Text(customer.balanceStatus),
                              trailing: Text(
                                '₹${customer.formattedBalance}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: customer.balance >= 0 ? Colors.green : Colors.red,
                                ),
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, Color color, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '₹${amount.abs().toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
