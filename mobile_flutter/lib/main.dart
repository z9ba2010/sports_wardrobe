import 'package:flutter/material.dart';
import 'screens/search_screen.dart';
import 'screens/wardrobe_screen.dart';
import 'services/parser_api_service.dart';
import 'services/wardrobe_repository.dart';
import 'widgets/custom_app_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaxFunFitWardrobeApp());
}

class MaxFunFitWardrobeApp extends StatelessWidget {
  const MaxFunFitWardrobeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MaxFunFit - Спортивный Гардероб',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1120),
        primaryColor: const Color(0xFF2563EB),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2563EB),
          secondary: Color(0xFFFF6B00),
          surface: Color(0xFF1E293B),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          elevation: 0,
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentScreenIndex = 0; // 0 = Search, 1 = Wardrobe
  int _wardrobeCount = 0;

  final ParserApiService _parserService = ParserApiService(
    baseUrl: const String.fromEnvironment('PARSER_API_URL', defaultValue: 'http://10.0.2.2:8000'),
  );

  final WardrobeRepository _wardrobeRepo = WardrobeRepository(
    remoteBaseUrl: const String.fromEnvironment('WARDROBE_API_URL', defaultValue: 'http://10.0.2.2:8000'),
  );

  @override
  void initState() {
    super.initState();
    _refreshWardrobeCount();
  }

  Future<void> _refreshWardrobeCount() async {
    try {
      final grouped = await _wardrobeRepo.getGroupedWardrobe('user_default');
      int count = 0;
      grouped.values.forEach((list) => count += list.length);
      if (mounted) {
        setState(() => _wardrobeCount = count);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isWardrobe = _currentScreenIndex == 1;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'MaxFunFit',
        subtitle: isWardrobe ? 'Мой гардероб' : 'Поиск экипировки',
        wardrobeCount: _wardrobeCount,
        showProfileButton: !isWardrobe,
        onProfilePressed: () {
          setState(() => _currentScreenIndex = 1);
          _refreshWardrobeCount();
        },
      ),
      body: IndexedStack(
        index: _currentScreenIndex,
        children: [
          SearchScreen(
            parserService: _parserService,
            wardrobeRepo: _wardrobeRepo,
            onItemAdded: _refreshWardrobeCount,
          ),
          WardrobeScreen(
            wardrobeRepo: _wardrobeRepo,
            onNavigateToSearch: () {
              setState(() => _currentScreenIndex = 0);
              _refreshWardrobeCount();
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentScreenIndex,
        backgroundColor: const Color(0xFF0F172A),
        selectedItemColor: const Color(0xFFFF6B00),
        unselectedItemColor: const Color(0xFF94A3B8),
        onTap: (index) {
          setState(() => _currentScreenIndex = index);
          _refreshWardrobeCount();
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Поиск',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.checkroom),
                if (_wardrobeCount > 0)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B00),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                      child: Text(
                        _wardrobeCount > 99 ? '99+' : _wardrobeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Гардероб',
          ),
        ],
      ),
    );
  }
}
