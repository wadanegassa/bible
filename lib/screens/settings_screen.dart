import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader(context, 'Appearance'),
          const SizedBox(height: 16),
          _buildSettingTile(
            context,
            'Dark Mode',
            'Toggle between light and dark themes',
            trailing: Switch.adaptive(
              value: themeProvider.isDarkMode,
              activeColor: theme.colorScheme.primary,
              onChanged: (value) {
                HapticFeedback.mediumImpact();
                themeProvider.toggleTheme();
              },
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'Typography'),
          const SizedBox(height: 16),
          _buildSettingTile(
            context,
            'Reading Font Size',
            'Adjust Bible text size (${themeProvider.fontSize.toInt()}px)',
            subtitleWidget: Slider(
              value: themeProvider.fontSize,
              min: 14,
              max: 32,
              divisions: 9,
              activeColor: theme.colorScheme.primary,
              onChanged: (value) {
                themeProvider.setFontSize(value);
              },
            ),
          ),
          const SizedBox(height: 48),
          _buildSectionHeader(context, 'About'),
          const SizedBox(height: 16),
          _buildSettingTile(
            context,
            'Amharic Bible',
            'A minimalist, high-contrast Bible study experience.',
            trailing: const Icon(Icons.info_outline, size: 20),
          ),
          _buildSettingTile(
            context,
            'Build Version',
            '1.2.0 (Theme Refresh)',
            trailing: Text(
              'PRO',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: 60),
          Center(
            child: Text(
              'MADE WITH ❤️ FOR THE WORD',
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 2,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.0,
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    String subtitle, {
    Widget? trailing,
    Widget? subtitleWidget,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          if (subtitleWidget != null) ...[
            const SizedBox(height: 12),
            subtitleWidget,
          ],
        ],
      ),
    );
  }
}
