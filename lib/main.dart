import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/cart_provider.dart';
import 'screens/product_list.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: const ReformlyApp(),
    ),
  );
}

class ReformlyApp extends StatelessWidget {
  const ReformlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reformly',
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
