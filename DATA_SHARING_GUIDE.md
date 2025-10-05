# Data Sharing & Security Guide

This guide explains how to securely share and sync data between devices in Katha Ledger.

## Overview

Katha Ledger supports multiple methods for sharing and syncing your ledger data:
1. **Local Backup/Restore** - Encrypted file export/import
2. **Cloud Backup** - Optional Firebase sync
3. **Direct Sharing** - Share encrypted backup files
4. **QR Code Sharing** - Quick device-to-device transfer (future feature)

## Security Features

### Data Encryption
- All local data is encrypted using **AES-256** encryption
- Backup files are encrypted before export
- User credentials are securely stored using platform-specific secure storage

### Authentication
- Multi-factor authentication support
- PIN protection
- Biometric authentication (Fingerprint/Face ID)

## Method 1: Local Backup & Restore

### Creating a Backup

1. **Open Settings**:
   - Tap on "Settings" tab in bottom navigation
   
2. **Backup Data**:
   - Scroll to "Data Management" section
   - Tap "Backup Data"
   - Choose save location
   - Backup file will be saved as: `katha_backup_[timestamp].json`

3. **Backup Contents**:
   - All customers
   - All transactions
   - User preferences
   - Export timestamp

### Restoring from Backup

1. **Open Settings**:
   - Tap on "Settings" tab
   
2. **Restore Data**:
   - Tap "Restore Data"
   - Select backup file (`.json`)
   - Confirm restoration
   - App will reload with restored data

**⚠️ Warning**: Restoring will replace all existing data. Create a backup first!

## Method 2: Cloud Backup (Optional)

### Enable Cloud Sync

1. **Firebase Setup Required**:
   - Ensure Firebase is configured
   - User must be logged in

2. **Automatic Sync**:
   - Data syncs automatically when online
   - Works in background
   - Conflict resolution handled automatically

3. **Manual Sync**:
   - Pull down to refresh on any screen
   - Forces immediate sync

### Cloud Sync Benefits
- Access data from multiple devices
- Automatic backup
- Real-time updates
- Disaster recovery

### Privacy Considerations
- Data stored in Firebase Firestore
- Encrypted in transit (HTTPS)
- User-specific security rules
- No data sharing between users

## Method 3: Direct File Sharing

### Share Backup File

1. **Create Backup**:
   - Settings → Backup Data
   - Save to device

2. **Share File**:
   - Settings → Share Data
   - Choose sharing method:
     - Email
     - WhatsApp
     - Google Drive
     - Any file sharing app

3. **Recipient Receives**:
   - Download backup file
   - Open Katha Ledger
   - Settings → Restore Data
   - Select received file

### Secure Sharing Best Practices

✅ **Do**:
- Use encrypted messaging apps
- Verify recipient before sharing
- Delete backup files after transfer
- Use password-protected archives for sensitive data

❌ **Don't**:
- Share via public channels
- Leave backup files in shared folders
- Share with untrusted parties
- Keep multiple unencrypted backups

## Method 4: QR Code Sharing (Future Feature)

### How It Will Work

1. **Generate QR Code**:
   - Settings → Share via QR
   - QR code contains encrypted data link

2. **Scan on New Device**:
   - Open Katha Ledger on new device
   - Settings → Scan QR Code
   - Data transfers securely

3. **Security**:
   - Time-limited QR codes
   - One-time use tokens
   - End-to-end encryption

## Data Structure

### Backup File Format

```json
{
  "customers": [
    {
      "id": "uuid",
      "name": "Customer Name",
      "phoneNumber": "+91XXXXXXXXXX",
      "balance": 1000.00,
      "createdAt": "2025-01-01T00:00:00.000Z"
    }
  ],
  "transactions": [
    {
      "id": "uuid",
      "customerId": "customer-uuid",
      "type": "credit",
      "amount": 500.00,
      "date": "2025-01-01T00:00:00.000Z",
      "notes": "Payment received"
    }
  ],
  "exportDate": "2025-01-01T00:00:00.000Z"
}
```

### Encryption Details

- **Algorithm**: AES-256-CBC
- **Key Derivation**: PBKDF2
- **Salt**: Random per backup
- **Iterations**: 10,000+

## Granting Access to Another User

### Scenario: Business Partner Access

If you want to grant access to another person (e.g., business partner):

#### Option 1: Shared Account
1. Share login credentials securely
2. Both use same account
3. Data syncs automatically
4. ⚠️ Both have full access

#### Option 2: Separate Accounts with Data Export
1. Create backup of your data
2. Share backup file securely
3. Partner imports on their account
4. ⚠️ Data won't sync between accounts

#### Option 3: Cloud Sharing (Future Feature)
1. Invite partner via email
2. Set permission level (view/edit)
3. Real-time collaboration
4. Revoke access anytime

## Multi-Device Setup

### Setting Up on Second Device

1. **Install App**:
   - Download Katha Ledger on new device

2. **Choose Method**:
   
   **Method A - Same Account**:
   - Login with same credentials
   - Data syncs automatically (if cloud enabled)
   
   **Method B - Import Backup**:
   - Create backup on first device
   - Transfer file to second device
   - Restore on second device

3. **Verify Data**:
   - Check all customers present
   - Verify transaction history
   - Test creating new transaction

### Keeping Devices in Sync

**With Cloud Sync**:
- Automatic sync when online
- Pull to refresh manually
- Conflict resolution automatic

**Without Cloud Sync**:
- Manual backup/restore required
- Export from Device A
- Import to Device B
- ⚠️ Changes on Device B won't sync back

## Troubleshooting

### Backup Failed
- **Check Storage Space**: Ensure enough space
- **Permissions**: Grant storage permission
- **Try Again**: Close and reopen app

### Restore Failed
- **File Corrupted**: Try different backup
- **Wrong Format**: Ensure it's a Katha backup file
- **Version Mismatch**: Update app to latest version

### Cloud Sync Not Working
- **Internet Connection**: Check connectivity
- **Login Status**: Ensure logged in
- **Firebase Setup**: Verify Firebase configuration
- **Force Sync**: Pull down to refresh

### Data Missing After Restore
- **Incomplete Backup**: Backup may be partial
- **Restore Interrupted**: Try restoring again
- **Check Backup Date**: Ensure correct file

## Best Practices

### Regular Backups
- **Daily**: For active businesses
- **Weekly**: For moderate use
- **Before Updates**: Always backup before app updates

### Backup Storage
- **Multiple Locations**: 
  - Local device
  - Cloud storage (Google Drive, iCloud)
  - External storage
- **Version Control**: Keep last 3-5 backups
- **Naming Convention**: Include date in filename

### Security Checklist
- [ ] Enable PIN/Biometric authentication
- [ ] Regular backups
- [ ] Secure backup storage
- [ ] Don't share credentials
- [ ] Use strong passwords
- [ ] Enable two-factor authentication
- [ ] Review access permissions

## Data Privacy

### What Data is Stored
- Customer names and contact info
- Transaction records
- User profile information
- App preferences

### What is NOT Stored
- Payment card details
- Bank account numbers
- Government ID numbers
- Passwords (only hashed)

### Data Retention
- **Local**: Until manually deleted
- **Cloud**: As per Firebase retention policy
- **Backups**: User controlled

### GDPR Compliance
- Right to access data (export)
- Right to delete data (delete account)
- Right to portability (backup/restore)
- Data encryption at rest and in transit

## Advanced Features

### Automated Backups
```dart
// Future feature: Scheduled backups
// Settings → Auto Backup
// - Daily at specific time
// - Weekly on specific day
// - Before major changes
```

### Selective Restore
```dart
// Future feature: Choose what to restore
// - Only customers
// - Only transactions
// - Specific date range
```

### Merge Data
```dart
// Future feature: Merge instead of replace
// - Combine data from multiple backups
// - Resolve conflicts
// - Deduplicate entries
```

## Support

### Need Help?
- Check app's Help section
- Review this guide
- Contact support
- Report issues on GitHub

### Reporting Data Issues
When reporting data-related issues, include:
- App version
- Device model and OS version
- Steps to reproduce
- Backup file (if safe to share)
- Error messages

---

**Remember**: Your data security is paramount. Always use secure methods for sharing and storing backups.
