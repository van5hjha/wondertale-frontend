import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../models/product.dart';
import 'api_config.dart';
import 'api_utils.dart';

class PaginatedProducts {
  final int count;
  final String? nextUrl;
  final String? previousUrl;
  final List<Product> products;

  PaginatedProducts({
    required this.count,
    this.nextUrl,
    this.previousUrl,
    required this.products,
  });
}

class ProductsService {
  /// Calls `GET /api/products/` to fetch active products from the Django backend.
  Future<PaginatedProducts> fetchProducts({int page = 1}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/products/?page=$page');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'] as List? ?? [];
      final products = results.map((json) => Product.fromJson(json)).toList();
      return PaginatedProducts(
        count: data['count'] as int? ?? 0,
        nextUrl: data['next'] as String?,
        previousUrl: data['previous'] as String?,
        products: products,
      );
    } else {
      final errorMsg = parseError(response.body);
      throw Exception('Failed to fetch products: $errorMsg');
    }
  }

  /// Loads products from the local assets products.json file as a fallback.
  Future<PaginatedProducts> loadLocalProducts() async {
    final jsonString = await rootBundle.loadString('assets/data/products.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    final products = jsonList.map((j) => Product.fromJson(j)).toList();
    return PaginatedProducts(
      count: products.length,
      nextUrl: null,
      previousUrl: null,
      products: products,
    );
  }
}
