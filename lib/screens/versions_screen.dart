import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/bible_provider.dart';
import '../data/models/bible_version_models.dart';

class VersionsScreen extends StatelessWidget {
  const VersionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bible = Provider.of<BibleProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Bible Versions'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bible.availableVersions.length,
              itemBuilder: (context, index) {
                final version = bible.availableVersions[index];
                return _buildVersionTile(context, version, bible);
              },
            ),
          ),
          _buildDownloadMoreButton(context),
        ],
      ),
    );
  }

  Widget _buildVersionTile(BuildContext context, BibleVersion version, BibleProvider bible) {
    final theme = Theme.of(context);
    final isSelected = bible.currentTranslation == version.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.menu_book_rounded,
            color: isSelected ? const Color(0xFFC67C4E) : Colors.grey[600],
            size: 36,
          ),
        ),
        title: Text(
          version.fullname,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          version.id,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[500],
            letterSpacing: 0.5,
          ),
        ),
        trailing: _buildTrailing(context, version, bible, isSelected),
        onTap: () {
          HapticFeedback.mediumImpact();
          if (version.isDownloaded) {
            bible.setTranslation(version.id);
          } else {
            bible.downloadVersion(version);
          }
        },
      ),
    );
  }

  Widget _buildTrailing(BuildContext context, BibleVersion version, BibleProvider bible, bool isSelected) {
    if (isSelected) {
      return const Icon(Icons.check_circle, color: Colors.orange, size: 24);
    }

    if (!version.isDownloaded) {
      return Icon(Icons.file_download_outlined, color: Colors.white.withValues(alpha: 0.6), size: 24);
    }

    return const SizedBox.shrink();
  }

  Widget _buildDownloadMoreButton(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          // Future: Open external download site or show more mock versions
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('More versions coming soon!')),
          );
        },
        child: Text(
          'DOWNLOAD MORE',
          style: theme.textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
