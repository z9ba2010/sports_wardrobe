import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/apparel_product.dart';

class ParserApiService {
  // По умолчанию локальный IP ПК в Wi-Fi сети; можно изменить в настройках приложения
  String baseUrl;
  bool lastRequestUsedFallback = false;

  ParserApiService({this.baseUrl = 'http://192.168.0.175:8000'});

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
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        lastRequestUsedFallback = false;
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List items = data['items'] ?? [];
        return items.map((e) => ApparelProduct.fromJson(e)).toList();
      } else {
        throw Exception('Ошибка ответа парсера: ${response.statusCode}');
      }
    } catch (e) {
      print('ParserApiService offline/error ($e), switching to demo catalog');
      lastRequestUsedFallback = true;
      return _filterDemoCatalog(query: query, category: category);
    }
  }

  /// Поиск по фотографии с камеры (POST /api/v1/vision/recognize)
  Future<List<ApparelProduct>> recognizeByPhoto(File imageFile) async {
    final uri = Uri.parse('$baseUrl/api/v1/vision/recognize');

    try {
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 10));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        lastRequestUsedFallback = false;
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
      print('ParserApiService vision offline/error ($e), returning demo match');
      lastRequestUsedFallback = true;
      return _demoCatalog.where((p) => p.category == 'Обувь').toList();
    }
  }

  List<ApparelProduct> _filterDemoCatalog({String? query, String? category}) {
    return _demoCatalog.where((item) {
      final matchesCat = category == null ||
          category.isEmpty ||
          item.category.toLowerCase().contains(category.toLowerCase());
      final q = (query ?? '').trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          item.productName.toLowerCase().contains(q) ||
          item.brand.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q) ||
          (item.skuId?.toLowerCase().contains(q) ?? false);
      return matchesCat && matchesQuery;
    }).toList();
  }

  static final List<ApparelProduct> _demoCatalog = [
    ApparelProduct(
      id: 101,
      skuId: 'NK-PEG41',
      title: 'Кроссовки беговые Nike Air Zoom Pegasus 41',
      productName: 'Nike Air Zoom Pegasus 41',
      brand: 'Nike',
      category: 'Обувь',
      gender: 'Унисекс',
      priceCurrent: 15990,
      imageUrls: ['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500&q=80'],
      sourceUrl: 'https://maxfunfit.ru/catalog/nike-pegasus-41',
      source: 'Демо-каталог',
    ),
    ApparelProduct(
      id: 102,
      skuId: 'AS-NOV4',
      title: 'Кроссовки ASICS Novablast 4',
      productName: 'ASICS Novablast 4',
      brand: 'ASICS',
      category: 'Обувь',
      gender: 'Унисекс',
      priceCurrent: 17490,
      imageUrls: ['https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=500&q=80'],
      sourceUrl: 'https://maxfunfit.ru/catalog/asics-novablast-4',
      source: 'Демо-каталог',
    ),
    ApparelProduct(
      id: 103,
      skuId: 'HK-CLIF9',
      title: 'Кроссовки Hoka Clifton 9',
      productName: 'Hoka Clifton 9',
      brand: 'Hoka',
      category: 'Обувь',
      gender: 'Унисекс',
      priceCurrent: 16900,
      imageUrls: ['https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=500&q=80'],
      sourceUrl: 'https://maxfunfit.ru/catalog/hoka-clifton-9',
      source: 'Демо-каталог',
    ),
    ApparelProduct(
      id: 104,
      skuId: 'SL-BONAT',
      title: 'Ветровка беговая Salomon Bonatti Waterproof',
      productName: 'Salomon Bonatti Waterproof Jacket',
      brand: 'Salomon',
      category: 'Куртки',
      gender: 'Унисекс',
      priceCurrent: 18500,
      imageUrls: ['https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=500&q=80'],
      sourceUrl: 'https://maxfunfit.ru/catalog/salomon-bonatti',
      source: 'Демо-каталог',
    ),
    ApparelProduct(
      id: 105,
      skuId: 'NK-DRI-T',
      title: 'Футболка беговая Nike Dri-FIT Miler',
      productName: 'Nike Dri-FIT Miler Tee',
      brand: 'Nike',
      category: 'Футболки',
      gender: 'Мужской',
      priceCurrent: 4290,
      imageUrls: ['https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=500&q=80'],
      sourceUrl: 'https://maxfunfit.ru/catalog/nike-miler-tee',
      source: 'Демо-каталог',
    ),
    ApparelProduct(
      id: 106,
      skuId: 'CR-PRO-SH',
      title: 'Шорты беговые Craft Pro Velocity 2-in-1',
      productName: 'Craft Pro Velocity Shorts',
      brand: 'Craft',
      category: 'Шорты',
      gender: 'Унисекс',
      priceCurrent: 5990,
      imageUrls: ['https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=500&q=80'],
      sourceUrl: 'https://maxfunfit.ru/catalog/craft-velocity-shorts',
      source: 'Демо-каталог',
    ),
    ApparelProduct(
      id: 107,
      skuId: 'AS-TIGHT',
      title: 'Тайтсы беговые ASICS Core Tight',
      productName: 'ASICS Core Running Tights',
      brand: 'ASICS',
      category: 'Тайтсы',
      gender: 'Унисекс',
      priceCurrent: 6490,
      imageUrls: ['https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=500&q=80'],
      sourceUrl: 'https://maxfunfit.ru/catalog/asics-core-tight',
      source: 'Демо-каталог',
    ),
    ApparelProduct(
      id: 108,
      skuId: 'CP-SOCKS',
      title: 'Носки компрессионные CEP Run 4.0',
      productName: 'CEP Run Socks 4.0',
      brand: 'CEP',
      category: 'Носки',
      gender: 'Унисекс',
      priceCurrent: 2490,
      imageUrls: ['https://images.unsplash.com/photo-1586350977771-b3b0abd50c82?w=500&q=80'],
      sourceUrl: 'https://maxfunfit.ru/catalog/cep-run-socks',
      source: 'Демо-каталог',
    ),
  ];
}
