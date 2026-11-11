import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/theme/app_theme.dart';
import 'providers/bible_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final bibleProvider = BibleProvider();
  bibleProvider.init(isStartup: true);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => bibleProvider),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const AmharicBibleApp(),
    ),
  );
}

class AmharicBibleApp extends StatelessWidget {
  const AmharicBibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, BibleProvider>(
      builder: (context, themeProvider, bible, child) {
        final fontSize =
            themeProvider.fontSize + (bible.familyMode ? 2.0 : 0.0);
        return MaterialApp(
          title: 'Holy Bible',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(fontSize),
          darkTheme: AppTheme.darkTheme(fontSize),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
        );
      },
    );
  }
}
