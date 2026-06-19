import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../core/legal_config.dart';
import '../widgets/navbar.dart';
import '../widgets/footer.dart';
import 'home_view.dart';
import 'products_view.dart';

class InfoView extends StatefulWidget {
  final int initialTabIndex;

  const InfoView({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<InfoView> createState() => _InfoViewState();
}

class _InfoViewState extends State<InfoView> {
  late int _activeTab;
  final _formKey = GlobalKey<FormState>();
  
  // Contact Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _orderIdController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  
  bool _isSending = false;
  bool _formSubmitted = false;

  final List<Map<String, dynamic>> _tabs = [
    {
      'title': 'Privacy Policy',
      'icon': Icons.security,
    },
    {
      'title': 'Terms of Service',
      'icon': Icons.description,
    },
    {
      'title': 'Refund & Cancellation',
      'icon': Icons.assignment_return,
    },
    {
      'title': 'Shipping Policy',
      'icon': Icons.local_shipping,
    },
    {
      'title': 'Contact Us',
      'icon': Icons.contact_support,
    },
  ];

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTabIndex;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _orderIdController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitContactForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSending = true;
    });

    // Simulate sending message to support API
    await Future.delayed(const Duration(seconds: 1500 ~/ 1000));

    if (mounted) {
      setState(() {
        _isSending = false;
        _formSubmitted = true;
      });
      
      _nameController.clear();
      _emailController.clear();
      _orderIdController.clear();
      _messageController.clear();
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📋 $label copied to clipboard!'),
        backgroundColor: AppTheme.secondary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 960.0;
    final isTablet = width >= 640.0;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: NavBar(
        activeIndex: -1,
        onHomeTap: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeView()),
          );
        },
        onExploreStoriesTap: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeView()),
          ).then((_) {
            // Scroll to stories key after routing
          });
        },
        onHowItWorksTap: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeView()),
          );
        },
        onPricingTap: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeView()),
          );
        },
        onCreatePreviewTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProductsView()),
          );
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40.0),
            
            // Header Hero Banner
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? AppConstants.desktopMargin : AppConstants.mobileMargin,
                vertical: 40.0,
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: AppConstants.maxContainerWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CUSTOMER HELP & POLICIES',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppTheme.secondary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        _tabs[_activeTab]['title'],
                        style: (isTablet
                                ? Theme.of(context).textTheme.displayLarge
                                : Theme.of(context).textTheme.displayMedium)
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Find answers to your questions, contact details, and our operational guidelines.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Main Help/Legal Workspace Layout
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: AppConstants.maxContainerWidth),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? AppConstants.gutter : AppConstants.mobileMargin,
                ),
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Sidebar Tabs
                          SizedBox(
                            width: 280.0,
                            child: _buildSidebar(context),
                          ),
                          const SizedBox(width: 48.0),
                          
                          // Right Policy Content
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                                border: Border.all(
                                  color: AppTheme.primary.withOpacity(0.05),
                                  width: 1.0,
                                ),
                              ),
                              padding: const EdgeInsets.all(40.0),
                              child: _buildActiveTabContent(context),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top scrollable tabs
                          _buildMobileTabs(context),
                          const SizedBox(height: 24.0),
                          
                          // Main Content Box
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                              border: Border.all(
                                color: AppTheme.primary.withOpacity(0.05),
                                  width: 1.0,
                              ),
                            ),
                            padding: const EdgeInsets.all(24.0),
                            child: _buildActiveTabContent(context),
                          ),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 80.0),
            const Footer(),
          ],
        ),
      ),
    );
  }

  // Sidebar navigation for desktop
  Widget _buildSidebar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(_tabs.length, (index) {
          final tab = _tabs[index];
          final isActive = _activeTab == index;
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _activeTab = index;
                    _formSubmitted = false;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.secondaryContainer : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    children: [
                      Icon(
                        tab['icon'] as IconData,
                        color: isActive ? AppTheme.onSecondaryContainer : AppTheme.onSurfaceVariant,
                        size: 20.0,
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Text(
                          tab['title'] as String,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: isActive ? AppTheme.onSecondaryContainer : AppTheme.primary,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              ),
                        ),
                      ),
                      if (isActive)
                        const Icon(
                          Icons.chevron_right,
                          color: AppTheme.secondary,
                          size: 16.0,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // Horizontal scrollable tabs for tablet/mobile
  Widget _buildMobileTabs(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final tab = _tabs[index];
          final isActive = _activeTab == index;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _activeTab = index;
                  _formSubmitted = false;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.secondaryContainer : AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Row(
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      color: isActive ? AppTheme.onSecondaryContainer : AppTheme.onSurfaceVariant,
                      size: 16.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      tab['title'] as String,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: isActive ? AppTheme.onSecondaryContainer : AppTheme.primary,
                            fontSize: 13.0,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActiveTabContent(BuildContext context) {
    switch (_activeTab) {
      case 0:
        return _buildPrivacyPolicy();
      case 1:
        return _buildTermsOfService();
      case 2:
        return _buildRefundPolicy();
      case 3:
        return _buildShippingPolicy();
      case 4:
        return _buildContactUs();
      default:
        return const SizedBox.shrink();
    }
  }

  // --- PRIVACY POLICY ---
  Widget _buildPrivacyPolicy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Privacy Policy'),
        _buildLastUpdated('Last updated: June 8, 2026'),
        _buildParagraph(
          'At Wondertale, operated by ${LegalConfig.entityName}, we are highly committed to protecting the privacy of our customers and their children. This Privacy Policy describes how we collect, store, scan, use, and process personal information, specifically tailored for our personalized children\'s storybooks service.',
        ),
        
        _buildSubHeader('1. Data We Collect'),
        _buildParagraph(
          'To generate your customized storybook, we collect the following information during order creation:',
        ),
        _buildBulletPoint('Parent\'s name, email address, shipping address, and phone number.'),
        _buildBulletPoint('Child\'s first name (used to name the protagonist in the story).'),
        _buildBulletPoint('Child\'s approximate age and gender/pronoun preference (to tailor story text and theme complexity).'),
        _buildBulletPoint('A photograph of your child\'s face (uploaded by the parent or guardian).'),

        _buildSubHeader('2. How We Use and Process Children\'s Photos'),
        _buildParagraph(
          'We treat uploaded photos with the highest security and confidentiality. Here is how photo processing works:',
        ),
        _buildBulletPoint('**AI Face-Scanning:** We run high-resolution AI face-mapping algorithms to align and blend your child\'s facial structure into our preset, artist-drawn storybook illustrations. This process is fully automated and does not involve human cataloging of facial databases.'),
        _buildBulletPoint('**Limited Processing Purpose:** Uploaded photos are strictly used to render the customized illustrations of the ordered books.'),
        _buildBulletPoint('**Automatic Post-Delivery Deletion:** To respect your child\'s privacy, we do not store original photos indefinitely. Both original face photos and scanned biometric tokens are permanently deleted from our primary storage databases within thirty (30) days of successful order delivery.'),
        
        _buildSubHeader('3. Storage and Safety Measures'),
        _buildParagraph(
          'All customer data is encrypted in transit using SSL/TLS protocols and stored securely in cloud servers using AES-256 encryption. Access to original images is strictly locked down and automated, meaning no external third-party or unauthorized personnel can access your child\'s photos.',
        ),
        _buildParagraph(
          'We do not sell, rent, or lease any child\'s name, gender information, or photo data to third parties. Customer address and phone number details are only shared with authorized logistics partners (${LegalConfig.courierPartners}) to complete delivery.',
        ),
        
        _buildSubHeader('4. Contact Privacy Officer'),
        _buildParagraph(
          'If you have any questions about this Privacy Policy or wish to request immediate deletion of your child\'s uploaded photo and information before the 30-day automatic deletion window, please contact our privacy officer at ${LegalConfig.supportEmail}.',
        ),
      ],
    );
  }

  // --- TERMS OF SERVICE ---
  Widget _buildTermsOfService() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Terms of Service'),
        _buildLastUpdated('Last updated: June 8, 2026'),
        _buildParagraph(
          'Welcome to Wondertale! These Terms of Service ("Terms") govern your access to and use of our website, services, and purchase of personalized children\'s storybooks. By using our website and placing an order, you agree to comply with and be bound by these Terms.',
        ),
        
        _buildSubHeader('1. Order Eligibility and Customer Inputs'),
        _buildParagraph(
          'To purchase custom books, you represent that you are the parent or legal guardian of the child being personalized, or that you have received explicit authorization from the child\'s parent or guardian to upload their name and photo.',
        ),
        _buildParagraph(
          'You agree to provide accurate details (names, spelling, gender options, and high-quality clear photos). We are not responsible for spelling mistakes or low-quality prints due to blurry/out-of-focus original photo uploads.',
        ),

        _buildSubHeader('2. Custom AI Rendering & Previews'),
        _buildParagraph(
          'We offer free digital book previews to show you how our AI face-mapping and personalization fits into the selected story. While we strive to achieve stunning face-mapping results, variations in photo quality, lighting, and angles may affect final rendering. Digital previews are representative, and minor differences in print colors compared to back-lit screens are natural.',
        ),

        _buildSubHeader('3. Intellectual Property Rights'),
        _buildParagraph(
          'Wondertale and its parent entity, ${LegalConfig.entityName}, retain complete ownership, copyright, and intellectual property rights over all story concepts, texts, custom artist illustrations, designs, software algorithms, and website code. By placing an order, you are granted a non-exclusive license to use the printed physical book for personal, family reading, and non-commercial gift-giving purposes.',
        ),

        _buildSubHeader('4. Customer Indemnity'),
        _buildParagraph(
          'You agree to indemnify and hold harmless Wondertale and its employees against any claims, damages, or liabilities arising from your upload of photos for which you do not own copyright, privacy release, or permissions.',
        ),

        _buildSubHeader('5. Governing Law'),
        _buildParagraph(
          'These Terms shall be governed by and construed in accordance with the laws of India. Any disputes arising out of purchases or use of this platform shall be subject to the exclusive jurisdiction of the courts in Bengaluru, Karnataka, India.',
        ),
      ],
    );
  }

  // --- REFUND POLICY ---
  Widget _buildRefundPolicy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Refund & Cancellation Policy'),
        _buildLastUpdated('Last updated: June 8, 2026'),
        _buildParagraph(
          'Because Wondertale storybooks are highly personalized, custom-designed, and printed-on-demand for a specific child, our refund and cancellation policy is structured as follows:',
        ),
        
        _buildAlertCard(
          context,
          title: 'NO GENERAL REFUNDS',
          content: 'Since each storybook is unique to your child, once printing begins, we cannot accept returns, exchanges, or provide refunds if you change your mind, select the wrong theme, or make spelling typos during ordering.',
        ),

        _buildSubHeader('1. Cancellation Window'),
        _buildParagraph(
          'We understand that mistakes can happen. You can cancel your order and receive a full refund within **${LegalConfig.cancellationWindowHours} hours** of order placement, or before you click "Approve for Printing" (whichever happens first). Once the book enters our automated printing queue, the order is locked and cannot be cancelled.',
        ),
        _buildParagraph(
          'To request a cancellation, please email us immediately at **${LegalConfig.supportEmail}** with your Order ID and the subject line "URGENT: Order Cancellation".',
        ),

        _buildSubHeader('2. Damaged or Defective Books'),
        _buildParagraph(
          'Your satisfaction is our magic! If your custom book arrives with any of the following issues, we will gladly arrange a **free replacement reprint** at absolutely no extra cost to you:',
        ),
        _buildBulletPoint('Physical damage to the book cover, spine, or pages incurred during transit.'),
        _buildBulletPoint('Clear printing defects, such as missing pages, misaligned bindings, or smeared ink.'),
        _buildBulletPoint('The printed book differs from the digital preview you approved (e.g., wrong name or incorrect photo mapping applied).'),
        
        _buildSubHeader('3. How to Request a Replacement'),
        _buildParagraph(
          'To request a free replacement, please follow these steps within **seven (7) days** of receiving your package:',
        ),
        _buildBulletPoint('Send an email to **${LegalConfig.supportEmail}** stating your Order ID.'),
        _buildBulletPoint('Attach a clear photo or short video showing the damage, print defect, or incorrect customization.'),
        _buildParagraph(
          'Once our team verifies the defect, we will immediately initiate printing for a replacement book. The replacement will be shipped within 48 hours and delivered within our standard timeline. You do not need to ship the damaged book back to us.',
        ),
      ],
    );
  }

  // --- SHIPPING POLICY ---
  Widget _buildShippingPolicy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Shipping & Delivery Policy'),
        _buildLastUpdated('Last updated: June 8, 2026'),
        _buildParagraph(
          'We want to deliver Wondertale magic straight to your doorstep as quickly and safely as possible. Here is what you need to know about our shipping policy:',
        ),

        _buildSubHeader('1. Delivery Timelines'),
        _buildParagraph(
          'Each Wondertale storybook undergoes a careful quality check, printing, and binding process. Our standard shipping timelines are as follows:',
        ),
        _buildBulletPoint('**Production/Binding:** 2-3 business days after you approve your book preview.'),
        _buildBulletPoint('**Transit Shipping:** 4-5 business days depending on your delivery address.'),
        _buildBulletPoint('**Total Delivery Time:** Typically **${LegalConfig.estimatedDeliveryTime}** across India.'),

        _buildSubHeader('2. Delivery Zones and Shipping Charges'),
        _buildParagraph(
          'We offer delivery to all major cities, towns, and PIN codes across India. \n\n* **Standard Shipping:** Currently, we offer **FREE Standard Shipping** across India on all storybook orders.',
        ),

        _buildSubHeader('3. Courier Partners'),
        _buildParagraph(
          'We partner with premium, reliable logistics providers to ensure your book arrives in perfect condition. Our main shipping partners include **${LegalConfig.courierPartners}**.',
        ),

        _buildSubHeader('4. Delivery Tracking'),
        _buildParagraph(
          'As soon as your book leaves our printing facility, you will receive an automatic email and SMS containing a tracking link and a Tracking ID. You can use this link to check the live transit status of your package.',
        ),

        _buildSubHeader('5. Address Changes'),
        _buildParagraph(
          'If you need to change your delivery address after ordering, please notify us at **${LegalConfig.supportEmail}** within 2 hours of placing the order. Once the package is handed over to our courier partner, we cannot modify the shipping address.',
        ),
      ],
    );
  }

  // --- CONTACT US ---
  Widget _buildContactUs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Contact Us'),
        _buildParagraph(
          'Have questions about a story theme, need help with your photo upload, or want to check the status of your order? We are here to help!',
        ),
        const SizedBox(height: 32.0),

        // Contact Information Cards Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 24.0) / 2.0;
            final useSingleColumn = constraints.maxWidth < 600.0;
            
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: useSingleColumn ? 1 : 0,
                      child: _buildContactCard(
                        context,
                        icon: Icons.email,
                        title: 'Email Us',
                        value: LegalConfig.supportEmail,
                        onTap: () => _copyToClipboard(LegalConfig.supportEmail, 'Support Email'),
                        width: useSingleColumn ? constraints.maxWidth : cardWidth,
                      ),
                    ),
                    if (!useSingleColumn) const SizedBox(width: 24.0),
                    if (!useSingleColumn)
                      Expanded(
                        child: _buildContactCard(
                          context,
                          icon: Icons.phone,
                          title: 'Call Us',
                          value: LegalConfig.supportPhone,
                          onTap: () => _copyToClipboard(LegalConfig.supportPhone, 'Support Phone'),
                          width: cardWidth,
                        ),
                      ),
                  ],
                ),
                if (useSingleColumn) const SizedBox(height: 16.0),
                if (useSingleColumn)
                  _buildContactCard(
                    context,
                    icon: Icons.phone,
                    title: 'Call Us',
                    value: LegalConfig.supportPhone,
                    onTap: () => _copyToClipboard(LegalConfig.supportPhone, 'Support Phone'),
                    width: constraints.maxWidth,
                  ),
                const SizedBox(height: 16.0),
                _buildContactCard(
                  context,
                  icon: Icons.business,
                  title: 'Registered Office',
                  value: '${LegalConfig.entityName}\n${LegalConfig.registeredAddress}',
                  onTap: () => _copyToClipboard(LegalConfig.registeredAddress, 'Office Address'),
                  width: constraints.maxWidth,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 48.0),

        const Divider(),
        const SizedBox(height: 32.0),

        // Interactive Contact Form
        Text(
          'Send Us a Message',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
        ),
        const SizedBox(height: 8.0),
        Text(
          'Fill out the form below and our customer magic team will get back to you within 24 hours.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 24.0),

        _formSubmitted ? _buildFormSuccessState() : _buildContactForm(),
      ],
    );
  }

  // Contact Form widget
  Widget _buildContactForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildFormTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  hint: 'e.g. Advait Sharma',
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your name' : null,
                ),
              ),
              const SizedBox(width: 24.0),
              Expanded(
                child: _buildFormTextField(
                  label: 'Email Address',
                  controller: _emailController,
                  hint: 'e.g. parent@wondertale.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter your email';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          _buildFormTextField(
            label: 'Order ID (Optional)',
            controller: _orderIdController,
            hint: 'e.g. WT-84902 (Leave blank if asking about story themes)',
          ),
          const SizedBox(height: 20.0),
          _buildFormTextField(
            label: 'Message',
            controller: _messageController,
            hint: 'Type your question or support request here...',
            maxLines: 5,
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your message' : null,
          ),
          const SizedBox(height: 32.0),
          
          // Submit Button
          Center(
            child: SizedBox(
              width: 200.0,
              height: 52.0,
              child: ElevatedButton(
                onPressed: _isSending ? null : _submitContactForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.secondary.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
                  ),
                  elevation: 0,
                ),
                child: _isSending
                    ? const SizedBox(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Send Message',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
                          ),
                          SizedBox(width: 8.0),
                          Icon(Icons.send, size: 16.0),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Form input builder helper
  Widget _buildFormTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          cursorColor: AppTheme.secondary,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.primary,
              ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppTheme.onSurfaceVariant.withOpacity(0.5)),
            filled: true,
            fillColor: AppTheme.surfaceContainerLow,
            contentPadding: const EdgeInsets.all(16.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
              borderSide: const BorderSide(color: AppTheme.secondary, width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
              borderSide: const BorderSide(color: AppTheme.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
              borderSide: const BorderSide(color: AppTheme.error, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }

  // Contact form success feedback state
  Widget _buildFormSuccessState() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppTheme.secondary.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Icon(
              Icons.check_circle,
              color: AppTheme.secondary,
              size: 48.0,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            'Message Sent Successfully!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondary,
                ),
          ),
          const SizedBox(height: 12.0),
          Text(
            'Thank you for reaching out. We have received your query, and our customer support magic team will get back to you at your email address within 24 hours.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 24.0),
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _formSubmitted = false;
                });
              },
              child: const Text(
                'Send Another Message',
                style: TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build contact cards
  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
    required double width,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
            border: Border.all(
              color: AppTheme.primary.withOpacity(0.05),
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: AppTheme.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10.0),
                child: Icon(
                  icon,
                  color: AppTheme.secondary,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppTheme.onSurfaceVariant,
                            fontSize: 12.0,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Icon(
                Icons.copy,
                color: AppTheme.onSurfaceVariant.withOpacity(0.4),
                size: 16.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper formatting widgets
  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
      ),
    );
  }

  Widget _buildLastUpdated(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.onSurfaceVariant.withOpacity(0.6),
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.normal,
            ),
      ),
    );
  }

  Widget _buildSubHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0, bottom: 12.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
              fontSize: 20.0,
            ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurfaceVariant,
              height: 1.6,
            ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8.0, right: 8.0),
            child: Icon(
              Icons.circle,
              size: 6.0,
              color: AppTheme.secondary,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, {required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0, top: 12.0),
      decoration: BoxDecoration(
        color: AppTheme.secondaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
        border: Border.all(color: AppTheme.secondary.withOpacity(0.3), width: 1.0),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info, color: AppTheme.secondary, size: 20.0),
              const SizedBox(width: 8.0),
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}
