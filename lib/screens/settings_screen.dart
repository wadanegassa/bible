import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/bible_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SETTINGS',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 20,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          _buildSectionHeader(context, 'APPEARANCE'),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Card(
                child: SwitchListTile(
                  title: Text(
                    'Dark Mode',
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Toggle between royal gold and onyx themes'),
                  value: themeProvider.isDarkMode,
                  activeColor: theme.colorScheme.primary,
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'TEXT SIZE'),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Slider(
                    min: 14.0,
                    max: 32.0,
                    divisions: 9,
                    label: themeProvider.fontSize.round().toString(),
                    value: themeProvider.fontSize,
                    activeColor: theme.colorScheme.primary,
                    inactiveColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    onChanged: (value) => themeProvider.setFontSize(value),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'TRANSLATION'),
          Consumer<BibleProvider>(
            builder: (context, bible, child) {
              return Card(
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('English (KJV)'),
                      value: 'KJV',
                      groupValue: bible.currentTranslation,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (value) => bible.setTranslation(value!),
                    ),
                    Divider(height: 1, indent: 16, endIndent: 16, color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                    RadioListTile<String>(
                      title: const Text('Amharic'),
                      value: 'AMHARIC',
                      groupValue: bible.currentTranslation,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (value) => bible.setTranslation(value!),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Icon(Icons.auto_stories, color: theme.colorScheme.primary.withValues(alpha: 0.3), size: 40),
                const SizedBox(height: 12),
                Text(
                  'HOLY BIBLE APP',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    letterSpacing: 3,
                  ),
                ),
                Text(
                  'Version 2.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
