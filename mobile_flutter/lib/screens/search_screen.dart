import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/apparel_product.dart';
import '../services/parser_api_service.dart';
import '../services/wardrobe_repository.dart';
import '../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  final ParserApiService parserService;
  final WardrobeRepository wardrobeRepo;
  final VoidCallback onItemAdded;

  const SearchScreen({
    Key? key,
    required this.parserService,
    required this.wardrobeRepo,
    required this.onItemAdded,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<ApparelProduct> _products = [];
  bool _isLoading = false;
  bool _isScanning = false;
  int? _addingProductId;
  String _selectedCategory = 'Все';

  final List<String> _filters = ['Все', 'Обувь', 'Футболки', 'Куртки', 'Шорты', 'Тайтсы', 'Носки'];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts({String? query, String? category}) async {
    setState(() => _isLoading = true);
    try {
      final cat = (category ?? _selectedCategory) == 'Все' ? null : (category ?? _selectedCategory);
      final results = await widget.parserService.searchApparel(
        query: query ?? _searchController.text,
        category: cat,
      );
      setState(() => _products = results);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка связи с парсером: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePhotoScan() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1200);
      if (image == null) return;

      setState(() => _isScanning = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI Vision парсера анализирует фото экипировки...'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFFFF6B00),
        ),
      );

      final matches = await widget.parserService.recognizeByPhoto(File(image.path));
      if (matches.isNotEmpty) {
        setState(() => _products = matches);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сканирования: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isScanning = false);
    }
  }

  Future<void> _handleAddToWardrobe(ApparelProduct product) async {
    setState(() => _addingProductId = product.id);
    try {
      await widget.wardrobeRepo.addItemFromApparel(product: product);
      widget.onItemAdded();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('«${product.productName}» добавлено в гардероб!'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось добавить: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _addingProductId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Панель поиска: Текстовая строка + кнопка «Сканер / Поиск по фото»
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Поиск экипировки, бренда, артикула...',
                      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Color(0xFF94A3B8), size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _fetchProducts();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onSubmitted: (val) => _fetchProducts(query: val),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Кнопка «Сканер / Поиск по фото» (ТЗ п. 2)
              ElevatedButton.icon(
                onPressed: _isScanning ? null : _handlePhotoScan,
                icon: _isScanning
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.photo_camera, color: Colors.white, size: 18),
                label: const Text('Фото', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B00),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),

        // Горизонтальные чипы категорий
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = _filters[i];
              final isSel = _selectedCategory == cat;
              return ChoiceChip(
                label: Text(cat, style: TextStyle(color: isSel ? Colors.white : const Color(0xFF94A3B8), fontSize: 12)),
                selected: isSel,
                selectedColor: const Color(0xFF2563EB),
                backgroundColor: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                side: BorderSide(color: isSel ? const Color(0xFF60A5FA) : const Color(0xFF334155)),
                onSelected: (val) {
                  setState(() => _selectedCategory = cat);
                  _fetchProducts(category: cat);
                },
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Сетка результатов из ответа парсера
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
              : _products.isEmpty
                  ? const Center(
                      child: Text('Товары не найдены', style: TextStyle(color: Color(0xFF94A3B8))),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        final isSaved = widget.wardrobeRepo.isItemSaved(product.productName, product.brand);
                        return ProductCard(
                          product: product,
                          isSaved: isSaved,
                          isLoading: _addingProductId == product.id,
                          onAdd: () => _handleAddToWardrobe(product),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
