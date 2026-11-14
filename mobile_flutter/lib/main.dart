import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  static const String _defaultParserUrl = String.fromEnvironment(
    'PARSER_API_URL',
    defaultValue: 'http://192.168.0.175:8000',
  );
  static const String _defaultWardrobeUrl = String.fromEnvironment(
    'WARDROBE_API_URL',
    defaultValue: 'http://192.168.0.175:8001',
  );

  int _currentScreenIndex = 0; // 0 = Search, 1 = Wardrobe
  int _wardrobeCount = 0;
  int _configVersion = 0;
  bool _prefsLoaded = false;

  late final ParserApiService _parserService;
  late final WardrobeRepository _wardrobeRepo;

  @override
  void initState() {
    super.initState();
    _parserService = ParserApiService(baseUrl: _defaultParserUrl);
    _wardrobeRepo = WardrobeRepository(remoteBaseUrl: _defaultWardrobeUrl);
    _loadSettingsAndInit();
  }

  Future<void> _loadSettingsAndInit() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedParser = prefs.getString('parser_api_url');
      final savedWardrobe = prefs.getString('wardrobe_api_url');
      if (savedParser != null && savedParser.isNotEmpty) {
        _parserService.baseUrl = savedParser;
      }
      if (savedWardrobe != null && savedWardrobe.isNotEmpty) {
        _wardrobeRepo.remoteBaseUrl = savedWardrobe;
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _prefsLoaded = true);
      _refreshWardrobeCount();
    }
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

  Future<void> _showServerSettingsDialog() async {
    final parserCtrl = TextEditingController(text: _parserService.baseUrl);
    final wardrobeCtrl = TextEditingController(text: _wardrobeRepo.remoteBaseUrl);

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Настройки сервера', style: TextStyle(color: Colors.white, fontSize: 18)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Укажите IP-адрес ПК в локальной сети (например, http://192.168.0.175:8000) или URL сервера.',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
              const SizedBox(height: 14),
              const Text('API Парсера (порт 8000)', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
              const SizedBox(height: 6),
              TextField(
                controller: parserCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  hintText: 'http://192.168.0.175:8000',
                  hintStyle: const TextStyle(color: Color(0xFF64748B)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              const Text('API Гардероба (порт 8001)', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
              const SizedBox(height: 6),
              TextField(
                controller: wardrobeCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  hintText: 'http://192.168.0.175:8001',
                  hintStyle: const TextStyle(color: Color(0xFF64748B)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Отмена', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
            child: const Text('Сохранить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (saved == true) {
      final newParser = parserCtrl.text.trim().replaceAll(RegExp(r'/+$'), '');
      final newWardrobe = wardrobeCtrl.text.trim().replaceAll(RegExp(r'/+$'), '');
      if (newParser.isNotEmpty) _parserService.baseUrl = newParser;
      if (newWardrobe.isNotEmpty) _wardrobeRepo.remoteBaseUrl = newWardrobe;

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('parser_api_url', _parserService.baseUrl);
        await prefs.setString('wardrobe_api_url', _wardrobeRepo.remoteBaseUrl);
      } catch (_) {}

      if (mounted) {
        setState(() => _configVersion++);
        _refreshWardrobeCount();
      }
    }
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
        onSettingsPressed: _showServerSettingsDialog,
        onProfilePressed: () {
          setState(() => _currentScreenIndex = 1);
          _refreshWardrobeCount();
        },
      ),
      body: !_prefsLoaded
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
          : IndexedStack(
              index: _currentScreenIndex,
              children: [
                SearchScreen(
                  key: ValueKey('search_$_configVersion'),
                  parserService: _parserService,
                  wardrobeRepo: _wardrobeRepo,
                  onItemAdded: _refreshWardrobeCount,
                ),
                WardrobeScreen(
                  key: ValueKey('wardrobe_${_configVersion}_$_currentScreenIndex'),
                  wardrobeRepo: _wardrobeRepo,
                  onNavigateToSearch: () {
                    setState(() => _currentScreenIndex = 0);
                    _refreshWardrobeCount();
                  },
                ),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _currentScreenIndex,
            elevation: 0,
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
        ),
      ),
    );
  }
}
