# AI Financial OS - Architecture & Vision

## 🎯 The Problem

Users spend money constantly, but expense tracking apps require **manual data entry**.

- "I have to remember every transaction"
- "I have 47 notifications but don't track them"
- "My receipts pile up in my drawer"
- "I miss payment deadlines"
- "I don't know where my money goes"

**Manual entry friction = Low adoption = Users abandon the app**

---

## 💡 The Solution: AI Financial OS

Transform the app from a **passive recorder** to an **active financial intelligence system** that automatically collects and categorizes transactions from every approved source the user already uses.

**Key Insight:** Don't ask users to change behavior. Meet them where they are.

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    AI Financial Brain                       │
│  (Notification Parser, ML Categorizer, Timeline Generator)  │
└──────────────────────┬──────────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
        ▼              ▼              ▼
   ┌─────────┐   ┌─────────┐   ┌─────────┐
   │Raw Data │   │Parsing &│   │Storage &│
   │Ingestion│→  │Validation   │ Timeline
   │         │   │         │   │         │
   └─────────┘   └─────────┘   └────┬────┘
        ▲                            │
        │                            ▼
   1. Notifications  ────→ Extracted Transactions ──→ Firestore
   2. Emails         ────→ Confidence Score      ──→ User Timeline
   3. SMS            ────→ Auto-Created Expense ──→ Dashboard
   4. Calendar       ────→ Manual Review Queue
   5. OCR Receipts
   6. Screenshots
```

---

## 📊 Data Sources & Integration

### 1. Notification Access (Android 13+)

**Service:** `NotificationListenerService`
**Permissions:** `BIND_NOTIFICATION_LISTENER_SERVICE`

Reads notifications from:

- **Shopping:** Amazon, Flipkart, Myntra, Croma, AjioKart
- **Food:** Swiggy, Zomato, Magicpin, Blinkit, Zepto
- **Banking:** HDFC, ICICI, Axis, SBI, KOTAK
- **Payments:** Google Pay, PhonePe, Paytm, Amazon Pay
- **Hotels:** Booking.com, OYO, MakeMyTrip

**Example Extraction:**

```
Input notification:  "Amazon: Your order for Sony Headphones has been shipped."
                     ↓ (AI Parser)
Output: {
  "merchant": "Amazon",
  "product": "Sony Headphones",
  "status": "SHIPPED",
  "confidence": 95
}
```

---

### 2. Email Integration (Gmail/Outlook OAuth)

**Service:** `EmailParsingService`
**API:** Gmail API v1 / Microsoft Graph API

Connects to email and reads ONLY:

- Order confirmations (Amazon, Flipkart)
- Invoices (stores, services)
- Receipts (food delivery, shopping)
- Bookings (hotels, flights, trains)
- Bills (utilities—optional)

**Privacy:** Uses Gmail filter to read only messages with subjects containing:
`invoice | receipt | order | booking | confirmation | bill`

**Example Extraction:**

```
Input email: From: amazon@amazon.com
             Subject: "Your Amazon Invoice - Sony WH-CH720N"
             Body: "Total with tax: ₹5,699 (incl. GST ₹870)"
                     ↓ (OCR + Parser)
Output: {
  "merchant": "Amazon",
  "amount": 5699,
  "gst": 870,
  "product": "Sony WH-CH720N",
  "category": "Shopping",
  "confidence": 97
}
```

---

### 3. SMS Parsing (Banking Alerts)

**Request Permission:** `READ_SMS`
**Filter:** Only from known bank numbers

Parses banking SMS:

```
Input SMS:  "HDFC: Rs.599 spent on AMAZON using HDFC Credit Card. Available Balance: ₹12,450."
            ↓ (Regex + Parser)
Output: {
  "merchant": "Amazon",
  "amount": 599,
  "paymentMode": "HDFC Credit Card",
  "availableBalance": 12450,
  "category": "Shopping",
  "confidence": 98
}
```

---

### 4. Calendar Integration

**Request Permission:** `READ_CALENDAR`

Detects financial events:

- **Salary Date:** Marked in calendar → forecast income
- **EMI/Loan:** Recurring events → predict outflows
- **Rent/Utilities:** Bill due dates → set reminders
- **Travel:** Vacation planned → alert if budget insufficient

**Example:**

```
Calendar Event: "Salary Credited" (repeats Monthly on 28th)
                ↓
App automatically knows:
- ₹62,000 income every 28th
- Can forecast month-end balance
- Set reminders for bill payments before salary
```

---

### 5. Receipt Scanning (OCR)

**Service:** `ReceiptScannerService`
**Tech:** ML Kit Vision / Firebase ML Kit

User takes photo of receipt:

```
Photo: [Receipt image]
  ↓ (OCR Processing)
Extracted:
  - Store: "Zomato"
  - Items: ["Biryani", "Coke", "Dessert"]
  - Amount: ₹420
  - GST: ₹76
  - Date: Jun 27, 2026
  - Warranty: No (food)

  ↓ (Stored in Firestore)
Later query: "Show me warranty for Boat Headphones"
→ Receipt appears instantly
```

---

### 6. Share Extension

**How it works:**

1. User finds product on Amazon
2. Taps "Share" → selects "AI Wallet"
3. App captures:
   - Product name
   - Price
   - Images
   - Seller
   - URL
4. Stores in Wishlist + Price Tracker

**Code Pattern:**

```dart
// Receive share from Amazon
// Intent extras: product_name, price, url, seller
// Parse and store automatically
```

---

### 7. Screenshot Detection

**Request Permission:** Photo Library + Accessibility Service (optional)

When user takes screenshot of shopping cart:

- AI Vision detects products and prices
- User confirmation: "Add these 2 items to wishlist?"
- One-tap saves to tracked products

---

### 8. Browser Extension (Future)

Desktop users shopping online:

- Real-time price comparison overlay
- "Best price: Croma ₹5,699"
- Wishlist sync
- Cart tracking

---

## 🤖 Parsing & Categorization Pipeline

### Step 1: Raw Data Collection

```dart
// Services listen to:
// - Notification stream
// - Email inbox
// - SMS inbox
// - Calendar changes

// Store in: raw_financial_data collection
```

### Step 2: Intelligent Parsing

```dart
// Different parsers for each source:
NotificationParser → Extract merchant, amount, status
EmailParser        → OCR + regex extraction
SMSParser          → Regex patterns + Merchant DB lookup
CalendarParser     → Event title → Financial event type
```

### Step 3: Merchant Recognition

```dart
// Known prefixes → Category mapping
{
  "amazon", "flipkart", "myntra" → "Shopping",
  "swiggy", "zomato", "food" → "Food",
  "uber", "ola" → "Travel",
  "netflix", "spotify", "prime" → "Entertainment",
}
```

### Step 4: Confidence Scoring

```dart
// For each extracted field
confidence = (regex_match * 0.3) + (merchant_known * 0.5) + (amount_valid * 0.2)

// If confidence >= 80%  → Auto-create Expense
// If confidence < 80%   → Queue for User Review
```

### Step 5: Timeline Generation

```dart
// Combine all sources into chronological order:
// [Income] [Expense] [Bill Due] [Price Alert] [Subscription] [Reminder]
// User sees unified view across all financial events
```

---

## 🔒 Privacy & Security by Design

### Principles

1. **Zero Tracking:** No background surveillance
2. **Opt-In Only:** User explicitly grants each permission
3. **Minimal Scope:** Access only what's needed (e.g., Gmail reads invoices, not personal emails)
4. **Encryption:** TLS in transit, encryption at rest in Firestore
5. **User Control:** Can revoke, delete, export anytime

### What We Read

✅ Shopping notifications
✅ Invoice/receipt emails  
✅ Banking alerts SMS
✅ Calendar (financial events only)
✅ Receipt photos (OCR only, deleted after)

### What We Never Read

❌ Personal emails or conversations
❌ Private chat messages
❌ Passwords or authentication tokens
❌ Other apps' internal data
❌ Browsing history
❌ Documents unrelated to finances

### Data Storage

- Encrypted in transit (HTTPS/TLS)
- Encrypted at rest (Firestore encryption)
- Auto-delete old data after 90 days (user-configurable)
- User can request full data export
- Account deletion = all data purged

### Third-Party Sharing

❌ Never sold to advertisers
❌ Never shared on social media
❌ Never given to credit agencies (unless user consents + complies with law)
❌ Only law enforcement with warrant

---

## 🎯 Impact & Success Metrics

### Automation Impact

| Metric               | Before | After                        |
| -------------------- | ------ | ---------------------------- |
| Manual Entry %       | 100%   | 10%                          |
| Time per transaction | 2 min  | 0 sec (auto)                 |
| Transactions tracked | ~5/day | ~20/day                      |
| User retention (30d) | 30%    | 75%+                         |
| Daily active users   | Low    | High (happens automatically) |

### Parsing Performance

- **Notification accuracy:** 95%+
- **Email extraction:** 97%+
- **SMS parsing:** 99%
- **Confidence threshold:** 80% (auto-create)
- **Manual review rate:** <20%

---

## 🔄 System Flow: End-to-End Example

**Real scenario: User buys shoes on Amazon**

```
1. 🛒 User completes Amazon purchase
   └─→ ₹5,699 charged via PhonePe

2. 📱 Amazon sends notification
   └─→ "Sony headphones ordered"

3. 💳 PhonePe sends UPI notification
   └─→ "₹5,699 paid to Amazon"

4. 🏦 HDFC sends SMS alert
   └─→ "Rs.5,699 spent on AMAZON via Wallet. Balance: ₹12,450"

5. 📧 Amazon sends invoice email
   └─→ Invoice with GST details

6. 🧠 AI Financial OS processes all 4 signals
   ├─→ NotificationParser: "Amazon pending"
   ├─→ UPIParser: "₹5,699 paid"
   ├─→ SMSParser: Confirms HDFC charged
   └─→ EmailParser: Extracts and links invoice

7. ✅ Confidence score = (0.9 + 0.98 + 0.99 + 0.97) / 4 = 96%

8. 💾 Auto-creates Expense:
   {
     "merchant": "Amazon",
     "amount": 5699,
     "category": "Shopping",
     "paymentMode": "UPI (PhonePe)",
     "product": "Sony headphones",
     "invoice": [email data],
     "status": "COMPLETED",
     "sources": ["notification", "upi", "sms", "email"],
     "confidence": 96,
   }

9. 📊 Updates Dashboard:
   - Spent Today: +₹5,699
   - This Month: +₹5,699
   - Shopping Category: Updated
   - Item added to warranty tracker

10. 👤 User sees in Timeline:
    "💳 Amazon - ₹5,699 - Shopping (Auto-detected)"
    [One-click to edit or approve]
```

**All in < 5 seconds. User does nothing. No manual entry.**

---

## 🚀 Rollout Strategy

### Phase 1: MVP (Week 3-4)

- [x] Notification parser for shopping apps
- [x] SMS parser for banks
- [x] Gmail integration
- [x] Confidence scoring
- [x] Timeline view

### Phase 2: Expansion (Week 5-8)

- Calendar integration
- Receipt OCR
- Share extension
- Email filtering improvements
- Batch processing for bulk imports

### Phase 3: Refinement (Week 9-12)

- ML model for better parsing
- Browser extension
- Webhook integrations
- Open Banking APIs (where available)
- A/B testing on confidence thresholds

### Phase 4: Scale (Week 13+)

- Background sync optimization
- Rate limiting & quotas
- Multi-account support
- Real-time dashboard updates
- Advanced filtering options

---

## 💻 Tech Stack

**Frontend:** Flutter (iOS + Android)
**Backend:** Firebase Firestore + Functions
**Parsing:** Regex + NLP (Gemini API for complex cases)
**OCR:** ML Kit Vision
**Notifications:** Firebase Cloud Messaging
**OAuth:** Google Sign-In, Microsoft Graph
**NLP:** spaCy or similar for entity extraction
**Storage:** Google Cloud Storage (receipts)

---

## 📝 Next Steps

1. **Implement Phase 2:** AI Financial OS (this document)
   - Finalize notification parser
   - Set up Gmail OAuth flow
   - Build confidence scoring logic

2. **Beta Testing:** Internal testing with team members
   - Test all parsers with real transactions
   - Measure parsing accuracy
   - Fine-tune confidence thresholds

3. **User Feedback:** Early adopter testing
   - Does auto-detection feel right?
   - Are permissions requests clear?
   - Is privacy transparent?

4. **Launch:** Gradual rollout to beta users
   - Monitor accuracy metrics
   - Gather feedback
   - Iterate on experience

5. **Iterate:** Refine based on real user data
   - Add more merchants
   - Improve parsing for edge cases
   - Build additional data sources

---

## 🎓 Key Learnings

**This transforms the app from:**

- ❌ "Manually record every expense"
- ✅ "Automatically collect everything, review as needed"

**From user perspective:**

- ❌ 2-minute data entry per transaction
- ✅ 0 seconds (happens in background)

**From business perspective:**

- ❌ Low data density (only what users remember)
- ✅ High data density (100% of transactions)
- ❌ Low retention (friction of entering data)
- ✅ High retention (automatic habits)

**This is the difference between:**

- A utility app users grudgingly use
- A life-changing financial OS users love

---

## 📖 Further Exploration

Once Phase 2 is live, add:

1. **AI Financial Twin** - Predictive recommendations
2. **Intelligent Shopping** - Price comparison, best buy times
3. **Investment Automation** - SIP suggestions, tax optimization
4. **Family Sync** - Shared spending, split bills
5. **Open Banking** - Bank APIs for deeper insights

All powered by the unified data collected in Phase 2.
