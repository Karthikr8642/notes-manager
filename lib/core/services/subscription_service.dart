import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for detecting and tracking recurring subscriptions
/// Auto-detects subscriptions from expense history
class SubscriptionService {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;
  
  /// Auto-detect subscriptions from expenses
  /// Looks for recurring patterns: Netflix ₹199 every month on 15th
  Future<List<Map<String, dynamic>>> detectSubscriptions(
    String userId,
    List<Map<String, dynamic>> expenses,
  ) async {
    // TODO: Analyze expense patterns
    // - Group by merchant and amount
    // - Check for monthly recurrence
    // - Look at day-of-month patterns
    // - Filter known subscription merchants
    
    final detectedSubscriptions = <Map<String, dynamic>>[];
    
    // Known subscription patterns
    final subscriptionMerchants = {
      'netflix': 'Entertainment',
      'prime': 'Entertainment',
      'spotify': 'Entertainment',
      'amazon prime': 'Entertainment',
      'youtube': 'Entertainment',
      'hotstar': 'Entertainment',
      'apple music': 'Entertainment',
      'gym': 'Health',
      'zymrat': 'Health',
      'duolingo': 'Education',
      'microsoft': 'Productivity',
      'adobe': 'Productivity',
      'figma': 'Productivity',
    };
    
    // TODO: Implement pattern detection logic
    
    return detectedSubscriptions;
  }
  
  /// Calculate total monthly subscription cost
  double getTotalSubscriptionCost(List<Map<String, dynamic>> subscriptions) {
    return subscriptions.fold<double>(
      0.0,
      (sum, sub) => sum + (sub['monthlyAmount'] as double? ?? 0),
    );
  }
  
  /// Detect unused subscriptions
  /// If not accessed in X days, flag it
  List<Map<String, dynamic>> detectUnusedSubscriptions(
    List<Map<String, dynamic>> subscriptions,
    int unusedThresholdDays,
  ) {
    // TODO: Check app usage analytics
    // Cross-reference with user's device data
    // Return subscriptions not used recently
    
    return subscriptions
        .where((sub) => (sub['daysSinceLastUsed'] as int? ?? 999) > unusedThresholdDays)
        .toList();
  }
  
  /// Save detected subscription to Firestore
  Future<void> saveSubscription(
    String userId,
    Map<String, dynamic> subscription,
  ) async {
    try {
      await _fire.collection('subscriptions').add({
        'userId': userId,
        'name': subscription['name'],
        'monthlyAmount': subscription['monthlyAmount'],
        'startDate': Timestamp.fromDate(subscription['startDate'] ?? DateTime.now()),
        'category': subscription['category'] ?? 'Other',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving subscription: $e');
    }
  }
  
  /// Get cancellation recommendation
  Map<String, dynamic> getCancellationRecommendation(
    String subscriptionName,
    double monthlyAmount,
    int daysSinceLastUsed,
  ) {
    return {
      'subscriptionName': subscriptionName,
      'shouldCancel': daysSinceLastUsed > 30,
      'reason': daysSinceLastUsed > 30 
        ? 'You haven\'t used this in $daysSinceLastUsed days.'
        : 'Keep using this one.',
      'monthlySavings': monthlyAmount,
      'annualSavings': monthlyAmount * 12,
    };
  }
}
