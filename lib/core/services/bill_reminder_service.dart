import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for bill calendar and cash flow forecasting
class BillReminderService {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;
  
  /// Get upcoming bills for user
  Future<List<Map<String, dynamic>>> getUpcomingBills(String userId, int daysAhead) async {
    final now = DateTime.now();
    final future = now.add(Duration(days: daysAhead));
    
    try {
      final snap = await _fire
          .collection('bills')
          .where('userId', isEqualTo: userId)
          .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(future))
          .orderBy('dueDate')
          .get();
      
      return snap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (e) {
      print('Error fetching upcoming bills: $e');
      return [];
    }
  }
  
  /// Predict cash flow for the month
  /// Shows when money comes in and goes out
  Map<String, dynamic> predictCashFlow(
    double salaryAmount,
    DateTime salaryDate,
    List<Map<String, dynamic>> bills,
  ) {
    // TODO: Calculate cash flow timeline
    final timeline = <Map<String, dynamic>>[];
    
    // Add salary
    timeline.add({
      'date': salaryDate,
      'type': 'INCOME',
      'amount': salaryAmount,
      'description': 'Salary',
    });
    
    // Add bills
    for (var bill in bills) {
      timeline.add({
        'date': bill['dueDate'],
        'type': 'EXPENSE',
        'amount': bill['amount'],
        'description': bill['title'],
      });
    }
    
    // Sort by date
    timeline.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
    
    // Calculate running balance
    double balance = 0;
    for (var item in timeline) {
      if (item['type'] == 'INCOME') {
        balance += item['amount'];
      } else {
        balance -= item['amount'];
      }
      item['balance'] = balance;
    }
    
    return {
      'timeline': timeline,
      'lowestBalance': timeline.map((item) => item['balance']).reduce((a, b) => a < b ? a : b),
      'lowestBalanceDate': timeline
          .where((item) => item['balance'] == timeline.map((i) => i['balance']).reduce((a, b) => a < b ? a : b))
          .first['date'],
    };
  }
  
  /// Low balance warning
  /// Alert user if balance will drop below threshold
  Map<String, dynamic>? getLowBalanceWarning(
    List<Map<String, dynamic>> bills,
    double currentBalance,
    double warningThreshold,
  ) {
    // Sort bills by due date
    bills.sort((a, b) => (a['dueDate'] as DateTime).compareTo(b['dueDate'] as DateTime));
    
    double runningBalance = currentBalance;
    
    for (var bill in bills) {
      runningBalance -= (bill['amount'] as double? ?? 0);
      
      if (runningBalance < warningThreshold) {
        return {
          'warning': 'Low balance alert',
          'message': 'After paying ${bill['title']} on ${bill['dueDate']}, '
              'your balance will be ₹${runningBalance.toStringAsFixed(0)}',
          'currentBalance': currentBalance,
          'projectedBalance': runningBalance,
          'billThatTriggersWarning': bill['title'],
          'daysUntilBill': (bill['dueDate'] as DateTime).difference(DateTime.now()).inDays,
        };
      }
    }
    
    return null;
  }
  
  /// Send reminder notification
  Future<void> sendBillReminder(String userId, Map<String, dynamic> bill) async {
    // TODO: Integrate with Firebase Cloud Messaging
    // Send push notification 3 days before due date
    // "₹${bill['amount']} due: ${bill['title']}"
  }
  
  /// Mark bill as paid
  Future<void> markBillAsPaid(String billId) async {
    try {
      await _fire.collection('bills').doc(billId).update({'isPaid': true});
    } catch (e) {
      print('Error marking bill as paid: $e');
    }
  }
}
