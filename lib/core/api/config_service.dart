import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../legal_config.dart';

class ConfigService {
  static Future<void> loadConfig() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/config/');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        ApiConfig.underMaintenance = data['under_maintenance'] ?? ApiConfig.underMaintenance;
        
        LegalConfig.entityName = data['entity_name'] ?? LegalConfig.entityName;
        LegalConfig.registeredAddress = data['registered_address'] ?? LegalConfig.registeredAddress;
        LegalConfig.supportPhone = data['support_phone'] ?? LegalConfig.supportPhone;
        LegalConfig.supportEmail = data['support_email'] ?? LegalConfig.supportEmail;
        LegalConfig.supportHours = data['support_hours'] ?? LegalConfig.supportHours;
        LegalConfig.currencySymbol = data['currency_symbol'] ?? LegalConfig.currencySymbol;
        LegalConfig.currencyCode = data['currency_code'] ?? LegalConfig.currencyCode;
        LegalConfig.isTaxIncluded = data['is_tax_included'] ?? LegalConfig.isTaxIncluded;
        LegalConfig.taxNote = data['tax_note'] ?? LegalConfig.taxNote;
        LegalConfig.estimatedDeliveryTime = data['estimated_delivery_time'] ?? LegalConfig.estimatedDeliveryTime;
        LegalConfig.shippingRegions = data['shipping_regions'] ?? LegalConfig.shippingRegions;
        LegalConfig.courierPartners = data['courier_partners'] ?? LegalConfig.courierPartners;
        LegalConfig.dispatchTimeline = data['dispatch_timeline'] ?? LegalConfig.dispatchTimeline;
        
        LegalConfig.softcoverImageUrl = data['softcoverImageUrl'];
        LegalConfig.hardcoverImageUrl = data['hardcoverImageUrl'];
        
        LegalConfig.cancellationWindowHours = data['cancellation_window_hours'] ?? LegalConfig.cancellationWindowHours;

        LegalConfig.viewingMin = data['viewing_min'] ?? LegalConfig.viewingMin;
        LegalConfig.viewingMax = data['viewing_max'] ?? LegalConfig.viewingMax;
        LegalConfig.craftingMin = data['crafting_min'] ?? LegalConfig.craftingMin;
        LegalConfig.craftingMax = data['crafting_max'] ?? LegalConfig.craftingMax;
        LegalConfig.activeViewingCount = data['active_viewing_count'];
        LegalConfig.activeCraftingCount = data['active_crafting_count'];

        LegalConfig.announcementText = data['announcement_text'] ?? LegalConfig.announcementText;
        LegalConfig.announcementEnabled = data['announcement_enabled'] ?? LegalConfig.announcementEnabled;
        LegalConfig.discountBarText = data['discount_bar_text'] ?? LegalConfig.discountBarText;
        LegalConfig.discountBarEnabled = data['discount_bar_enabled'] ?? LegalConfig.discountBarEnabled;
      } else {
        debugPrint('Failed to load remote config. Using fallback config. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching config from backend: $e. Using local defaults.');
    }
  }
}
