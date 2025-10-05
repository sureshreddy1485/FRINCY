import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/database_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _backupData(BuildContext context) async {
    try {
      final data = await DatabaseService.instance.exportDatabase();
      
      // Save to file
      final directory = await FilePicker.platform.getDirectoryPath();
      if (directory != null) {
        final file = File('$directory/frincy_backup_${DateTime.now().millisecondsSinceEpoch}.json');
        await file.writeAsString(data);
        
        if (!context.mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _restoreData(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final data = await file.readAsString();
        
        await DatabaseService.instance.importDatabase(data);
        
        if (!context.mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data restored successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Restore failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareData(BuildContext context) async {
    try {
      final data = await DatabaseService.instance.exportDatabase();
      
      // Create temporary file
      final directory = Directory.systemTemp;
      final file = File('${directory.path}/frincy_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(data);
      
      await Share.shareXFiles([XFile(file.path)], text: 'Frincy Backup');
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Share failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Profile Section
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final user = authProvider.currentUser;
              
              return Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          user?.name?[0].toUpperCase() ?? 'U',
                          style: const TextStyle(
                            fontSize: 32,
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
                              user?.name ?? 'User',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            if (user?.email != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                user!.email!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                            if (user?.phoneNumber != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                user!.phoneNumber!,
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
                ),
              );
            },
          ),

          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    themeProvider.setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
              );
            },
          ),
          Consumer<LanguageProvider>(
            builder: (context, languageProvider, child) {
              return ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                subtitle: Text(
                  languageProvider.supportedLanguages.firstWhere(
                    (lang) => lang['code'] == '${languageProvider.locale.languageCode}_${languageProvider.locale.countryCode}',
                    orElse: () => {'name': 'English'},
                  )['name']!,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showLanguageDialog(context, languageProvider);
                },
              );
            },
          ),

          // Security Section
          _buildSectionHeader(context, 'Security'),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Set PIN'),
            subtitle: const Text('Secure your app with a PIN'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showSetPINDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Biometric Authentication'),
            subtitle: const Text('Use fingerprint or face ID'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showBiometricDialog(context);
            },
          ),

          // Data Management Section
          _buildSectionHeader(context, 'Data Management'),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup Data'),
            subtitle: const Text('Save your data to a file'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _backupData(context),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore Data'),
            subtitle: const Text('Restore from a backup file'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _restoreData(context),
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share Data'),
            subtitle: const Text('Share backup with another device'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _shareData(context),
          ),

          // About Section
          _buildSectionHeader(context, 'About'),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to privacy policy
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to terms
            },
          ),

          const SizedBox(height: 16),

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && context.mounted) {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  await authProvider.signOut();
                  
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                }
              },
              icon: const Icon(Icons.logout),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Logout'),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, LanguageProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: provider.supportedLanguages.map((lang) {
            final parts = lang['code']!.split('_');
            final locale = Locale(parts[0], parts[1]);
            
            return RadioListTile<Locale>(
              title: Text(lang['name']!),
              value: locale,
              groupValue: provider.locale,
              onChanged: (value) {
                if (value != null) {
                  provider.setLocale(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSetPINDialog(BuildContext context) {
    final pinController = TextEditingController();
    final confirmPinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Enter PIN',
                hintText: '4-digit PIN',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm PIN',
                hintText: '4-digit PIN',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (pinController.text.length != 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN must be 4 digits')),
                );
                return;
              }

              if (pinController.text != confirmPinController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PINs do not match')),
                );
                return;
              }

              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.setPIN(pinController.text);

              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PIN set successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showBiometricDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Biometric Authentication'),
        content: const Text('Enable biometric authentication for quick and secure access to your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.enableBiometric();

              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Biometric authentication enabled'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }
}
