import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String? _verificationId;
  bool _codeSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    final phoneNumber = '+91${_phoneController.text.trim()}';
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    await authProvider.signInWithPhone(
      phoneNumber,
      (verificationId) {
        setState(() {
          _verificationId = verificationId;
          _codeSent = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully')),
        );
      },
    );
  }

  Future<void> _verifyOTP() async {
    if (_verificationId == null) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.verifyOTP(
      _verificationId!,
      _otpController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'OTP verification failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Login'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Icon(
                Icons.phone_android,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Enter your phone number',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We will send you an OTP to verify',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                enabled: !_codeSent,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  prefixText: '+91 ',
                  hintText: '9876543210',
                ),
              ),
              if (_codeSent) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'OTP',
                    prefixIcon: Icon(Icons.lock),
                    hintText: '123456',
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : (_codeSent ? _verifyOTP : _sendOTP),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(_codeSent ? 'Verify OTP' : 'Send OTP'),
                    ),
                  );
                },
              ),
              if (_codeSent) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _codeSent = false;
                      _verificationId = null;
                      _otpController.clear();
                    });
                  },
                  child: const Text('Change Phone Number'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
