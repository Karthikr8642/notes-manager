import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for managing spending challenges and gamification
class ChallengeService {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;
  
  /// Create a new challenge for user
  /// Example: "No Swiggy for 7 days → Save ₹2,000"
  Future<String> createChallenge(
    String userId,
    String title,
    String type, // CATEGORY_SPEND_LIMIT, NO_CATEGORY, DAILY_LIMIT
    Map<String, dynamic> criteria,
    DateTime endDate,
    double? estimatedSavings,
  ) async {
    try {
      final doc = await _fire.collection('challenges').add({
        'userId': userId,
        'title': title,
        'description': title,
        'type': type,
        'criteria': criteria,
        'startDate': FieldValue.serverTimestamp(),
        'endDate': Timestamp.fromDate(endDate),
        'isCompleted': false,
        'completionPercent': 0,
        'estimatedSavings': estimatedSavings ?? 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return doc.id;
    } catch (e) {
      print('Error creating challenge: $e');
      return '';
    }
  }
  
  /// Get suggested challenges for user based on spending patterns
  List<Map<String, dynamic>> suggestChallenges(
    Map<String, double> spendByCategory,
    double totalBudget,
  ) {
    final suggestions = <Map<String, dynamic>>[];
    
    // Find top spending category
    final topCategory = spendByCategory.entries.reduce((a, b) => a.value > b.value ? a : b);
    if (topCategory.value > totalBudget * 0.4) {
      suggestions.add({
        'title': 'Reduce ${topCategory.key}',
        'type': 'CATEGORY_SPEND_LIMIT',
        'description': 'Spend 30% less on ${topCategory.key} this week',
        'criterion': topCategory.key,
        'maxAmount': topCategory.value * 0.7,
        'duration': '7 days',
        'estimatedSavings': topCategory.value * 0.3,
      });
    }
    
    // Suggest daily spend limit
    final avgDaily = totalBudget / 30;
    suggestions.add({
      'title': 'Daily Spend Limit',
      'type': 'DAILY_LIMIT',
      'description': 'Spend below ₹${avgDaily.toStringAsFixed(0)} every day for a week',
      'maxAmount': avgDaily,
      'duration': '7 days',
      'estimatedSavings': avgDaily * 0.2 * 7,
    });
    
    return suggestions;
  }
  
  /// Update challenge progress
  Future<void> updateChallengeProgress(
    String challengeId,
    int completionPercent,
  ) async {
    try {
      await _fire.collection('challenges').doc(challengeId).update({
        'completionPercent': completionPercent,
      });
    } catch (e) {
      print('Error updating challenge: $e');
    }
  }
  
  /// Complete challenge and award rewards
  Future<Map<String, dynamic>> completeChallenge(
    String challengeId,
    double estimatedSavings,
  ) async {
    try {
      await _fire.collection('challenges').doc(challengeId).update({
        'isCompleted': true,
        'completionPercent': 100,
        'completedAt': FieldValue.serverTimestamp(),
      });
      
      return {
        'message': '🎉 Challenge completed!',
        'savings': estimatedSavings,
        'xpEarned': 100,
        'badgeUnlocked': 'Money Saver',
      };
    } catch (e) {
      print('Error completing challenge: $e');
      return {};
    }
  }
  
  /// Get user's challenge statistics
  Map<String, dynamic> getChallengeStats(
    List<Map<String, dynamic>> challenges,
  ) {
    final completed = challenges.where((c) => c['isCompleted'] == true).length;
    final totalSavings = challenges.fold<double>(
      0,
      (sum, c) => sum + (c['estimatedSavings'] as double? ?? 0),
    );
    
    return {
      'totalChallenges': challenges.length,
      'completedChallenges': completed,
      'completionRate': challenges.isEmpty ? 0 : (completed / challenges.length * 100),
      'totalSavingsByAllChallenges': totalSavings,
      'currentStreak': _calculateStreak(challenges),
      'xpEarned': completed * 100,
    };
  }
  
  int _calculateStreak(List<Map<String, dynamic>> challenges) {
    // TODO: Calculate consecutive day or week completion streak
    return 5;
  }
}
