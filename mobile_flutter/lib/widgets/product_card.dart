import 'package:flutter/material.dart';
import '../models/apparel_product.dart';

class ProductCard extends StatelessWidget {
  final ApparelProduct product;
  final bool isSaved;
  final bool isLoading;
  final VoidCallback onAdd;

  const ProductCard({
    Key? key,
    required this.product,
    required this.isSaved,
    required this.isLoading,
    required this.onAdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imgUrl = product.imageUrl ?? (product.imageUrls.isNotEmpty ? product.imageUrls.first : null);
    final formattedPrice = '${product.priceCurrent.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} ₽';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Превью фото и бейдж бренда
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                child: Container(
                  height: 130,
                  width: double.infinity,
                  color: const Color(0xFF0F172A),
                  child: imgUrl != null && imgUrl.isNotEmpty
                      ? Image.network(
                          imgUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.checkroom, color: Colors.grey, size: 36),
                        ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xCC0F172A),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF475569), width: 0.5),
                  ),
                  child: Text(
                    product.brand,
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Информация о товаре
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.category,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                SizedBox(
                  height: 34,
                  child: Text(
                    product.productName.isNotEmpty ? product.productName : product.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formattedPrice,
                  style: const TextStyle(
                    color: Color(0xFFFF6B00),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),

                // Кнопка «Добавить в гардероб»
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: isSaved
                      ? OutlinedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.check, size: 16, color: Color(0xFF10B981)),
                          label: const Text('В гардеробе', style: TextStyle(color: Color(0xFF10B981), fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF10B981)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: isLoading ? null : onAdd,
                          icon: isLoading
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.add, size: 16, color: Colors.white),
                          label: Text(
                            isLoading ? 'Сохранение...' : 'В гардероб',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
