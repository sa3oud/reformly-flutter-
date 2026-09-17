import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'state/cart_provider.dart';
import 'screens/product_list.dart';
import 'services/supabase_service.dart';
import 'services/deep_link_service.dart';
import 'services/personalization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: const ReformlyApp(),
    ),
  );
}

class ReformlyApp extends StatefulWidget {
  const ReformlyApp({super.key});

  @override
  State<ReformlyApp> createState() => _ReformlyAppState();
}

class _ReformlyAppState extends State<ReformlyApp> {
  final _appLinks = AppLinks();
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // Handle cold start deep link
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        await DeepLinkService.handleIncomingLink(initialLink);
        PersonalizationService().resetCache();
      }
    } catch (_) {}

    // Handle deep links while app is running
    _appLinks.uriLinkStream.listen((uri) async {
      await DeepLinkService.handleIncomingLink(uri);
      PersonalizationService().resetCache();
      // Navigate to home to refresh personalization
      _navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ProductListScreen()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reformly',
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB85C38),
          background: const Color(0xFFFAF8F5),
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF8F5),
        fontFamily: 'SF Pro Display',
        useMaterial3: true,
      ),
      home: const ProductListScreen(),
    );
  }
}
