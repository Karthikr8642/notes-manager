# AI Financial OS - Implementation Guide

## Quick Start: Week 1 Priority

### 🎯 MVP Scope (Next 2 Weeks)

Build a foundation that proves the concept:

1. **SMS Parser** (Easiest, Highest Return)
   - Banks already send ₹XXX transaction alerts
   - ~1000s of messages per user per month
   - Regex-based extraction (no ML needed)
   - 99% accuracy possible

2. **Gmail Parser** (Medium Effort, High Value)
   - Order confirmations are structured
   - User already has emails
   - OAuth setup (once) = recurring benefit
   - Can parse 100s of invoices

3. **Notification Parser** (Harder, Required for Mobile)
   - Requires Android service integration
   - But captures real-time transactions
   - Future-proofs the architecture

---

## Phase 2.1: SMS Parser (Start Here)

**Estimated Effort:** 3-4 days

### Step 1: Request Permission in Android

**File:** `android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.READ_SMS" />
```

**File:** `lib/core/services/financial_os_permissions_service.dart`

```dart
Future<bool> requestSMSAccess() async {
  if (Platform.isAndroid) {
    final status = await Permission.sms.request();
    return status.isGranted;
  }
  return false;
}
```

### Step 2: Read SMS Messages

**Package to add in pubspec.yaml:**

```yaml
dependencies:
  flutter_sms: ^0.1.0 # or similar SMS reading package
```

**Service:** `lib/core/services/financial_os_service.dart`

```dart
Future<void> readAndParseBankingSMS(String userId) async {
  try {
    // Get SMS messages (simplified example)
    final messages = await getSMSMessages(
      filter: (sms) => _isBankingMessage(sms.sender),
      limit: 100,
    );

    for (var message in messages) {
      await processSMS(
        userId,
        message.sender,
        message.body,
        message.timestamp,
      );
    }
  } catch (e) {
    print('Error reading SMS: $e');
  }
}

bool _isBankingMessage(String sender) {
  final bankPrefixes = ['HDFC', 'ICICI', 'SBI', 'AXIS', 'KOTAK'];
  return bankPrefixes.any((prefix) => sender.contains(prefix));
}
```

### Step 3: Parse Banking SMS

**Regex Patterns:**

```dart
// Pattern 1: HDFC/ICICI format
// "Rs.599 spent on AMAZON using HDFC Credit Card."
final spendPattern = RegExp(
  r'[Rr]s\.?\s*(\d+(?:,\d{3})*|\d+)\s+spent\s+on\s+([A-Z0-9\s]+?)\s+using\s+([A-Za-z\s]+?)(?:\.|$)'
);

// Pattern 2: Balance update
// "Available Balance: ₹12,450"
final balancePattern = RegExp(
  r'(?:Available\s+)?[Bb]alance\s*[:=]\s*[₹R]\.?\s*(\d+(?:,\d{3})*|\d+)'
);

// Pattern 3: UPI transfer
// "₹540 paid to Swiggy"
final upiPattern = RegExp(
  r'[₹R]s\.?\s*(\d+(?:,\d{3})*|\d+)\s+paid\s+to\s+([A-Za-z0-9\s]+)(?:\.|$)'
);
```

### Step 4: Store Parsed Transactions

**In Firestore:**

```
raw_financial_data/
  ├── docId/
      ├── userId: "user123"
      ├── source: "sms"
      ├── rawContent: "Rs.599 spent on AMAZON..."
      ├── metadata: { from: "HDFC" }
      ├── collectedAt: Timestamp
      └── isParsed: false

auto_parsed_transactions/
  ├── docId/
      ├── userId: "user123"
      ├── raw DataId: "ref_to_raw_data"
      ├── merchant: "Amazon"
      ├── amount: 599
      ├── category: "Shopping"
      ├── paymentMode: "HDFC Credit Card"
      ├── status: "COMPLETED"
      ├── confidence: 98
      ├── requiresReview: false
      └── createdAt: Timestamp
```

### Step 5: Convert to Expense (Auto-Create)

```dart
Future<void> autoCreateExpenseIfHighConfidence(
  String userId,
  Map<String, dynamic> parsedTransaction,
) async {
  final confidence = parsedTransaction['confidence'] as int;

  if (confidence >= 80) {
    // Auto-create expense
    await _fire.collection('expenses').add({
      'userId': userId,
      'merchant': parsedTransaction['merchant'],
      'amount': parsedTransaction['amount'],
      'category': parsedTransaction['category'],
      'date': Timestamp.now(),
      'paymentMode': parsedTransaction['paymentMode'],
      'autoCreated': true,
      'source': 'sms',
      'rawTransactionId': parsedTransaction['id'],
      'createdAt': FieldValue.serverTimestamp(),
    });
  } else {
    // Queue for user review
    await _fire.collection('pending_review').add({
      'userId': userId,
      'parsedTransaction': parsedTransaction,
      'reason': 'confidence_below_threshold',
      'status': 'PENDING',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
```

### Step 6: Test with Real SMS

**Test Cases:**

1. **Standard spend:** "Rs.599 spent on AMAZON using HDFC Credit Card at 15:30."
   - Extract: merchant=Amazon, amount=599
   - Confidence: 98%

2. **With balance:** "Rs.1200 spent on ZOMATO using SBI Debit Card. Available Balance: ₹45,300"
   - Extract: merchant=Zomato, amount=1200, balance=45300
   - Confidence: 99%

3. **UPI transfer:** "₹540 paid to Swiggy. Available Balance: ₹10,230"
   - Extract: merchant=Swiggy, amount=540
   - Confidence: 98%

---

## Phase 2.2: Gmail OAuth integration

**Estimated Effort:** 4-5 days

### Step 1: Set Up Google OAuth

**In google-services.json:**
Already configured from Firebase setup. Check that `gmail_auth_scope` is included.

**Add to pubspec.yaml:**

```yaml
dependencies:
  google_sign_in: ^6.1.0
  googleapis: ^11.0.0
  extension_google_cloud_messaging_firebase: ^0.0.1
```

### Step 2: Request Gmail Permission

```dart
Future<void> initializeGmailAccess(String userId) async {
  try {
    final googleSignIn = GoogleSignIn(
      scopes: ['https://www.googleapis.com/auth/gmail.readonly'],
    );

    // User signs in (if not already)
    final account = await googleSignIn.signIn();
    if (account != null) {
      final auth = await account.authentication;

      // Save token for Gmail API calls
      await _fire.collection('users').doc(userId).update({
        'gmailAccessToken': auth.accessToken,
        'gmailRefreshToken': auth.idToken,
        'gmailAccessGrantedAt': FieldValue.serverTimestamp(),
      });
    }
  } catch (e) {
    print('Error initializing Gmail: $e');
  }
}
```

### Step 3: Fetch Invoices from Gmail

```dart
Future<void> fetchInvoicesFromGmail(String userId, String accessToken) async {
  try {
    final gmail = GmailAPI(
      client: await googleSignIn.authenticatedClient,
    );

    // Search for invoice emails
    final invoiceEmails = await gmail.users.messages.list(
      'me',
      q: 'subject:(invoice OR receipt OR order) from:(amazon.com OR flipkart.com OR zomato.in)',
      maxResults: 100,
    );

    for (var message in invoiceEmails.messages ?? []) {
      final fullMessage = await gmail.users.messages.get(
        'me',
        message.id!,
        format: 'full',
      );

      // Extract email data
      final subject = _getHeader(fullMessage, 'Subject');
      final from = _getHeader(fullMessage, 'From');
      final body = fullMessage.parts?.first.body?.data ?? '';

      // Process email
      await processEmail(userId, from, subject, body, DateTime.now());
    }
  } catch (e) {
    print('Error fetching Gmail: $e');
  }
}

String _getHeader(Message message, String name) {
  return message.payload?.headers
      ?.firstWhere((h) => h.name == name, orElse: () => Header(name: '', value: ''))
      .value ?? '';
}
```

### Step 4: Parse Email Content

```dart
Map<String, dynamic>? _parseAmazonEmail(String subject, String body) {
  // Extract from email body
  final amountMatch = RegExp(r'[₹Rs\.]*\s*(\d+(?:,\d{3})*(?:\.\d{2})?)').firstMatch(body);
  final gstMatch = RegExp(r'GST[:\s]*[₹Rs\.]*\s*(\d+(?:\.\d{2})?)').firstMatch(body);

  return {
    'source': 'email',
    'merchant': 'Amazon',
    'amount': _parseAmount(amountMatch?.group(1)),
    'gst': _parseAmount(gstMatch?.group(1)),
    'category': 'Shopping',
    'status': 'INVOICE_RECEIVED',
    'confidence': 95,
  };
}
```

### Step 5: Show in Timeline

Create a `PendingTransactionsPage` to show auto-detected transactions awaiting approval:

```dart
class PendingTransactionsPage extends StatefulWidget {
  @override
  State<PendingTransactionsPage> createState() => _PendingTransactionsPageState();
}

class _PendingTransactionsPageState extends State<PendingTransactionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auto-Detected Transactions')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fire
            .collection('auto_parsed_transactions')
            .where('userId', isEqualTo: userId)
            .where('status', isEqualTo: 'PENDING')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          final transactions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final txn = transactions[index].data() as Map;

              return Card(
                child: ListTile(
                  title: Text('${txn['merchant']} • ${txn['category']}'),
                  subtitle: Text('₹${txn['amount']} • ${txn['source']}'),
                  trailing: PopupMenuButton(
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        child: const Text('Approve'),
                        onTap: () => _approveTransaction(transactions[index].id, txn),
                      ),
                      PopupMenuItem(
                        child: const Text('Edit'),
                        onTap: () => _editTransaction(txn),
                      ),
                      PopupMenuItem(
                        child: const Text('Reject'),
                        onTap: () => _rejectTransaction(transactions[index].id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _approveTransaction(String txnId, Map txn) async {
    // Create expense from auto-parsed transaction
    await _fire.collection('expenses').add({
      'userId': userId,
      'merchant': txn['merchant'],
      'amount': txn['amount'],
      'category': txn['category'],
      'date': Timestamp.now(),
      'paymentMode': txn['paymentMode'],
      'note': 'Auto-detected from ${txn['source']}',
      'autoCreatedFrom': txnId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update status
    await _fire.collection('auto_parsed_transactions').doc(txnId).update({
      'status': 'APPROVED',
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }
}
```

---

## Phase 2.3: Notification Listener (Mobile Only)

**Estimated Effort:** 5-7 days

### Step 1: Implement Notification Listener Service

**File:** `android/app/src/main/kotlin/NotificationListenerService.kt`

```kotlin
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

class FinancialOSNotificationListener : NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val notification = sbn.notification
        val notificationText = notification?.extras?.getString("android.text")
        val appName = sbn.packageName

        // Send to Flutter via MethodChannel
        val bundle = Bundle().apply {
            putString("app", appName)
            putString("text", notificationText)
            putLong("time", sbn.postTime)
        }

        // Communicate with Flutter
        sendToFlutter(bundle)
    }

    private fun sendToFlutter(data: Bundle) {
        // Use MethodChannel to send data to Dart
    }
}
```

### Step 2: Receive in Flutter

**File:** `lib/core/services/notification_listener_service.dart`

```dart
class NotificationListenerService {
  static const platform = MethodChannel('com.example.wallet/notifications');

  void initializeListeners() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onNotification') {
        final app = call.arguments['app'];
        final text = call.arguments['text'];

        await _processNotification(app, text);
      }
    });
  }

  Future<void> _processNotification(String appName, String text) async {
    final parsed = _parseNotification(appName, text);
    if (parsed != null) {
      // Store and process
      await storeProcessedNotification(parsed);
    }
  }
}
```

---

## 📊 Metrics to Track

Once Phase 2 is live:

```dart
class FinancialOSMetrics {
  // Data collection metrics
  double autoCreationRate;      // % of expenses auto-created
  double parsingAccuracy;        // % of correct extractions
  double confidenceScore;        // Avg confidence of parsed transactions
  int transactionsPerDay;        // Avg transactions tracked

  // User metrics
  double userRetention30d;       // % of users active after 30 days
  double dataAcceptanceRate;     // % of auto-created expenses user approves
  int manualsPerDay;             // Manual entries (should decrease)

  // System metrics
  double latency;                // Time from transaction → app
  int errorRate;                 // % of parsing failures
  double storagePerUser;         // GB of data per user
}
```

---

## 🚨 Common Pitfalls

### 1. Permission Exhaustion

Don't request all permissions at once. Ask for SMS first, Gmail second, notifications last.

```dart
// ❌ DON'T:
requestAllPermissionsAtOnce();

// ✅ DO:
await requestSMSPermission();
await showExplanation('Email access enables invoice parsing');
await requestGmailPermission();
```

### 2. Privacy Concerns

Be transparent about what you read:

```dart
// ❌ DON'T: "We need access to your emails"

// ✅ DO: "We read ONLY invoices and receipts.
//   Your personal emails stay private."
```

### 3. High False Positives

Start conservative. Use high confidence thresholds (>85%) initially.

```dart
// ❌ DON'T: Auto-create everything
if (confidence > 50) createExpense();

// ✅ DO: High bar for auto-create, manual review for medium
if (confidence >= 85) createExpense();
else if (confidence >= 70) queueForReview();
```

### 4. Data Staleness

Don't parse old emails. Focus on recent transactions.

```dart
// ✅ DO: Only fetch last 30 days
final invoiceEmails = await gmail.users.messages.list(
  'me',
  q: 'subject:(invoice) before:${Date.now()} after:${Date.now() - 30days}',
);
```

---

## 🎯 Success Criteria for Phase 2

- [ ] SMS parser working with >95% accuracy
- [ ] Gmail OAuth integration functional
- [ ] Auto-created expenses appearing in dashboard
- [ ] Pending review queue operational
- [ ] Unified timeline combining all sources
- [ ] <500ms latency from notification → app
- [ ] > 80% user approval rate for auto-created transactions
- [ ] <10% error rate for parsing

---

## 📚 Resources

- Firebase Firestore Docs: https://firebase.google.com/docs/firestore
- Gmail API: https://developers.google.com/gmail/api
- Flutter Notifications: https://pub.dev/packages/flutter_local_notifications
- Regular Expression Tester: https://regexr.com/

---

## 🎓 Next Phase

Once Phase 2 is solid:
→ Phase 3: Shopping Intelligence & Price Tracking
→ Phase 4: Subscription Detection
→ Phase 5: Family Expense Splitting
→ Phase 6: AI Chat Interface
→ And beyond...
