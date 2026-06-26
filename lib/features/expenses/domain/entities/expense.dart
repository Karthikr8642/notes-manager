import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final double amount;
  final String merchant;
  final String category;
  final DateTime date;
  final String paymentMode;
  final String note;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Expense({
    required this.id,
    required this.amount,
    required this.merchant,
    required this.category,
    required this.date,
    required this.paymentMode,
    required this.note,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory Expense.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data() ?? <String, dynamic>{};
    return Expense(
      id: snap.id,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      merchant: data['merchant'] as String? ?? '',
      category: data['category'] as String? ?? 'Others',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paymentMode: data['paymentMode'] as String? ?? 'Unknown',
      note: data['note'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
