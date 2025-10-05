import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/customer_provider.dart';
import '../../../core/models/customer_model.dart';

class AddCustomerScreen extends StatefulWidget {
  final CustomerModel? customer;
  
  const AddCustomerScreen({super.key, this.customer});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  bool get isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.customer!.name;
      _phoneController.text = widget.customer!.phoneNumber ?? '';
      _emailController.text = widget.customer!.email ?? '';
      _addressController.text = widget.customer!.address ?? '';
      _notesController.text = widget.customer!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<CustomerProvider>(context, listen: false);

      final customer = CustomerModel(
        id: widget.customer?.id ?? '',
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        balance: widget.customer?.balance ?? 0.0,
        createdAt: widget.customer?.createdAt ?? DateTime.now(),
      );

      if (isEditing) {
        await provider.updateCustomer(customer);
      } else {
        await provider.addCustomer(customer);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Customer updated' : 'Customer added'),
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
        title: Text(isEditing ? 'Edit Customer' : 'Add Customer'),
        actions: [
          TextButton(
            onPressed: _saveCustomer,
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
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter customer name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.note_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveCustomer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(isEditing ? 'Update Customer' : 'Add Customer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
