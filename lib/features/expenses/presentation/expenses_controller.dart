import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../domain/entities/expense.dart';

class ExpensesController extends GetxController {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;

  final expenses = <Expense>[].obs;
  final loading = false.obs;
  final error = RxnString();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  static const List<String> categories = [
    'Food',
    'Shopping',
    'Travel',
    'Medical',
    'Bills',
    'Entertainment',
    'Recharge',
    'Investment',
    'Others',
  ];

  void subscribe(String uid) {
    _sub?.cancel();
    _sub = _fire
        .collection('expenses')
        .where('userId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots()
        .listen(
      (snap) {
        expenses.value = snap.docs.map(Expense.fromSnapshot).toList();
      },
      onError: (e) {
        error.value = e.toString();
      },
    );
  }

  Future<void> addExpense({
    required double amount,
    required String merchant,
    required String category,
    required DateTime date,
    required String paymentMode,
    required String note,
    required String uid,
  }) async {
    loading.value = true;
    error.value = null;

    try {
      await _fire.collection('expenses').add({
        'amount': amount,
        'merchant': merchant,
        'category': category,
        'date': Timestamp.fromDate(date),
        'paymentMode': paymentMode,
        'note': note,
        'userId': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<void> updateExpense({
    required String id,
    required double amount,
    required String merchant,
    required String category,
    required DateTime date,
    required String paymentMode,
    required String note,
  }) async {
    loading.value = true;
    error.value = null;

    try {
      await _fire.collection('expenses').doc(id).update({
        'amount': amount,
        'merchant': merchant,
        'category': category,
        'date': Timestamp.fromDate(date),
        'paymentMode': paymentMode,
        'note': note,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _fire.collection('expenses').doc(id).delete();
    } catch (e) {
      error.value = e.toString();
    }
  }

  String suggestCategory(String merchant) {
    if (merchant.isEmpty) return 'Others';
    final lowered = merchant.toLowerCase();
    final suggestions = {
      'swiggy': 'Food',
      'zomato': 'Food',
      'dominos': 'Food',
      'starbucks': 'Food',
      'mcdonald': 'Food',
      'uber': 'Travel',
      'ola': 'Travel',
      'amazon': 'Shopping',
      'flipkart': 'Shopping',
      'netflix': 'Entertainment',
      'spotify': 'Entertainment',
      'pharmacy': 'Medical',
      'medplus': 'Medical',
      'doctor': 'Medical',
      'electricity': 'Bills',
      'water': 'Bills',
      'gas': 'Bills',
      'recharge': 'Recharge',
      'investment': 'Investment',
      'mutual': 'Investment',
      'broker': 'Investment',
      'payment': 'Bills',
      'hotel': 'Travel',
      'airbnb': 'Travel',
    };

    for (final entry in suggestions.entries) {
      if (lowered.contains(entry.key)) {
        return entry.value;
      }
    }

    for (final category in categories) {
      if (lowered.contains(category.toLowerCase())) {
        return category;
      }
    }

    return 'Others';
  }

  List<Expense> duplicatesFor({
    required double amount,
    required String merchant,
    required DateTime date,
  }) {
    final normalizedMerchant = merchant.trim().toLowerCase();
    return expenses.where((expense) {
      final sameMerchant = expense.merchant.trim().toLowerCase() == normalizedMerchant;
      final sameAmount = expense.amount == amount;
      final withinOneDay = expense.date.difference(date).inDays.abs() <= 1;
      return sameMerchant && sameAmount && withinOneDay;
    }).toList();
  }

  double totalInPeriod(DateTime start, DateTime end) {
    return expenses
        .where((expense) => !expense.date.isBefore(start) && !expense.date.isAfter(end))
        .fold(0.0, (subtotal, expense) => subtotal + expense.amount);
  }

  double get totalThisMonth {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return totalInPeriod(start, end);
  }

  double get totalToday {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return totalInPeriod(start, end);
  }

  String get topCategory {
    if (expenses.isEmpty) return 'None';
    final totals = <String, double>{};
    for (final expense in expenses) {
      totals[expense.category] = (totals[expense.category] ?? 0) + expense.amount;
    }
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  String get topMerchant {
    if (expenses.isEmpty) return 'None';
    final totals = <String, double>{};
    for (final expense in expenses) {
      totals[expense.merchant] = (totals[expense.merchant] ?? 0) + expense.amount;
    }
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  double get predictedMonthEnd {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final elapsedDays = now.difference(monthStart).inDays + 1;
    if (elapsedDays <= 0) return totalThisMonth;
    final avgPerDay = totalThisMonth / elapsedDays;
    final totalDays = DateTime(now.year, now.month + 1, 0).day;
    return avgPerDay * totalDays;
  }

  double get weeklyComparisonPercent {
    final now = DateTime.now();
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final lastWeekEnd = thisWeekStart.subtract(const Duration(seconds: 1));
    final thisWeekTotal = totalInPeriod(thisWeekStart, now);
    final lastWeekTotal = totalInPeriod(lastWeekStart, lastWeekEnd);
    if (lastWeekTotal == 0) return 0;
    return ((thisWeekTotal - lastWeekTotal) / lastWeekTotal) * 100;
  }

  int get spendingScore {
    var score = 100;
    if (totalThisMonth > 25000) score -= 10;
    if (weeklyComparisonPercent > 20) score -= 10;
    if (topCategory == 'Food') score -= 5;
    if (topCategory == 'Shopping') score -= 3;
    return score.clamp(0, 100).toInt();
  }

  String get spendingSummary {
    if (expenses.isEmpty) return 'Start adding expenses to see insights.';
    final buffer = StringBuffer();
    buffer.writeln('You spent ₹${totalThisMonth.toStringAsFixed(0)} this month.');
    buffer.writeln('Highest category: $topCategory');
    buffer.writeln('Highest merchant: $topMerchant');
    return buffer.toString();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
