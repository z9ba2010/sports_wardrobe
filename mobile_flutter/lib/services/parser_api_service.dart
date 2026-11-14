import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/apparel_product.dart';

class ParserApiService {
  // Для Android эмулятора используйте 10.0.2.2, для реального устройства - локальный IP хоста
  final String baseUrl;

  ParserApiService({this.baseUrl = 'http://10.0.2.2:8000'});

  /// Текстовый поиск экипировки через API Парсера (GET /api/v1/apparel)
  Future<List<ApparelProduct>> searchApparel({
    String? query,
    String? category,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };
    if (query != null && query.trim().isNotEmpty) {
      queryParams['search'] = query.trim();
    }
    if (category != null && category.trim().isNotEmpty) {
      queryParams['category'] = category.trim();
    }

    final uri = Uri.parse('$baseUrl/api/v1/apparel').replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List items = data['items'] ?? [];
        return items.map((e) => ApparelProduct.fromJson(e)).toList();
      } else {
        throw Exception('Ошибка ответа парсера: ${response.statusCode}');
      }
    } catch (e) {
      print('ParserApiService error: $e');
      rethrow;
    }
  }

  /// Поиск по фотографии с камеры (POST /api/v1/vision/recognize)
  Future<List<ApparelProduct>> recognizeByPhoto(File imageFile) async {
    final uri = Uri.parse('$baseUrl/api/v1/vision/recognize');

    try {
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        List<ApparelProduct> results = [];

        if (data['matched_product'] != null) {
          results.add(ApparelProduct.fromJson(data['matched_product']));
        }
        if (data['similar_products'] is List) {
          for (var p in data['similar_products']) {
            results.add(ApparelProduct.fromJson(p));
          }
        }
        return results;
      } else {
        throw Exception('Ошибка распознавания Vision API: ${response.statusCode}');
      }
    } catch (e) {
      print('ParserApiService vision error: $e');
      rethrow;
    }
  }
}
