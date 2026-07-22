class LegalConfig {
  // --- BUSINESS ENTITY DETAILS ---
  /// The registered legal name of your business entity.
  static String entityName = 'MD AAQIF';

  /// The physical registered office address of your company.
  static String registeredAddress =
      'B-278/ GALI NO-4, JAITPUR PART-2, KHADDA COLONY, NEAR SONI MODERN PUBLIC SCHOOL,  NEW DELHI-110044';

  /// The customer support phone number.
  static String supportPhone = '+91 8506021247';

  /// The customer support email address.
  static String supportEmail = 'support@wondertale.in';

  /// The business hours or operational hours.
  static String supportHours = 'Mon - Fri, 10:00 AM - 6:00 PM';

  // --- PRICING & TAX DETAILS ---
  /// Currency symbol to display throughout the app.
  static String currencySymbol = '₹';

  /// Currency code (e.g. INR, USD)
  static String currencyCode = 'INR';

  /// Whether prices displayed include GST/taxes.
  static bool isTaxIncluded = true;

  /// Custom note about taxes (e.g. "incl. GST")
  static String taxNote = 'Inclusive of all taxes';

  // --- SHIPPING & DELIVERY TIMELINES ---
  /// Delivery timeline description for the Home/Product pages.
  static String estimatedDeliveryTime = '7-8 working days';

  /// Shipping regions/regions covered by delivery.
  static String shippingRegions =
      'Deliveries available across all pin codes in India.';

  /// Default courier partners used for deliveries.
  static String courierPartners = 'Delhivery, BlueDart, and Speed Post';

  /// Dispatch timeline post-order approval.
  static String dispatchTimeline =
      'Dispatched within 24-48 hours after photo approval.';

  // --- PRICING IMAGES ---
  /// Dynamic images for pricing sections.
  static String? softcoverImageUrl;
  static String? hardcoverImageUrl;

  // --- CANCELLATION & REFUND POLICIES ---
  /// Time frame (in hours) within which an order can be cancelled before design/print queue begins.
  static int cancellationWindowHours = 2;

  // --- SOCIAL PROOF COUNTERS ---
  /// Minimum active viewing count range (default 60).
  static int viewingMin = 60;

  /// Maximum active viewing count range (default 99).
  static int viewingMax = 99;

  /// Minimum stories crafting count range (default 8).
  static int craftingMin = 8;

  /// Maximum stories crafting count range (default 50).
  static int craftingMax = 50;

  /// Backend pre-computed active viewing count (optional).
  static int? activeViewingCount;

  /// Backend pre-computed active crafting count (optional).
  static int? activeCraftingCount;

  // --- ANNOUNCEMENT & DISCOUNT BANNERS ---
  /// Top header announcement text.
  static String announcementText =
      '✨ New Story Alert: "The Crystal Cave" is now available for personalization! ✨';

  /// Whether the top announcement bar is enabled.
  static bool announcementEnabled = true;

  /// Promotional discount bar text.
  static String discountBarText =
      '⚡ Limited Time Offer: Save up to 33% OFF on all custom storybooks today!';

  /// Whether the promotional discount bar is enabled.
  static bool discountBarEnabled = true;
}
