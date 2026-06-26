/// AI Financial OS - Data Collection Architecture
/// 
/// This module handles automatic expense collection from:
/// - Push notifications (shopping, banking, UPI)
/// - Email (Gmail/Outlook - invoices, receipts, bookings)
/// - SMS (banking alerts, OTPs)
/// - Calendar events (salary dates, bill schedules)
/// - OCR receipt scanning
/// - Share extension (shopping apps)
/// - Screenshot detection (carts, wishlists)
/// - Browser extension (web shopping)
/// - Open Banking APIs (where available)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

/// Data source types for the Financial OS
enum DataSourceType {
  notification,      // Push notifications from apps
  email,            // Gmail/Outlook emails
  sms,              // Bank SMS alerts
  calendar,         // Calendar events for salary/bills
  ocrReceipt,       // Scanned receipts
  shareExtension,   // Share-to-app from shopping apps
  screenshot,       // Screenshot detection
  browserExtension, // Web shopping tracker
  openBanking,      // Bank APIs
  upiGateway,       // UPI payment notifications
}

/// Raw data collected from various sources before parsing
class RawFinancialData {
  final String id;
  final String userId;
  final DataSourceType source;
  final String rawContent;      // Original text/data
  final DateTime collectedAt;
  final Map<String, dynamic>? metadata; // Extra info (app name, sender, etc.)
  final bool isParsed;
  final String? parsedExpenseId; // Link to parsed expense
  final int confidence; // 0-100, how sure we are it's valid

  RawFinancialData({
    required this.id,
    required this.userId,
    required this.source,
    required this.rawContent,
    required this.collectedAt,
    this.metadata,
    this.isParsed = false,
    this.parsedExpenseId,
    this.confidence = 100,
  });
}

/// Parsed transaction from raw data
class AutoParsedTransaction {
  final String id;
  final String userId;
  final String rawDataId;      // Reference to RawFinancialData
  final DataSourceType source;
  final String? merchant;
  final double? amount;
  final String? category;      // AI-categorized
  final DateTime? transactionDate;
  final String? paymentMode;   // UPI, Card, Net Banking, etc.
  final String? product;        // What was bought
  final String? orderId;        // For tracking
  final String? status;         // PENDING, COMPLETED, CANCELLED
  final bool requiresReview;    // Confidence < threshold
  final DateTime createdAt;

  AutoParsedTransaction({
    required this.id,
    required this.userId,
    required this.rawDataId,
    required this.source,
    this.merchant,
    this.amount,
    this.category,
    this.transactionDate,
    this.paymentMode,
    this.product,
    this.orderId,
    this.status,
    this.requiresReview = false,
    required this.createdAt,
  });
}

/// Data source permissions and configuration
class DataSourcePermission {
  final DataSourceType type;
  final bool isGranted;
  final DateTime? grantedAt;
  final DateTime? expiresAt; // OAuth tokens
  final String? token;        // For API access
  final String? email;        // For Gmail integration
  final Map<String, dynamic>? config; // Source-specific settings

  DataSourcePermission({
    required this.type,
    required this.isGranted,
    this.grantedAt,
    this.expiresAt,
    this.token,
    this.email,
    this.config,
  });
}

/// Financial OS configuration per user
class FinancialOSConfig {
  final String userId;
  final List<DataSourcePermission> permissions;
  final bool autoParseNotifications;
  final bool autoParseEmails;
  final bool autoImportSMS;
  final bool autoSyncCalendar;
  final bool autoSuggestCategories;
  final int confidenceThreshold; // Min confidence to auto-create expense
  final bool notifyOnDataCollection;

  FinancialOSConfig({
    required this.userId,
    this.permissions = const [],
    this.autoParseNotifications = true,
    this.autoParseEmails = true,
    this.autoImportSMS = true,
    this.autoSyncCalendar = true,
    this.autoSuggestCategories = true,
    this.confidenceThreshold = 80,
    this.notifyOnDataCollection = true,
  });
}

/// Timeline view combining all data sources
class UnifiedFinancialTimeline {
  final String userId;
  final List<TimelineEvent> events;
  final DateTime generatedAt;

  UnifiedFinancialTimeline({
    required this.userId,
    required this.events,
    required this.generatedAt,
  });
}

/// Single timeline event (could be transaction, notification, alert, etc.)
class TimelineEvent {
  final String id;
  final DateTime timestamp;
  final String type;            // EXPENSE, INCOME, ALERT, NOTIFICATION
  final String title;
  final String? description;
  final double? amount;
  final String? icon;           // Material icon name
  final String? color;          // Hex color
  final String? relatedExpense; // Link to Expense ID if created

  TimelineEvent({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.title,
    this.description,
    this.amount,
    this.icon,
    this.color,
    this.relatedExpense,
  });
}
