class Wishlist {
  final String id;
  final String userId;
  final String productName;
  final String productUrl;
  final String platform; // Amazon, Flipkart, Myntra, etc.
  final double currentPrice;
  final double? targetPrice; // Price user wants to wait for
  final String category; // Fashion, Electronics, Books, etc.
  final DateTime addedDate;
  final DateTime? purchasedDate;
  final bool isPurchased;
  final String? notes;

  Wishlist({
    required this.id,
    required this.userId,
    required this.productName,
    required this.productUrl,
    required this.platform,
    required this.currentPrice,
    this.targetPrice,
    required this.category,
    required this.addedDate,
    this.purchasedDate,
    this.isPurchased = false,
    this.notes,
  });
}

class PriceHistory {
  final String id;
  final String wishlistId;
  final double price;
  final DateTime recordedDate;
  final String platform;
  final bool isAvailable;

  PriceHistory({
    required this.id,
    required this.wishlistId,
    required this.price,
    required this.recordedDate,
    required this.platform,
    this.isAvailable = true,
  });
}

class Subscription {
  final String id;
  final String userId;
  final String name; // Netflix, Prime, Spotify, etc.
  final double monthlyAmount;
  final DateTime startDate;
  final DateTime? nextBillingDate;
  final String? paymentMethod;
  final String? category; // Entertainment, Productivity, etc.
  final bool isActive;
  final int daysSinceLastUsed; // For unused detection
  final String? autoDetectedFrom; // Email, notification, expense

  Subscription({
    required this.id,
    required this.userId,
    required this.name,
    required this.monthlyAmount,
    required this.startDate,
    this.nextBillingDate,
    this.paymentMethod,
    this.category,
    this.isActive = true,
    this.daysSinceLastUsed = 0,
    this.autoDetectedFrom,
  });
}

class BillEvent {
  final String id;
  final String userId;
  final String title; // Rent, EMI, Electricity, etc.
  final String type; // SALARY, EMI, BILL, INSURANCE
  final double? amount;
  final DateTime dueDate;
  final int? dayOfMonth; // For recurring bills
  final bool isRecurring;
  final String? notes;
  final bool isPaid;

  BillEvent({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    this.amount,
    required this.dueDate,
    this.dayOfMonth,
    this.isRecurring = false,
    this.notes,
    this.isPaid = false,
  });
}

class Challenge {
  final String id;
  final String userId;
  final String title; // "No Swiggy for 7 days"
  final String description;
  final String type; // CATEGORY_SPEND_LIMIT, NO_CATEGORY, DAILY_LIMIT
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> criteria; // category, maxAmount, days, etc.
  final double? rewardXP;
  final double? estimatedSavings;
  final bool isCompleted;
  final int completionPercent;

  Challenge({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.criteria,
    this.rewardXP,
    this.estimatedSavings,
    this.isCompleted = false,
    this.completionPercent = 0,
  });
}

class FamilyGroup {
  final String id;
  final String createdBy; // userId
  final String groupName;
  final List<String> members; // List of userIds
  final DateTime createdDate;
  final String? description;

  FamilyGroup({
    required this.id,
    required this.createdBy,
    required this.groupName,
    required this.members,
    required this.createdDate,
    this.description,
  });
}

class SharedExpense {
  final String id;
  final String familyGroupId;
  final String paidByUserId;
  final String description;
  final double totalAmount;
  final Map<String, double> splits; // userId -> amount owed
  final DateTime date;
  final bool isSettled;

  SharedExpense({
    required this.id,
    required this.familyGroupId,
    required this.paidByUserId,
    required this.description,
    required this.totalAmount,
    required this.splits,
    required this.date,
    this.isSettled = false,
  });
}

class Receipt {
  final String id;
  final String userId;
  final String? imagePath; // Local or cloud storage path
  final String merchant;
  final double totalAmount;
  final double? gst;
  final List<String> items; // Product names extracted
  final DateTime purchaseDate;
  final String? warrantyExpiry;
  final String? category;
  final DateTime uploadedDate;

  Receipt({
    required this.id,
    required this.userId,
    this.imagePath,
    required this.merchant,
    required this.totalAmount,
    this.gst,
    this.items = const [],
    required this.purchaseDate,
    this.warrantyExpiry,
    this.category,
    required this.uploadedDate,
  });
}

class HabitScore {
  final String userId;
  final int overallScore; // 0-100
  final Map<String, int> categoryScores; // category -> score
  final Map<String, int> trends; // category -> change % from last month
  final DateTime calculatedDate;
  final String recommendation; // AI-generated text

  HabitScore({
    required this.userId,
    required this.overallScore,
    required this.categoryScores,
    required this.trends,
    required this.calculatedDate,
    required this.recommendation,
  });
}

class DailySummary {
  final String id;
  final String userId;
  final DateTime date;
  final double totalSpend;
  final Map<String, double> spendByCategory;
  final double budgetRemaining;
  final double estimatedSaved; // AI savings from recommendations
  final String insight; // AI-generated motivation
  final List<String> suggestions; // Recommendations from AI

  DailySummary({
    required this.id,
    required this.userId,
    required this.date,
    required this.totalSpend,
    required this.spendByCategory,
    required this.budgetRemaining,
    required this.estimatedSaved,
    required this.insight,
    required this.suggestions,
  });
}
