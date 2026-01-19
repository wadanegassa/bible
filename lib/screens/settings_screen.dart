import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

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
          const ListTile(
            title: Text('About App'),
            subtitle: Text('Holy Bible App v2.0.0'),
          ),
        ],
      ),
    );
  }
}
