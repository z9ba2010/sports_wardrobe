import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wardrobe_item.dart';
import '../models/apparel_product.dart';
import 'category_mapper.dart';

class WardrobeRepository {
  final String remoteBaseUrl;
  final List<WardrobeItem> _inMemoryCache = [];

  WardrobeRepository({this.remoteBaseUrl = 'http://10.0.2.2:8001'});

  /// Получить сохраненные вещи пользователя, сгруппированные по 4 секциям
  Future<Map<String, List<WardrobeItem>>> getGroupedWardrobe(String userId) async {
    try {
      final uri = Uri.parse('$remoteBaseUrl/api/v1/wardrobe/grouped?user_id=$userId');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final sectionsRaw = data['sections'] as Map<String, dynamic>;
        
        Map<String, List<WardrobeItem>> result = {
          'Обувь': [],
          'Верх': [],
          'Низ': [],
          'Аксессуары': [],
        };

        sectionsRaw.forEach((key, list) {
          if (list is List) {
            result[key] = list.map((e) => WardrobeItem.fromJson(e)).toList();
          }
        });

        // Синхронизируем локальный кэш
        _inMemoryCache.clear();
        result.values.forEach(_inMemoryCache.addAll);

        return result;
      }
    } catch (e) {
      print('Using local cache for wardrobe: $e');
    }

    // Локальная группировка
    Map<String, List<WardrobeItem>> grouped = {
      'Обувь': [],
      'Верх': [],
      'Низ': [],
      'Аксессуары': [],
    };
    for (var it in _inMemoryCache) {
      final sec = grouped.containsKey(it.category) ? it.category : 'Аксессуары';
      grouped[sec]!.add(it);
    }
    return grouped;
  }

  /// Добавить товар из каталога парсера в гардероб пользователя (CRUD Create)
  Future<WardrobeItem> addItemFromApparel({
    required ApparelProduct product,
    String userId = 'user_default',
  }) async {
    final section = CategoryMapper.mapToSection(product.category, title: product.productName);

    final payload = {
      'user_id': userId,
      'item_name': product.productName.isNotEmpty ? product.productName : product.title,
      'brand': product.brand,
      'category': section,
      'raw_category': product.category,
      'image_url': product.imageUrl ?? (product.imageUrls.isNotEmpty ? product.imageUrls.first : null),
      'source_url': product.sourceUrl,
      'price': product.priceCurrent,
    };

    try {
      final uri = Uri.parse('$remoteBaseUrl/api/v1/wardrobe');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final saved = WardrobeItem.fromJson(json.decode(utf8.decode(response.bodyBytes)));
        _inMemoryCache.removeWhere((i) => i.id == saved.id);
        _inMemoryCache.insert(0, saved);
        return saved;
      }
    } catch (e) {
      print('Network error adding to wardrobe, saving in-memory: $e');
    }

    // Офлайн режим
    final localItem = WardrobeItem(
      id: DateTime.now().millisecondsSinceEpoch,
      userId: userId,
      itemName: product.productName.isNotEmpty ? product.productName : product.title,
      brand: product.brand,
      category: section,
      rawCategory: product.category,
      imageUrl: product.imageUrl ?? (product.imageUrls.isNotEmpty ? product.imageUrls.first : null),
      sourceUrl: product.sourceUrl,
      price: product.priceCurrent,
      createdAt: DateTime.now(),
    );
    _inMemoryCache.insert(0, localItem);
    return localItem;
  }

  /// Удалить вещь из гардероба (CRUD Delete)
  Future<bool> deleteItem(int itemId, {String userId = 'user_default'}) async {
    _inMemoryCache.removeWhere((i) => i.id == itemId);

    try {
      final uri = Uri.parse('$remoteBaseUrl/api/v1/wardrobe/$itemId?user_id=$userId');
      await http.delete(uri).timeout(const Duration(seconds: 3));
      return true;
    } catch (e) {
      return true;
    }
  }

  bool isItemSaved(String itemName, String brand) {
    return _inMemoryCache.any((i) => i.itemName == itemName && i.brand == brand);
  }
}
