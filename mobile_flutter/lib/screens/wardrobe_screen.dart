import 'package:flutter/material.dart';
import '../models/wardrobe_item.dart';
import '../services/wardrobe_repository.dart';
import '../widgets/empty_wardrobe_view.dart';

class WardrobeScreen extends StatefulWidget {
  final WardrobeRepository wardrobeRepo;
  final VoidCallback onNavigateToSearch;

  const WardrobeScreen({
    Key? key,
    required this.wardrobeRepo,
    required this.onNavigateToSearch,
  }) : super(key: key);

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, List<WardrobeItem>> _groupedItems = {
    'Обувь': [],
    'Верх': [],
    'Низ': [],
    'Аксессуары': [],
  };
  bool _isLoading = true;

  final List<Map<String, String>> _sections = [
    {'key': 'Обувь', 'title': 'Обувь', 'icon': '👟'},
    {'key': 'Верх', 'title': 'Верх', 'icon': '👕'},
    {'key': 'Низ', 'title': 'Низ', 'icon': '🩳'},
    {'key': 'Аксессуары', 'title': 'Аксессуары', 'icon': '🧢'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _sections.length, vsync: this);
    _loadWardrobe();
  }

  Future<void> _loadWardrobe() async {
    setState(() => _isLoading = true);
    final data = await widget.wardrobeRepo.getGroupedWardrobe('user_default');
    setState(() {
      _groupedItems = data;
      _isLoading = false;
    });
  }

  int get _totalCount {
    int sum = 0;
    _groupedItems.values.forEach((l) => sum += l.length);
    return sum;
  }

  Future<void> _deleteItem(int itemId) async {
    await widget.wardrobeRepo.deleteItem(itemId);
    _loadWardrobe();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
    }

    // Если гардероб пуст (Empty State п. 3 ТЗ)
    if (_totalCount == 0) {
      return EmptyWardrobeView(onGoToSearch: widget.onNavigateToSearch);
    }

    return Column(
      children: [
        // Табы 4 секций: Обувь, Верх, Низ, Аксессуары (ТЗ п. 3)
        Container(
          color: const Color(0xFF0F172A),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: const Color(0xFF3B82F6),
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFF94A3B8),
            tabs: _sections.map((sec) {
              final count = _groupedItems[sec['key']]?.length ?? 0;
              return Tab(
                child: Row(
                  children: [
                    Text(sec['icon']!),
                    const SizedBox(width: 6),
                    Text(sec['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count.toString(),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        // Сетки карточек одежды по секциям
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _sections.map((sec) {
              final items = _groupedItems[sec['key']] ?? [];
              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(sec['icon']!, style: const TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(
                        'В секции «${sec['title']}» пока пусто',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: widget.onNavigateToSearch,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF3B82F6)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Найти в каталоге', style: TextStyle(color: Color(0xFF38BDF8))),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final item = items[i];
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                          child: Container(
                            height: 120,
                            width: double.infinity,
                            color: const Color(0xFF0F172A),
                            child: item.imageUrl != null
                                ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                                : const Icon(Icons.checkroom, color: Colors.grey, size: 36),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.brand, style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(
                                item.itemName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${item.price.toStringAsFixed(0)} ₽',
                                    style: const TextStyle(color: Color(0xFFFF6B00), fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                    onPressed: () => _deleteItem(item.id!),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
