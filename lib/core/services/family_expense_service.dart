import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for family expense splitting and group management
class FamilyExpenseService {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;
  
  /// Create a family group
  Future<String> createFamilyGroup(
    String userId,
    String groupName,
    List<String> memberUids,
  ) async {
    try {
      final doc = await _fire.collection('family_groups').add({
        'createdBy': userId,
        'groupName': groupName,
        'members': memberUids,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return doc.id;
    } catch (e) {
      print('Error creating family group: $e');
      return '';
    }
  }
  
  /// Add shared expense to family group
  /// Example: Dinner paid by Karthik, split equally among 5 people
  Future<String> addSharedExpense(
    String groupId,
    String paidByUserId,
    String description,
    double totalAmount,
    List<String> memberUids,
    String splitType, // EQUAL, PERCENTAGE, CUSTOM
    {Map<String, double>? customSplits}
  ) async {
    try {
      // Calculate splits
      Map<String, double> splits;
      
      if (splitType == 'EQUAL') {
        final perPerson = totalAmount / memberUids.length;
        splits = {for (var uid in memberUids) uid: perPerson};
      } else if (splitType == 'CUSTOM' && customSplits != null) {
        splits = customSplits;
      } else {
        splits = {paidByUserId: totalAmount};
      }
      
      final doc = await _fire.collection('shared_expenses').add({
        'familyGroupId': groupId,
        'paidByUserId': paidByUserId,
        'description': description,
        'totalAmount': totalAmount,
        'splits': splits,
        'date': Timestamp.fromDate(DateTime.now()),
        'isSettled': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return doc.id;
    } catch (e) {
      print('Error adding shared expense: $e');
      return '';
    }
  }
  
  /// Calculate who owes whom in a group
  Map<String, Map<String, double>> calculateSettlements(
    List<Map<String, dynamic>> sharedExpenses,
  ) {
    // TODO: Implement settlement calculation algorithm
    // Returns: { userId: { creditorId: amount_owed } }
    
    final balances = <String, double>{};
    
    for (var expense in sharedExpenses) {
      final paidBy = expense['paidByUserId'] as String;
      final splits = (expense['splits'] as Map).cast<String, double>();
      
      for (var entry in splits.entries) {
        final debtor = entry.key;
        final owedAmount = entry.value;
        
        if (debtor != paidBy) {
          balances[debtor] = (balances[debtor] ?? 0) - owedAmount;
          balances[paidBy] = (balances[paidBy] ?? 0) + owedAmount;
        }
      }
    }
    
    // Convert to readable format
    final settlements = <String, Map<String, double>>{};
    
    // Optimize settlements (minimize transactions)
    // TODO: Implement settlement optimization algorithm
    
    return settlements;
  }
  
  /// Get UPI request message for settlement
  String getUPISettlementMessage(
    String creditorName,
    double amount,
    String reason,
  ) {
    return '$creditorName has to pay you ₹${amount.toStringAsFixed(0)} for $reason. '
        'Send UPI payment? (Tap to send)';
  }
  
  /// Mark expense as settled
  Future<void> markExpenseAsSettled(String expenseId) async {
    try {
      await _fire.collection('shared_expenses').doc(expenseId).update({
        'isSettled': true,
        'settledAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking expense as settled: $e');
    }
  }
  
  /// Get group expense summary
  Map<String, dynamic> getGroupExpenseSummary(
    List<Map<String, dynamic>> sharedExpenses,
  ) {
    double totalGroupExpense = 0;
    final expensesByUser = <String, double>{};
    
    for (var expense in sharedExpenses) {
      totalGroupExpense += (expense['totalAmount'] as double? ?? 0);
      final paidBy = expense['paidByUserId'] as String;
      expensesByUser[paidBy] = (expensesByUser[paidBy] ?? 0) + (expense['totalAmount'] as double? ?? 0);
    }
    
    return {
      'totalGroupExpense': totalGroupExpense,
      'totalTransactions': sharedExpenses.length,
      'expensesByUser': expensesByUser,
      'averagePerTransaction': sharedExpenses.isEmpty ? 0 : totalGroupExpense / sharedExpenses.length,
    };
  }
}
