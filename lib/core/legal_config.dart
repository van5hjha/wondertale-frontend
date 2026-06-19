class LegalConfig {
  // --- BUSINESS ENTITY DETAILS ---
  /// The registered legal name of your business entity.
  static const String entityName = 'Wondertale Private Limited';

  /// The physical registered office address of your company.
  static const String registeredAddress = '3rd Floor, Room no 29, P2 Unispace, Plot No: 128, EPIP Zone Whitefield Rd, Brookefield, Bengaluru, Karnataka 560066';

  /// The customer support phone number.
  static const String supportPhone = '+91 80 4718 0474';

  /// The customer support email address.
  static const String supportEmail = 'support@wondertale.com';

  /// The business hours or operational hours.
  static const String supportHours = 'Mon - Fri, 10:00 AM - 6:00 PM';


  // --- PRICING & TAX DETAILS ---
  /// Currency symbol to display throughout the app.
  static const String currencySymbol = '₹';

  /// Currency code (e.g. INR, USD)
  static const String currencyCode = 'INR';

  /// Whether prices displayed include GST/taxes.
  static const bool isTaxIncluded = true;

  /// Custom note about taxes (e.g. "incl. GST")
  static const String taxNote = 'Inclusive of all taxes';


  // --- SHIPPING & DELIVERY TIMELINES ---
  /// Delivery timeline description for the Home/Product pages.
  static const String estimatedDeliveryTime = '7-8 working days';

  /// Shipping regions/regions covered by delivery.
  static const String shippingRegions = 'Deliveries available across all pin codes in India.';

  /// Default courier partners used for deliveries.
  static const String courierPartners = 'Delhivery, BlueDart, and Speed Post';

  /// Dispatch timeline post-order approval.
  static const String dispatchTimeline = 'Dispatched within 24-48 hours after photo approval.';


  // --- CANCELLATION & REFUND POLICIES ---
  /// Time frame (in hours) within which an order can be cancelled before design/print queue begins.
  static const int cancellationWindowHours = 2;
}
