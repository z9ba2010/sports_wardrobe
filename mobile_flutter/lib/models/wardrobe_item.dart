class WardrobeItem {
  final int? id;
  final String userId;
  final String itemName;
  final String brand;
  final String category; // 'Обувь', 'Верх', 'Низ', 'Аксессуары'
  final String? imageUrl;
  final String? sourceUrl;
  final double price;
  final String? rawCategory;
  final DateTime? createdAt;

  WardrobeItem({
    this.id,
    required this.userId,
    required this.itemName,
    required this.brand,
    required this.category,
    this.imageUrl,
    this.sourceUrl,
    this.price = 0.0,
    this.rawCategory,
    this.createdAt,
  });

  factory WardrobeItem.fromJson(Map<String, dynamic> json) {
    return WardrobeItem(
      id: json['id'] as int?,
      userId: json['user_id'] ?? 'user_default',
      itemName: json['item_name'] ?? json['title'] ?? '',
      brand: json['brand'] ?? '',
      category: json['category'] ?? 'Аксессуары',
      imageUrl: json['image_url'] as String?,
      sourceUrl: json['source_url'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      rawCategory: json['raw_category'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'item_name': itemName,
      'brand': brand,
      'category': category,
      'image_url': imageUrl,
      'source_url': sourceUrl,
      'price': price,
      'raw_category': rawCategory,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() => toJson();

  factory WardrobeItem.fromMap(Map<String, dynamic> map) => WardrobeItem.fromJson(map);
}
