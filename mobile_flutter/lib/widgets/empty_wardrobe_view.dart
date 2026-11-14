import 'package:flutter/material.dart';

class EmptyWardrobeView extends StatelessWidget {
  final VoidCallback onGoToSearch;

  const EmptyWardrobeView({Key? key, required this.onGoToSearch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0x1F3B82F6),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x4D3B82F6)),
              ),
              child: const Icon(
                Icons.checkroom_outlined,
                size: 46,
                color: Color(0xFF60A5FA),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ваш гардероб пуст',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Найдите и добавьте вещи через каталог экипировки или поиск по фото.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onGoToSearch,
              icon: const Icon(Icons.search, color: Colors.white),
              label: const Text(
                'Найти экипировку',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
