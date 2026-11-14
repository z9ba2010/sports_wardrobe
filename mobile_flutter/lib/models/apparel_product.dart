class ApparelProduct {
  final int id;
  final String? skuId;
  final String title;
  final String productName;
  final String brand;
  final String category;
  final String gender;
  final double priceCurrent;
  final double? oldPrice;
  final List<String> imageUrls;
  final String? imageUrl;
  final String sourceUrl;
  final String source;
  final double rating;

  ApparelProduct({
    required this.id,
    this.skuId,
    required this.title,
    required this.productName,
    required this.brand,
    required this.category,
    required this.gender,
    required this.priceCurrent,
    this.oldPrice,
    required this.imageUrls,
    this.imageUrl,
    required this.sourceUrl,
    required this.source,
    this.rating = 4.8,
  });

  factory ApparelProduct.fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    if (json['image_urls'] is List) {
      images = (json['image_urls'] as List).map((e) => e.toString()).toList();
    } else if (json['image_url'] != null) {
      images = [json['image_url'].toString()];
    }

    return ApparelProduct(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      skuId: json['sku_id']?.toString(),
      title: json['title']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? json['title']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      gender: json['gender']?.toString() ?? 'Унисекс',
      priceCurrent: (json['price_current'] as num?)?.toDouble() ?? (json['price'] as num?)?.toDouble() ?? 0.0,
      oldPrice: (json['old_price'] as num?)?.toDouble(),
      imageUrls: images,
      imageUrl: json['image_url']?.toString() ?? (images.isNotEmpty ? images.first : null),
      sourceUrl: json['source_url']?.toString() ?? '',
      source: json['source']?.toString() ?? 'Каталог',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
    );
  }
}
