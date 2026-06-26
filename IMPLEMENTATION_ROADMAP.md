# AI Personal Financial & Shopping Companion - Implementation Roadmap

## Phase 1: Foundation (Current - Week 1-2)

**Core Expense Tracking & Basic Analytics**

- [x] Expense recording with merchant, category, payment mode
- [x] AI auto-categorization using merchant intelligence
- [x] Monthly spending insights and comparisons
- [x] Duplicate expense detection
- [x] Spending score and financial health
- [x] Firestore integration for data persistence

**Deliverables:**

- Basic wallet dashboard with daily/monthly stats
- Expense CRUD operations
- Category suggestions

---

## Phase 2: AI Financial OS - Automatic Data Collection (Week 3-4)

**🎯 GAME CHANGER: Zero-manual-entry expense tracking**

The app becomes an AI Financial Brain that automatically collects transaction data from multiple approved sources.

### Key Principle

**Permission-first, Privacy-first:** Users explicitly grant access to each data source. No hidden tracking.

### Data Sources

1. **Push Notifications** (Android 13+)
   - Shopping apps: Amazon, Flipkart, Myntra, Croma, etc.
   - Food delivery: Swiggy, Zomato, Magicpin
   - Banking apps: HDFC, ICICI, Axis, SBI
   - UPI apps: Google Pay, PhonePe, Paytm
   - AI extracts: merchant, amount, product, time, status

2. **Email Integration** (Gmail/Outlook OAuth)
   - Invoices: Amazon, Flipkart orders
   - Receipts: Swiggy, Zomato, hotel bookings
   - Tickets: Flight bookings, train tickets
   - Warranty: Scanned receipts with expiry tracking
   - AI extracts: total amount, GST, items, warranty dates

3. **SMS Parsing** (Banking alerts)
   - Bank messages: "Rs.599 spent on AMAZON using HDFC Credit Card"
   - UPI notifications: "₹540 paid to Swiggy"
   - Auto-extraction: merchant, amount, payment method, category

4. **Calendar Integration**
   - Detect salary deposit dates
   - Track EMI/loan payment dates
   - Identify bill due dates (electricity, water, rent)
   - Forecast cash flow automatically

5. **OCR Receipt Scanning**
   - Photo → AI parsing → structured data
   - Extracts: store name, items, GST, date, warranty
   - Stores receipt in cloud for warranty claims later

6. **Share Extension**
   - User shares product links from shopping apps
   - One tap → AI Wallet captures price, images, reviews, seller

7. **Screenshot Detection**
   - User screenshots shopping cart
   - AI recognizes items and prices
   - Auto-saves to wishlist (user confirmation)

8. **Calendar + UPI + Notifications = Unified Timeline**
   - Combine all sources into chronological financial view
   - Shows income, expenses, alerts, price drops, bill reminders

### Technical Architecture

**Flow:**

```
Data Source (Notification/Email/SMS/etc.)
    ↓
Raw Data Collection & Storage
    ↓
AI NLP + Regex Parsing
    ↓
Extracted Transaction (merchant, amount, category, etc.)
    ↓
Confidence Check (>80% auto-create, else manual review)
    ↓
Store in Firestore + Link to Expense
    ↓
Unified Timeline Updated
```

**New Models:**

- `RawFinancialData` - raw input before parsing
- `AutoParsedTransaction` - extracted data with confidence score
- `FinancialOSConfig` - user permissions & settings
- `UnifiedFinancialTimeline` - all events combined

**New Services:**

- `FinancialOSService` - orchestrates all data collection
- `UnifiedTimelineService` - combines all sources into one view
- `FinancialOSPermissionsService` - handles privacy & OAuth

**New Pages:**

- `FinancialOSSetupPage` - one-time permission grants
- `UnifiedTimelinePage` - beautiful chronological view
- `AutoParsedReviewPage` - review uncertain transactions
- `DataSourcesPage` - manage which sources are enabled

### Privacy & Security

✅ **What users explicitly grant:**

- Read notifications (Android)
- Parse SMS (banking only)
- OAuth Gmail/Outlook (invoices/receipts only)
- Calendar read access
- Photo gallery for receipts
- Battery optimization exemption (background collection)

❌ **Never collected:**

- Personal emails or conversations
- Passwords or authentication tokens
- Other app's private data
- Browsing history
- Unrelated documents

🔒 **Encryption:**

- All data → HTTPS/TLS in transit
- Firebase Firestore encryption at rest
- User can auto-delete old data after 90 days
- Can always revoke permissions

### AI Parsing Examples

**Notification:** "Your order for Sony Headphones has been shipped."
→ `{ merchant: "Amazon", amount: null, product: "Sony Headphones", status: "SHIPPED" }`

**Email:** "Amazon Invoice - Sony WH-CH720N - ₹5,699 (incl. GST ₹870)"
→ `{ merchant: "Amazon", amount: 5699, gst: 870, product: "Sony WH-CH720N", category: "Shopping" }`

**SMS:** "Rs.540 spent on SWIGGY using HDFC Debit Card at Jun 27 10:30"
→ `{ merchant: "Swiggy", amount: 540, category: "Food", paymentMode: "Debit Card", timestamp: "10:30" }`

**Notification:** "₹800 received from Rahul"
→ `{ merchant: "Received from Rahul", amount: 800, category: "Income", paymentMode: "UPI", type: "TRANSFER_IN" }`

### Success Metrics

- **Automation Rate:** % of expenses auto-created without manual entry
- **Parsing Accuracy:** % of correctly extracted fields
- **User Confidence:** % of auto-transactions users accept without review
- **Data Freshness:** Avg delay from transaction → app (< 5 mins)

---

## Phase 3: Shopping Intelligence (Week 5-6)

**Price Comparison & Wishlist Management**

### Features:

1. **Shopping Wishlist Aggregation**
   - Store product links from multiple platforms (Amazon, Flipkart, Myntra, etc.)
   - Track price history per product
   - Add notes and wishlist categories

2. **Price Comparison Engine**
   - Multi-platform price lookup (initial: manual / future: API integration)
   - Best price finder with savings calculation
   - Price history graphs
   - Best time to buy recommendations (using historical patterns)

3. **Price Drop Alerts**
   - Notify user when product drops below target price
   - Weekly summary of drops on wishlist items

4. **Smart Receipt Scanner**
   - OCR-based bill parsing
   - Extract merchant, GST, items, warranty, expiry
   - Link receipts to products for warranty tracking

**New Models:**

- `Product` - product details with price history
- `Wishlist` - user's saved items across platforms
- `PriceHistory` - track price changes over time
- `Receipt` - scanned bill data with items

**New Controllers:**

- `ShoppingController` - wishlist and price comparison
- `PriceTrackingService` - price updates and alerts
- `ReceiptScannerService` - OCR and bill parsing

**New Pages:**

- `WishlistPage` - browsing and managing wishlists
- `PriceComparisonPage` - compare prices across stores
- `ReceiptScannerPage` - take photos and scan bills

---

## Phase 4: Subscription & Bill Management (Week 7-8)

**Automated Subscription Tracking & Bill Calendar**

### Features:

1. **Subscription Tracker**
   - Auto-detect recurring subscriptions from expenses
   - Monthly cost aggregation
   - Unused subscription detection
   - Cancellation recommendations

2. **Smart Bill Calendar**
   - Mark salary date, EMI dates, insurance, rent, utilities
   - Cash flow prediction
   - Low-balance warnings before due dates
   - Bill payment reminders

3. **Investment Suggestions**
   - Recommend SIP/savings based on monthly surplus
   - Emergency fund advising
   - Tax-saving investment alerts

**New Models:**

- `Subscription` - recurring payment tracking
- `BillEvent` - calendar events for bills/salary
- `CashFlowForecast` - predicted balance trends

**New Services:**

- `SubscriptionDetectionService` - identify recurring payments
- `BillReminderService` - push notifications for due dates
- `InvestmentAdvisor` - SIP recommendations

**New Pages:**

- `SubscriptionTrackerPage` - manage subscriptions
- `BillCalendarPage` - upcoming bills and cash flow
- `InvestmentPage` - savings and investment suggestions

---

## Phase 5: Social & Family Features (Week 9-10)

**Expense Splitting & Family Wallet**

### Features:

1. **Family Wallet**
   - Add family members (spouse, parents, roommates)
   - Share expense groups
   - Smart bill splitting (equally, by percentage, custom)
   - UPI request integration

2. **Group Expenses**
   - Track who paid for what in group outings
   - Automatic settlement calculations
   - History of group expenses

**New Models:**

- `FamilyGroup` - group of users sharing expenses
- `SharedExpense` - expense split among multiple people
- `Settlement` - who owes whom

**New Services:**

- `ExpenseSplittingService` - calculate splits
- `UPIIntegrationService` - send payment requests

**New Pages:**

- `FamilyPage` - invite and manage family members
- `SplitExpensePage` - add group expenses
- `SettlementPage` - show who owes whom

---

## Phase 6: AI Coach & Chat Interface (Week 11-12)

**Natural Language Financial Advice**

### Features:

1. **Chat with Money**
   - Ask questions naturally: "How much on food this month?"
   - Query-based expense analysis
   - Budget breach predictions
   - Purchase affordability checks

2. **AI Spending Coach**
   - Personalized spending analysis
   - Habit-based recommendations
   - Goal tracking and motivation

3. **Financial Habit Score**
   - Rate spending across categories
   - Identify weak areas (impulse buying, subscriptions, etc.)
   - Suggest improvements

**New Services:**

- `ChatService` - NLP-based query parsing and response
- `AICoachService` - spending analysis and recommendations
- `HabitAnalyzer` - category-wise spending patterns

**New UI:**

- `ChatPage` - conversational financial queries
- `CoachPage` - personalized recommendations
- `HabitScorePage` - habit breakdown and insights

---

## Phase 7: Gamification & Daily Engagement (Week 13-14)

**Challenges, Badges, and Daily Summaries**

### Features:

1. **AI Challenges**
   - "No Swiggy for 7 days → Save ₹2,000"
   - Daily spend limits
   - Category-specific challenges
   - XP, badges, streaks, and rewards

2. **AI Daily Summary**
   - Every morning: spending recap
   - Evening: budget status and savings
   - Week/month summaries

3. **Financial Twin**
   - Proactive advice before user acts
   - "Wait until Friday; this item usually drops 12%"
   - Predictive budget insights
   - Goal-based savings acceleration

**New Models:**

- `Challenge` - user challenges with rewards
- `Badge` - achievements unlocked
- `DailySummary` - personalized daily report

**New Services:**

- `ChallengeService` - create and track challenges
- `NotificationService` - send daily/weekly summaries
- `FinancialTwinService` - ML-based recommendations

**New Pages:**

- `ChallengesPage` - active challenges and leaderboards
- `StatsPage` - weekly/monthly breakdowns
- `FinancialTwinPage` - personalized insights

---

## Phase 8: Advanced Features & Integrations (Week 15+)

**Third-Party Integrations & ML**

### Features:

1. **API Integrations** (where official APIs exist)
   - Amazon Wishlist API
   - Flipkart Partner Network
   - Food delivery APIs (Swiggy, Zomato)
   - Bank API for auto-imports (if available)

2. **AI Financial Twin ML Model**
   - Predict spending patterns
   - Seasonal purchase detection
   - Recommend best buying times
   - Price drop predictions

3. **Investment Tracking**
   - Portfolio tracking
   - Mutual fund suggestions
   - Stock recommendations

4. **Credit Score Insights**
   - On-time bill payment tracking
   - Credit health indicators

---

## Privacy & Permissions Strategy

### User-Controlled Data Access

✅ **Always opt-in:**

- Read shopping notifications (Android 10+)
- Connect to supported APIs (with OAuth)
- Share cart/wishlist screenshots
- Import order confirmation emails
- Connect to bank (UPI payments)

❌ **Never automated:**

- Access private account data without permission
- Store unauthorized payment information
- Share data with third parties

### Firestore Structure

```
users/{userId}/
  ├── profile/
  ├── expenses/
  ├── wishlist/
  ├── subscriptions/
  ├── bills/
  ├── family_groups/
  ├── challenges/
  └── settings/
```

---

## Technology Stack

**Frontend:**

- Flutter (cross-platform)
- GetX (state management)
- Hive (local caching)
- SQLite (offline fallback)

**Backend:**

- Firebase Firestore (real-time DB)
- Firebase Auth (authentication)
- Cloud Functions (scheduled tasks)
- Cloud Storage (receipts, screenshots)

**AI/ML:**

- Gemini API (merchant categorization, spending insights)
- OpenAI API (alternative AI service)
- TensorFlow Lite (on-device ML for patterns)
- ML Kit (OCR for receipt scanning)

**Third-Party:**

- UPI integration (PhonePe, Google Pay)
- Push notifications (Firebase Cloud Messaging)
- Email parsing (for order confirmations)
- Price tracking APIs (JioCinema, MyntraAPI where available)

---

## Success Metrics

- Daily Active Users (DAU)
- Average session time
- Features used per session
- Money saved by users (tracked)
- Challenge completion rate
- Chat query success rate
- User retention rate

---

## Next Steps

1. **Immediate (This Sprint):**
   - Complete Phase 1: Expense tracking ✓
   - Begin Phase 2: Wishlist and price tracking

2. **Short Term (Next 2 Sprints):**
   - Implement receipt scanner
   - Add subscription detection
   - Deploy first version to beta

3. **Medium Term (1-2 Months):**
   - Launch family wallet
   - Add chat interface
   - Implement challenges and gamification

4. **Long Term:**
   - AI Financial Twin with ML
   - Official API integrations
   - Investment and credit tracking
