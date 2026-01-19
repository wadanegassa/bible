import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/bible_provider.dart';
import 'providers/bookmark_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final bibleProvider = BibleProvider();
  // Don't await here to avoid blank screen if network is slow
  bibleProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => bibleProvider),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()..loadBookmarks()),
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'አማርኛ መጽሐፍ ቅዱስ',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(themeProvider.fontSize),
          darkTheme: AppTheme.darkTheme(themeProvider.fontSize),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
        );
      },
    );
  }
}
