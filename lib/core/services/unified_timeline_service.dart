import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for unified financial timeline
/// Combines all data sources into a single chronological view
class UnifiedTimelineService {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;

  /// Get unified timeline for user
  /// Combines: expenses, income, alerts, price drops, bill reminders
  Future<List<Map<String, dynamic>>> getUnifiedTimeline(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final events = <Map<String, dynamic>>[];

      // Get expenses
      final expenseSnap = await _fire
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      for (var doc in expenseSnap.docs) {
        final data = doc.data();
        events.add({
          'id': doc.id,
          'timestamp': (data['date'] as Timestamp).toDate(),
          'type': 'EXPENSE',
          'title': '${data['merchant']} • ${data['category']}',
          'amount': data['amount'],
          'icon': _getCategoryIcon(data['category']),
          'color': _getCategoryColor(data['category']),
          'source': 'expense',
        });
      }

      // Get auto-parsed transactions
      final autoParsedSnap = await _fire
          .collection('auto_parsed_transactions')
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      for (var doc in autoParsedSnap.docs) {
        final data = doc.data();
        if (data['status'] != 'MANUAL_REVIEW') {
          events.add({
            'id': doc.id,
            'timestamp': (data['createdAt'] as Timestamp).toDate(),
            'type': 'AUTO_TRANSACTION',
            'title': '${data['merchant']}',
            'amount': data['amount'],
            'icon': 'receipt',
            'color': '#FF6B6B',
            'source': data['source'] ?? 'auto',
            'requiresReview': data['requiresReview'] ?? false,
          });
        }
      }

      // Get bills
      final billSnap = await _fire
          .collection('bills')
          .where('userId', isEqualTo: userId)
          .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      for (var doc in billSnap.docs) {
        final data = doc.data();
        events.add({
          'id': doc.id,
          'timestamp': (data['dueDate'] as Timestamp).toDate(),
          'type': 'BILL_DUE',
          'title': 'Bill due: ${data['title']}',
          'amount': data['amount'],
          'icon': 'receipt_long',
          'color': '#FFA500',
        });
      }

      // Get subscriptions
      final subSnap = await _fire
          .collection('subscriptions')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      for (var doc in subSnap.docs) {
        final data = doc.data();
        if (data['nextBillingDate'] != null) {
          final billingDate = (data['nextBillingDate'] as Timestamp).toDate();
          if (!billingDate.isBefore(startDate) && !billingDate.isAfter(endDate)) {
            events.add({
              'id': doc.id,
              'timestamp': billingDate,
              'type': 'SUBSCRIPTION_BILLING',
              'title': '${data['name']} renewal',
              'amount': data['monthlyAmount'],
              'icon': 'repeat',
              'color': '#9C27B0',
            });
          }
        }
      }

      // Sort by timestamp descending
      events.sort((b, a) => (a['timestamp'] as DateTime).compareTo(b['timestamp'] as DateTime));

      return events;
    } catch (e) {
      print('Error fetching unified timeline: $e');
      return [];
    }
  }

  /// Get daily summary
  /// Shows spending, income, and insights for a specific day
  Future<Map<String, dynamic>> getDailySummary(String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      // Get expenses for day
      final expenseSnap = await _fire
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      double totalSpend = 0;
      final spendByCategory = <String, double>{};

      for (var doc in expenseSnap.docs) {
        final amount = doc.data()['amount'] as double? ?? 0;
        final category = doc.data()['category'] as String? ?? 'Others';
        totalSpend += amount;
        spendByCategory[category] = (spendByCategory[category] ?? 0) + amount;
      }

      // Get auto-parsed transactions (not yet converted to expenses)
      final autoParsedSnap = await _fire
          .collection('auto_parsed_transactions')
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      for (var doc in autoParsedSnap.docs) {
        final amount = doc.data()['amount'] as double? ?? 0;
        final category = doc.data()['category'] as String? ?? 'Others';
        totalSpend += amount;
        spendByCategory[category] = (spendByCategory[category] ?? 0) + amount;
      }

      return {
        'date': date,
        'totalSpend': totalSpend,
        'spendByCategory': spendByCategory,
        'transactionCount': expenseSnap.docs.length + autoParsedSnap.docs.length,
        'primaryCategory': spendByCategory.isEmpty
            ? 'None'
            : spendByCategory.entries.reduce((a, b) => a.value > b.value ? a : b).key,
      };
    } catch (e) {
      print('Error getting daily summary: $e');
      return {};
    }
  }

  /// Get week overview
  Future<Map<String, dynamic>> getWeekOverview(String userId, DateTime startOfWeek) async {
    final events = <Map<String, dynamic>>[];
    double weekTotal = 0;

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final summary = await getDailySummary(userId, date);
      
      final dailyTotal = summary['totalSpend'] as double? ?? 0;
      weekTotal += dailyTotal;
      
      if (dailyTotal > 0) {
        events.add({
          'date': date,
          'spend': dailyTotal,
          'categories': summary['spendByCategory'],
        });
      }
    }

    return {
      'weekStart': startOfWeek,
      'totalSpend': weekTotal,
      'averagePerDay': weekTotal / 7,
      'days': events,
    };
  }

  // Helper methods
  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return 'restaurant';
      case 'shopping':
        return 'shopping_bag';
      case 'travel':
        return 'flight';
      case 'medical':
        return 'health_and_safety';
      case 'bills':
        return 'receipt_long';
      case 'entertainment':
        return 'movie';
      case 'fuel':
        return 'local_gas_station';
      default:
        return 'attach_money';
    }
  }

  String _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return '#FF6B6B';
      case 'shopping':
        return '#4ECDC4';
      case 'travel':
        return '#45B7D1';
      case 'medical':
        return '#96CEB4';
      case 'entertainment':
        return '#FFEAA7';
      default:
        return '#95E1D3';
    }
  }
}
