# Katha Ledger - Feature Documentation

Complete feature list and usage guide for Katha Ledger application.

## Table of Contents
1. [Authentication Features](#authentication-features)
2. [Customer Management](#customer-management)
3. [Transaction Management](#transaction-management)
4. [Reminders & Notifications](#reminders--notifications)
5. [Reports & Analytics](#reports--analytics)
6. [Data Management](#data-management)
7. [Settings & Customization](#settings--customization)
8. [Security Features](#security-features)

---

## Authentication Features

### 1. Email/Password Authentication
- **Sign Up**: Create account with email and password
- **Login**: Secure login with credentials
- **Password Reset**: Email-based password recovery
- **Email Verification**: Verify email address

**Usage**:
```
1. Open app → Sign Up
2. Enter name, email, password
3. Verify email (check inbox)
4. Login with credentials
```

### 2. Phone Number Authentication
- **OTP Login**: Login using phone number
- **SMS Verification**: Receive OTP via SMS
- **International Support**: Works with country codes

**Usage**:
```
1. Login Screen → Login with Phone
2. Enter phone number (+91XXXXXXXXXX)
3. Receive OTP via SMS
4. Enter OTP to login
```

### 3. PIN Authentication
- **4-Digit PIN**: Quick access with PIN
- **Secure Storage**: PIN stored securely
- **PIN Reset**: Reset via email/phone

**Usage**:
```
1. Settings → Security → Set PIN
2. Enter 4-digit PIN
3. Confirm PIN
4. Use PIN for quick login
```

### 4. Biometric Authentication
- **Fingerprint**: Use fingerprint sensor
- **Face ID**: Use facial recognition (iOS)
- **Quick Access**: Fast and secure

**Usage**:
```
1. Settings → Security → Biometric Authentication
2. Enable biometric
3. Authenticate with fingerprint/face
4. Use for app access
```

---

## Customer Management

### 1. Add Customer
- **Basic Info**: Name, phone, email
- **Address**: Store customer address
- **Notes**: Add custom notes
- **Photo**: Customer profile picture

**Fields**:
- Name (required)
- Phone Number (optional)
- Email (optional)
- Address (optional)
- Notes (optional)

### 2. Edit Customer
- Update customer information
- Modify contact details
- Change notes

### 3. Delete Customer
- Soft delete (mark inactive)
- Preserve transaction history
- Can be restored

### 4. Search Customers
- Search by name
- Search by phone number
- Search by email
- Real-time filtering

### 5. Sort Customers
- **By Name**: Alphabetical order
- **By Balance**: Highest to lowest
- **By Date**: Recently added first
- **Ascending/Descending**: Toggle sort order

### 6. Customer Details View
- **Balance Summary**: Current balance
- **Transaction History**: All transactions
- **Quick Actions**: 
  - Add transaction
  - Send reminder
  - Edit details
  - Delete customer

---

## Transaction Management

### 1. Add Transaction

#### Credit Transaction (You will get)
- Customer owes you money
- Increases customer balance
- Shows in green

#### Debit Transaction (You will give)
- You owe customer money
- Decreases customer balance
- Shows in red

**Fields**:
- Transaction Type (Credit/Debit)
- Customer (required)
- Amount (required)
- Date (default: today)
- Payment Mode (Cash, UPI, Card, etc.)
- Notes (optional)
- Attachments (optional)

### 2. Edit Transaction
- Modify transaction details
- Update amount
- Change date
- Edit notes

### 3. Delete Transaction
- Remove transaction
- Auto-update customer balance
- Cannot be undone

### 4. Transaction Attachments
- **Camera**: Capture receipt photo
- **Gallery**: Select from photos
- **Multiple Files**: Attach multiple images
- **View**: View attached receipts

### 5. Payment Modes
- Cash
- UPI
- Card
- Bank Transfer
- Cheque
- Other

### 6. Transaction Filters
- **Date Range**: Filter by period
- **Customer**: View specific customer
- **Type**: Credit or Debit only
- **Amount Range**: Min/max amount

---

## Reminders & Notifications

### 1. Payment Reminders
- **Automatic**: Based on due date
- **Manual**: Send anytime
- **Recurring**: Weekly/monthly reminders

### 2. Reminder Channels

#### WhatsApp
- Send via WhatsApp
- Pre-filled message
- Direct link to chat

#### SMS
- Send text message
- Custom message template
- Requires SMS permission

#### Push Notification
- In-app notification
- Local notification
- Scheduled delivery

### 3. Reminder Templates
```
Default Template:
"Hello [Customer Name],
This is a friendly reminder about your pending payment of ₹[Amount].
Please make the payment at your earliest convenience.
Thank you!"
```

### 4. Due Date Alerts
- Automatic alerts before due date
- Configurable alert timing
- Multiple reminder support

---

## Reports & Analytics

### 1. Transaction Summary
- **Total Credit**: Money you will receive
- **Total Debit**: Money you will give
- **Net Balance**: Overall position

### 2. Period Reports
- **Today**: Today's transactions
- **This Week**: Last 7 days
- **This Month**: Current month
- **This Year**: Current year
- **Custom**: Select date range

### 3. Customer Balance Report
- All customers with balances
- Sorted by amount
- Color-coded (green/red)
- Quick overview

### 4. Top Customers
- Customers with highest balances
- Top 10 list
- Quick access to details

### 5. Export Options

#### PDF Export
- Professional format
- Includes summary
- Customer-wise breakdown
- Date range header
- Print-ready

#### Excel Export (Coming Soon)
- Spreadsheet format
- Detailed data
- Formulas included
- Easy analysis

#### Share Report
- Share via any app
- Text summary
- Quick sharing

---

## Data Management

### 1. Local Storage
- **SQLite Database**: Fast local storage
- **Encrypted**: AES-256 encryption
- **Offline-First**: Works without internet
- **Auto-Save**: Automatic data saving

### 2. Backup

#### Create Backup
```
Settings → Backup Data
→ Choose location
→ Save as JSON file
→ Encrypted backup created
```

**Backup Contains**:
- All customers
- All transactions
- User preferences
- Export timestamp

#### Restore Backup
```
Settings → Restore Data
→ Select backup file
→ Confirm restoration
→ Data restored
```

**⚠️ Warning**: Restores will replace existing data!

### 3. Cloud Sync (Optional)

#### Firebase Sync
- Automatic sync when online
- Real-time updates
- Multi-device support
- Conflict resolution

#### Enable Cloud Sync
```
1. Login with Firebase account
2. Data syncs automatically
3. Access from any device
```

### 4. Share Data

#### Share Backup File
```
Settings → Share Data
→ Creates encrypted backup
→ Share via any app
→ Recipient can restore
```

#### Secure Sharing
- Encrypted file
- Password protection (optional)
- Time-limited links (future)

---

## Settings & Customization

### 1. Appearance

#### Theme
- **Light Mode**: Bright theme
- **Dark Mode**: Dark theme
- **System**: Follow device setting

#### Language
- English
- Hindi (हिंदी)
- Tamil (தமிழ்)
- Telugu (తెలుగు)
- Kannada (ಕನ್ನಡ)
- Malayalam (മലയാളം)

### 2. Security Settings
- Set/Change PIN
- Enable/Disable Biometric
- Auto-lock timeout
- Require auth on startup

### 3. Notification Settings
- Enable/Disable notifications
- Notification sound
- Vibration
- Reminder frequency

### 4. Data Settings
- Auto-backup frequency
- Cloud sync toggle
- Storage location
- Clear cache

### 5. Account Settings
- Edit profile
- Change password
- Update phone number
- Delete account

### 6. About
- App version
- Privacy policy
- Terms of service
- Contact support

---

## Security Features

### 1. Data Encryption
- **AES-256**: Military-grade encryption
- **Local Data**: All data encrypted at rest
- **Backups**: Encrypted backup files
- **Secure Keys**: Platform-specific key storage

### 2. Authentication Security
- **Password Hashing**: SHA-256 hashing
- **PIN Protection**: Secure PIN storage
- **Biometric**: Hardware-backed biometric
- **Session Management**: Auto-logout

### 3. Network Security
- **HTTPS Only**: Encrypted communication
- **Certificate Pinning**: Prevent MITM attacks
- **Secure APIs**: Firebase security rules

### 4. Privacy Protection
- **No Tracking**: No user tracking
- **Local-First**: Data stored locally
- **Optional Cloud**: Cloud sync is optional
- **Data Ownership**: You own your data

### 5. Permissions
- **Minimal Permissions**: Only required permissions
- **Runtime Permissions**: Ask when needed
- **Transparent**: Clear permission explanations

---

## Advanced Features

### 1. Offline Mode
- Full functionality offline
- Auto-sync when online
- Conflict resolution
- Queue pending operations

### 2. Multi-Currency (Future)
- Support multiple currencies
- Exchange rate conversion
- Currency-wise reports

### 3. Business Profiles (Future)
- Multiple business support
- Switch between businesses
- Separate data per business

### 4. Invoice Generation (Future)
- Create professional invoices
- PDF export
- Email invoices
- Payment tracking

### 5. Expense Tracking (Future)
- Track business expenses
- Categorize expenses
- Expense reports
- Tax calculations

### 6. Team Collaboration (Future)
- Multi-user access
- Role-based permissions
- Activity logs
- Real-time collaboration

---

## Tips & Best Practices

### For Better Organization
1. **Consistent Naming**: Use full names for customers
2. **Add Phone Numbers**: Enable WhatsApp reminders
3. **Use Notes**: Add context to transactions
4. **Attach Receipts**: Photo evidence of transactions
5. **Regular Backups**: Backup weekly

### For Accurate Records
1. **Enter Immediately**: Add transactions right away
2. **Verify Amounts**: Double-check amounts
3. **Use Payment Modes**: Track payment methods
4. **Add Dates**: Use correct transaction dates
5. **Review Regularly**: Check balances weekly

### For Security
1. **Enable PIN**: Quick secure access
2. **Use Biometric**: Fastest authentication
3. **Regular Backups**: Protect against data loss
4. **Secure Backups**: Store backups safely
5. **Strong Password**: Use complex passwords

### For Efficiency
1. **Use Search**: Find customers quickly
2. **Sort by Balance**: Prioritize collections
3. **Set Reminders**: Automate follow-ups
4. **Use Reports**: Track business health
5. **WhatsApp Integration**: Quick communication

---

## Keyboard Shortcuts (Future)

### Desktop/Web Version
- `Ctrl+N`: New customer
- `Ctrl+T`: New transaction
- `Ctrl+F`: Search
- `Ctrl+B`: Backup
- `Ctrl+R`: Reports

---

## Troubleshooting Common Issues

### Transaction Not Showing
- Pull down to refresh
- Check date filters
- Verify customer selection

### Balance Incorrect
- Review all transactions
- Check for duplicates
- Verify transaction types

### Reminder Not Sent
- Check phone number
- Verify WhatsApp installed
- Check permissions

### Backup Failed
- Check storage space
- Verify permissions
- Try different location

### Sync Not Working
- Check internet connection
- Verify login status
- Force refresh

---

**For more help, refer to**:
- README.md - General information
- SETUP_GUIDE.md - Installation guide
- DATA_SHARING_GUIDE.md - Data sharing details
