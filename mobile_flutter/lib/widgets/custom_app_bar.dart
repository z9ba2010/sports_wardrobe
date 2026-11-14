import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final int wardrobeCount;
  final VoidCallback onProfilePressed;
  final bool showProfileButton;

  const CustomAppBar({
    Key? key,
    this.title = 'MaxFunFit',
    this.subtitle = 'Спортивный Гардероб',
    this.wardrobeCount = 0,
    required this.onProfilePressed,
    this.showProfileButton = true,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(68.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0F172A),
      elevation: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0x26FF6B00),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0x66FF6B00)),
                ),
                child: const Text(
                  'AI',
                  style: TextStyle(
                    color: Color(0xFFFF6B00),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      actions: [
        if (showProfileButton)
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  tooltip: 'Мой гардероб (Профиль)',
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2563EB),
                      border: Border.all(color: const Color(0xFF60A5FA), width: 1.5),
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 22),
                  ),
                  onPressed: onProfilePressed,
                ),
                if (wardrobeCount > 0)
                  Positioned(
                    top: 6,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B00),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        wardrobeCount > 99 ? '99+' : wardrobeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: const Color(0xFF1E293B),
          height: 1.0,
        ),
      ),
    );
  }
}
