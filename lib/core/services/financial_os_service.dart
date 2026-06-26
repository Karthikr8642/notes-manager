import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/financial_os_models.dart';

/// Central service that orchestrates data collection from all sources
/// Acts as the "AI Financial Brain"
class FinancialOSService {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;
  
  /// Initialize Financial OS for a user
  /// Sets up all data source permissions and configuration
  Future<void> initializeFinancialOS(
    String userId,
    bool enableNotifications,
    bool enableEmails,
    bool enableSMS,
    bool enableCalendar,
  ) async {
    try {
      final permissions = [
        if (enableNotifications)
          DataSourcePermission(
            type: DataSourceType.notification,
            isGranted: false, // User must grant
            config: {
              'trackShopping': true,
              'trackBanking': true,
              'trackPayments': true,
            },
          ),
        if (enableEmails)
          DataSourcePermission(
            type: DataSourceType.email,
            isGranted: false,
            config: {'emailFilterPatterns': ['invoice', 'receipt', 'order', 'booking']},
          ),
        if (enableSMS)
          DataSourcePermission(
            type: DataSourceType.sms,
            isGranted: false,
            config: {'trackBankAlerts': true, 'trackUPI': true},
          ),
        if (enableCalendar)
          DataSourcePermission(
            type: DataSourceType.calendar,
            isGranted: false,
            config: {'trackEvents': ['salary', 'emi', 'bill', 'travel']},
          ),
      ];

      await _fire.collection('users').doc(userId).update({
        'financialOSConfig': {
          'permissions': permissions.map((p) => _permissionToMap(p)).toList(),
          'enabledAt': FieldValue.serverTimestamp(),
        },
      });
    } catch (e) {
      print('Error initializing Financial OS: $e');
    }
  }

  /// Process raw notification data
  Future<void> processNotification(
    String userId,
    String appName,
    String notificationText,
    DateTime receivedAt,
  ) async {
    try {
      // Store raw data
      final rawDataId = await _storeRawData(
        userId: userId,
        source: DataSourceType.notification,
        rawContent: notificationText,
        metadata: {'appName': appName},
        collectedAt: receivedAt,
      );

      // Parse notification
      final parsed = _parseNotification(appName, notificationText, receivedAt);
      
      // Store parsed transaction
      if (parsed != null) {
        await _storeParsedTransaction(userId, rawDataId, parsed);
      }
    } catch (e) {
      print('Error processing notification: $e');
    }
  }

  /// Parse notification based on app
  Map<String, dynamic>? _parseNotification(
    String appName,
    String text,
    DateTime timestamp,
  ) {
    final lower = text.toLowerCase();
    
    // Shopping apps
    if (appName.toLowerCase().contains('amazon')) {
      if (text.contains('shipped') || text.contains('order')) {
        return _extractAmazonOrder(text, timestamp);
      } else if (text.contains('price dropped')) {
        return _extractPriceAlert(text, timestamp);
      }
    }

    if (appName.toLowerCase().contains('swiggy')) {
      return _extractFoodOrder(text, timestamp, 'Swiggy');
    }

    if (appName.toLowerCase().contains('zomato')) {
      return _extractFoodOrder(text, timestamp, 'Zomato');
    }

    if (appName.toLowerCase().contains('flipkart')) {
      return _extractFlipkartNotification(text, timestamp);
    }

    // Banking apps
    if (appName.toLowerCase().contains('hdfc') ||
        appName.toLowerCase().contains('icic') ||
        appName.toLowerCase().contains('axis') ||
        appName.toLowerCase().contains('sbi')) {
      return _extractBankingAlert(text, timestamp);
    }

    // UPI payment apps
    if (appName.toLowerCase().contains('gpay') ||
        appName.toLowerCase().contains('phonepe') ||
        appName.toLowerCase().contains('paytm')) {
      return _extractUPIPayment(text, timestamp, appName);
    }

    return null;
  }

  Map<String, dynamic>? _extractAmazonOrder(String text, DateTime timestamp) {
    // Example: "Your order for Sony Headphones has been shipped."
    final priceMatch = RegExp(r'₹(\d+(?:,\d{3})*|\d+)').firstMatch(text);
    
    return {
      'merchant': 'Amazon',
      'amount': _parseAmount(priceMatch?.group(1) ?? '0'),
      'category': 'Shopping',
      'product': _extractProductName(text),
      'status': text.contains('shipped') ? 'SHIPPED' : 'ORDERED',
      'paymentMode': 'Card/UPI',
      'orderId': DateTime.now().millisecondsSinceEpoch.toString(),
    };
  }

  Map<String, dynamic>? _extractFoodOrder(
    String text,
    DateTime timestamp,
    String app,
  ) {
    // Example: "Your order worth ₹420 has been placed."
    final amountMatch = RegExp(r'₹(\d+(?:,\d{3})*|\d+)').firstMatch(text);
    
    return {
      'merchant': app,
      'amount': _parseAmount(amountMatch?.group(1) ?? '0'),
      'category': 'Food',
      'product': _extractDishName(text),
      'status': 'PLACED',
      'paymentMode': 'Card/UPI',
    };
  }

  Map<String, dynamic>? _extractBankingAlert(String text, DateTime timestamp) {
    // Example: "Rs.599 spent on AMAZON using HDFC Credit Card."
    final amountMatch = RegExp(r'Rs\.?(\d+(?:,\d{3})*|\d+)').firstMatch(text);
    final merchantMatch = RegExp(r'on\s+([A-Z0-9\s]+)\s+using').firstMatch(text);

    return {
      'merchant': merchantMatch?.group(1)?.trim() ?? 'Unknown',
      'amount': _parseAmount(amountMatch?.group(1) ?? '0'),
      'category': _categorizeMerchant(merchantMatch?.group(1) ?? ''),
      'status': 'COMPLETED',
      'paymentMode': text.contains('Credit Card')
          ? 'Credit Card'
          : text.contains('Debit Card')
              ? 'Debit Card'
              : 'Unknown',
    };
  }

  Map<String, dynamic>? _extractUPIPayment(
    String text,
    DateTime timestamp,
    String appName,
  ) {
    // Example: "₹540 paid to Swiggy"
    final amountMatch = RegExp(r'₹(\d+(?:,\d{3})*|\d+)').firstMatch(text);
    final paidToMatch = RegExp(r'paid to\s+([A-Za-z0-9\s]+)($|\.|\s)').firstMatch(text);
    final receivedMatch = RegExp(r'received from\s+([A-Za-z0-9\s]+)($|\.|\s)').firstMatch(text);

    if (paidToMatch != null) {
      return {
        'merchant': paidToMatch.group(1)?.trim() ?? 'UPI Transfer',
        'amount': _parseAmount(amountMatch?.group(1) ?? '0'),
        'category': 'Transfer Out',
        'status': 'COMPLETED',
        'paymentMode': 'UPI',
      };
    }

    if (receivedMatch != null) {
      return {
        'merchant': 'Received from ' + (receivedMatch.group(1)?.trim() ?? 'Unknown'),
        'amount': _parseAmount(amountMatch?.group(1) ?? '0'),
        'category': 'Income',
        'status': 'COMPLETED',
        'paymentMode': 'UPI',
      };
    }

    return null;
  }

  Map<String, dynamic>? _extractFlipkartNotification(String text, DateTime timestamp) {
    // Similar to Amazon
    return _extractAmazonOrder(text, timestamp)
        ?..['merchant'] = 'Flipkart';
  }

  Map<String, dynamic>? _extractPriceAlert(String text, DateTime timestamp) {
    return {
      'type': 'PRICE_ALERT',
      'description': text,
      'timestamp': timestamp,
    };
  }

  /// Process raw email data (from Gmail/Outlook)
  Future<void> processEmail(
    String userId,
    String senderEmail,
    String subject,
    String body,
    DateTime receivedAt,
  ) async {
    try {
      final rawDataId = await _storeRawData(
        userId: userId,
        source: DataSourceType.email,
        rawContent: '$subject\n$body',
        metadata: {'from': senderEmail},
        collectedAt: receivedAt,
      );

      // Parse email based on sender/subject
      final parsed = _parseEmail(senderEmail, subject, body, receivedAt);
      
      if (parsed != null) {
        await _storeParsedTransaction(userId, rawDataId, parsed);
      }
    } catch (e) {
      print('Error processing email: $e');
    }
  }

  Map<String, dynamic>? _parseEmail(
    String senderEmail,
    String subject,
    String body,
    DateTime timestamp,
  ) {
    // Amazon invoices
    if (senderEmail.contains('amazon') || subject.contains('Amazon')) {
      return _extractFromAmazonEmail(subject, body, timestamp);
    }

    // Flipkart invoices
    if (senderEmail.contains('flipkart') || subject.contains('Flipkart')) {
      return _extractFromFlipkartEmail(subject, body, timestamp);
    }

    // Food delivery receipts
    if (senderEmail.contains('swiggy') || senderEmail.contains('zomato')) {
      return _extractFromFoodEmail(senderEmail, subject, body, timestamp);
    }

    // Hotel bookings
    if (subject.contains('booking') || senderEmail.contains('booking')) {
      return _extractFromBookingEmail(subject, body, timestamp);
    }

    // Flight tickets
    if (subject.contains('ticket') || subject.contains('booking')) {
      return _extractFromFlightEmail(subject, body, timestamp);
    }

    return null;
  }

  Map<String, dynamic>? _extractFromAmazonEmail(
    String subject,
    String body,
    DateTime timestamp,
  ) {
    final amountMatch = RegExp(r'₹(\d+(?:,\d{3})*|\d+)').firstMatch(body);
    
    return {
      'merchant': 'Amazon',
      'amount': _parseAmount(amountMatch?.group(1) ?? '0'),
      'category': 'Shopping',
      'product': _extractProductFromBody(body),
      'status': 'INVOICE_RECEIVED',
      'paymentMode': 'Card/UPI',
      'gst': _extractGST(body),
    };
  }

  Map<String, dynamic>? _extractFromFlipkartEmail(
    String subject,
    String body,
    DateTime timestamp,
  ) {
    return _extractFromAmazonEmail(subject, body, timestamp)
        ?..['merchant'] = 'Flipkart';
  }

  Map<String, dynamic>? _extractFromFoodEmail(
    String senderEmail,
    String subject,
    String body,
    DateTime timestamp,
  ) {
    final merchant = senderEmail.contains('swiggy') ? 'Swiggy' : 'Zomato';
    final amountMatch = RegExp(r'₹(\d+(?:,\d{3})*|\d+)').firstMatch(body);

    return {
      'merchant': merchant,
      'amount': _parseAmount(amountMatch?.group(1) ?? '0'),
      'category': 'Food',
      'product': _extractDishFromBody(body),
      'status': 'INVOICE_RECEIVED',
      'paymentMode': 'Card/UPI',
    };
  }

  Map<String, dynamic>? _extractFromBookingEmail(
    String subject,
    String body,
    DateTime timestamp,
  ) {
    final amountMatch = RegExp(r'₹(\d+(?:,\d{3})*|\d+)').firstMatch(body);

    return {
      'merchant': 'Booking/Hotel',
      'amount': _parseAmount(amountMatch?.group(1) ?? '0'),
      'category': 'Travel',
      'product': _extractHotelName(body),
      'status': 'INVOICE_RECEIVED',
      'paymentMode': 'Card',
    };
  }

  Map<String, dynamic>? _extractFromFlightEmail(
    String subject,
    String body,
    DateTime timestamp,
  ) {
    final amountMatch = RegExp(r'₹(\d+(?:,\d{3})*|\d+)').firstMatch(body);

    return {
      'merchant': 'Flight/Airlines',
      'amount': _parseAmount(amountMatch?.group(1) ?? '0'),
      'category': 'Travel',
      'product': _extractFlightDetails(body),
      'status': 'INVOICE_RECEIVED',
      'paymentMode': 'Card',
    };
  }

  /// Process SMS data (banking alerts)
  Future<void> processSMS(
    String userId,
    String senderNumber,
    String messageText,
    DateTime receivedAt,
  ) async {
    try {
      final rawDataId = await _storeRawData(
        userId: userId,
        source: DataSourceType.sms,
        rawContent: messageText,
        metadata: {'from': senderNumber},
        collectedAt: receivedAt,
      );

      final parsed = _parseSMS(senderNumber, messageText, receivedAt);
      
      if (parsed != null) {
        await _storeParsedTransaction(userId, rawDataId, parsed);
      }
    } catch (e) {
      print('Error processing SMS: $e');
    }
  }

  Map<String, dynamic>? _parseSMS(
    String senderNumber,
    String text,
    DateTime timestamp,
  ) {
    // Bank SMS: "Rs.599 spent on AMAZON using HDFC Credit Card."
    final amountMatch = RegExp(r'Rs\.?(\d+(?:,\d{3})*|\d+)').firstMatch(text);
    if (amountMatch == null) return null;

    final merchantMatch = RegExp(r'on\s+([A-Z0-9\s]+)\s+(?:using|via)').firstMatch(text);
    final cardMatch = RegExp(r'(?:using|via)\s+(\w+)').firstMatch(text);

    return {
      'merchant': merchantMatch?.group(1)?.trim() ?? 'Unknown',
      'amount': _parseAmount(amountMatch.group(1)),
      'category': _categorizeMerchant(merchantMatch?.group(1) ?? ''),
      'status': 'COMPLETED',
      'paymentMode': cardMatch?.group(1) ?? 'Unknown',
      'source': 'SMS',
    };
  }

  /// Store raw data before parsing
  Future<String> _storeRawData({
    required String userId,
    required DataSourceType source,
    required String rawContent,
    required DateTime collectedAt,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final doc = await _fire.collection('raw_financial_data').add({
        'userId': userId,
        'source': source.toString(),
        'rawContent': rawContent,
        'metadata': metadata ?? {},
        'collectedAt': Timestamp.fromDate(collectedAt),
        'isParsed': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e) {
      print('Error storing raw data: $e');
      return '';
    }
  }

  /// Store parsed transaction
  Future<void> _storeParsedTransaction(
    String userId,
    String rawDataId,
    Map<String, dynamic> parsed,
  ) async {
    try {
      await _fire.collection('auto_parsed_transactions').add({
        'userId': userId,
        'rawDataId': rawDataId,
        'merchant': parsed['merchant'],
        'amount': parsed['amount'],
        'category': parsed['category'],
        'status': parsed['status'] ?? 'PENDING',
        'paymentMode': parsed['paymentMode'],
        'product': parsed['product'],
        'requiresReview': (parsed as dynamic)['confidence'] ?? 100 < 80,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Mark raw data as parsed
      await _fire.collection('raw_financial_data').doc(rawDataId).update({
        'isParsed': true,
      });
    } catch (e) {
      print('Error storing parsed transaction: $e');
    }
  }

  // Helper methods
  double _parseAmount(String? amountStr) {
    if (amountStr == null) return 0;
    return double.tryParse(amountStr.replaceAll(',', '')) ?? 0;
  }

  String _categorizeMerchant(String merchant) {
    final lower = merchant.toLowerCase();
    
    if (lower.contains('amazon') || lower.contains('flipkart') || lower.contains('myntra')) {
      return 'Shopping';
    }
    if (lower.contains('swiggy') || lower.contains('zomato') || lower.contains('food')) {
      return 'Food';
    }
    if (lower.contains('uber') || lower.contains('ola')) {
      return 'Travel';
    }
    if (lower.contains('pharmacy') || lower.contains('medplus') || lower.contains('doctor')) {
      return 'Medical';
    }
    if (lower.contains('netflix') || lower.contains('spotify') || lower.contains('amazon prime')) {
      return 'Entertainment';
    }
    
    return 'Others';
  }

  String _extractProductName(String text) => text.split(' ').take(3).join(' ');
  String _extractDishName(String text) => text.split(' ').take(2).join(' ');
  String _extractProductFromBody(String body) {
    final match = RegExp(r'Product:\s*([^\n]+)').firstMatch(body);
    return match?.group(1) ?? 'Item';
  }

  String _extractDishFromBody(String body) {
    final match = RegExp(r'(?:ordered|items?)[:\s]*([^\n]+)').firstMatch(body);
    return match?.group(1) ?? 'Food';
  }

  String _extractHotelName(String body) {
    final match = RegExp(r'(?:hotel|property)[:\s]*([^\n]+)').firstMatch(body);
    return match?.group(1) ?? 'Hotel';
  }

  String _extractFlightDetails(String body) {
    final match = RegExp(r'(?:flight|route)[:\s]*([^\n]+)').firstMatch(body);
    return match?.group(1) ?? 'Flight Ticket';
  }

  double _extractGST(String body) {
    final match = RegExp(r'GST[:\s]*₹?(\d+(?:\.\d{2})?)').firstMatch(body);
    return double.tryParse(match?.group(1) ?? '0') ?? 0;
  }

  Map<String, dynamic> _permissionToMap(DataSourcePermission p) {
    return {
      'type': p.type.toString(),
      'isGranted': p.isGranted,
      'grantedAt': p.grantedAt != null ? Timestamp.fromDate(p.grantedAt!) : null,
      'config': p.config,
    };
  }
}
