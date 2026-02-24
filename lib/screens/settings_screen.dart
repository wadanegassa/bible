import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/bible_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Consumer<ThemeProvider>(
            builder: (context, theme, child) {
              return SwitchListTile(
                title: const Text('Dark Mode'),
                value: theme.isDarkMode,
                onChanged: (_) => theme.toggleTheme(),
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Font Size',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Consumer<ThemeProvider>(
            builder: (context, theme, child) {
              return Slider(
                min: 14.0,
                max: 32.0,
                divisions: 9,
                label: theme.fontSize.round().toString(),
                value: theme.fontSize,
                onChanged: (value) => theme.setFontSize(value),
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Translation',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Consumer<BibleProvider>(
            builder: (context, bible, child) {
              return Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('English (KJV)'),
                    value: 'KJV',
                    groupValue: bible.currentTranslation,
                    onChanged: (value) => bible.setTranslation(value!),
                  ),
                  RadioListTile<String>(
                    title: const Text('Amharic'),
                    value: 'AMHARIC',
                    groupValue: bible.currentTranslation,
                    onChanged: (value) => bible.setTranslation(value!),
                  ),
                ],
              );
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('About App'),
            subtitle: Text('Holy Bible App v2.0.0'),
          ),
        ],
      ),
    );
  }
}
