import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/customer_model.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/providers/transaction_provider.dart';
import '../../../core/providers/customer_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final CustomerModel? customer;
  final TransactionModel? transaction;

  const AddTransactionScreen({super.key, this.customer, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  TransactionType _type = TransactionType.credit;
  DateTime _selectedDate = DateTime.now();
  CustomerModel? _selectedCustomer;
  String? _paymentMode;
  List<String> _attachments = [];

  final List<String> _paymentModes = [
    'Cash',
    'UPI',
    'Card',
    'Bank Transfer',
    'Cheque',
    'Other',
  ];

  bool get isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    _selectedCustomer = widget.customer;
    
    if (isEditing) {
      _type = widget.transaction!.type;
      _amountController.text = widget.transaction!.amount.toString();
      _notesController.text = widget.transaction!.notes ?? '';
      _selectedDate = widget.transaction!.date;
      _paymentMode = widget.transaction!.paymentMode;
      _attachments = widget.transaction!.attachments ?? [];
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      setState(() {
        _attachments.add(image.path);
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCustomer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a customer'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final provider = Provider.of<TransactionProvider>(context, listen: false);

      final transaction = TransactionModel(
        id: widget.transaction?.id ?? '',
        customerId: _selectedCustomer!.id,
        type: _type,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        attachments: _attachments.isEmpty ? null : _attachments,
        paymentMode: _paymentMode,
        createdAt: widget.transaction?.createdAt ?? DateTime.now(),
      );

      if (isEditing) {
        await provider.updateTransaction(transaction);
      } else {
        await provider.addTransaction(transaction);
      }

      // Reload customer to update balance
      final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
      await customerProvider.loadCustomers();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Transaction updated' : 'Transaction added'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction'),
        actions: [
          TextButton(
            onPressed: _saveTransaction,
            child: const Text('SAVE'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Transaction Type
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction Type',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<TransactionType>(
                              title: const Text('Credit (You will get)'),
                              value: TransactionType.credit,
                              groupValue: _type,
                              onChanged: (value) {
                                setState(() {
                                  _type = value!;
                                });
                              },
                              activeColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<TransactionType>(
                              title: const Text('Debit (You will give)'),
                              value: TransactionType.debit,
                              groupValue: _type,
                              onChanged: (value) {
                                setState(() {
                                  _type = value!;
                                });
                              },
                              activeColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Customer Selection
              if (widget.customer == null)
                Consumer<CustomerProvider>(
                  builder: (context, provider, child) {
                    return DropdownButtonFormField<CustomerModel>(
                      value: _selectedCustomer,
                      decoration: const InputDecoration(
                        labelText: 'Customer *',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      items: provider.customers.map((customer) {
                        return DropdownMenuItem(
                          value: customer,
                          child: Text(customer.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCustomer = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a customer';
                        }
                        return null;
                      },
                    );
                  },
                ),

              if (widget.customer != null)
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        widget.customer!.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(widget.customer!.name),
                    subtitle: widget.customer!.phoneNumber != null
                        ? Text(widget.customer!.phoneNumber!)
                        : null,
                  ),
                ),

              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount *',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Date
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate)),
                ),
              ),

              const SizedBox(height: 16),

              // Payment Mode
              DropdownButtonFormField<String>(
                value: _paymentMode,
                decoration: const InputDecoration(
                  labelText: 'Payment Mode',
                  prefixIcon: Icon(Icons.payment),
                ),
                items: _paymentModes.map((mode) {
                  return DropdownMenuItem(
                    value: mode,
                    child: Text(mode),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _paymentMode = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.note_outlined),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 16),

              // Attachments
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Attachments',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          TextButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Add Photo'),
                          ),
                        ],
                      ),
                      if (_attachments.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _attachments.map((path) {
                            return Chip(
                              label: const Text('Receipt'),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () {
                                setState(() {
                                  _attachments.remove(path);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _saveTransaction,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(isEditing ? 'Update Transaction' : 'Add Transaction'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
