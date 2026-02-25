import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/models/bible_models.dart';
import '../providers/bible_provider.dart';
import 'verse_card_creator.dart';

class VerseActionToolbar extends StatelessWidget {
  final Verse verse;
  final Function(String?) onHighlight;
  final VoidCallback onBookmark;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onClose;

  const VerseActionToolbar({
    super.key,
    required this.verse,
    required this.onHighlight,
    required this.onBookmark,
    required this.onCopy,
    required this.onShare,
    required this.onClose,
  });

  static void show(BuildContext context, Verse verse, BibleProvider bible) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      builder: (context) => VerseActionToolbar(
        verse: verse,
        onHighlight: (color) {
          bible.updateHighlight(verse, color);
          Navigator.pop(context);
        },
        onBookmark: () {
          bible.toggleBookmark(verse);
          Navigator.pop(context);
        },
        onCopy: () {
          Clipboard.setData(ClipboardData(text: '${verse.reference}: ${verse.text}'));
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verse copied to clipboard')),
          );
        },
        onShare: () {
          Navigator.pop(context);
          VerseCardCreator.show(context, verse);
        },
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle or top bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Highlight Color Picker
                _buildColorPicker(context),
                const SizedBox(height: 20),
                const Divider(color: Colors.white10),
                const SizedBox(height: 12),
                
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(
                      context,
                      verse.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      'Save',
                      onBookmark,
                      isActive: verse.isBookmarked,
                    ),
                    _buildActionButton(
                      context,
                      Icons.copy,
                      'Copy',
                      onCopy,
                    ),
                    _buildActionButton(
                      context,
                      Icons.share_outlined,
                      'Share',
                      onShare,
                    ),
                    _buildActionButton(
                      context,
                      Icons.close,
                      'Close',
                      onClose,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker(BuildContext context) {
    final colors = {
      'Gold': const Color(0xFFFFD700),
      'Crimson': const Color(0xFFFF4D4D),
      'Sky': const Color(0xFF00BFFF),
      'Mint': const Color(0xFF00FA9A),
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildColorItem(context, null, 'None'), // Reset color
        ...colors.entries.map((e) => _buildColorItem(context, e.value, e.key)),
      ],
    );
  }

  Widget _buildColorItem(BuildContext context, Color? color, String label) {
    final theme = Theme.of(context);
    final String? colorHex = color != null ? '#${color.toARGB32().toRadixString(16).padLeft(8, '0')}' : null;
    final isSelected = verse.highlightColor == colorHex;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onHighlight(colorHex);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color ?? Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected 
                      ? theme.colorScheme.primary 
                      : (color == null ? Colors.white30 : Colors.transparent),
                  width: isSelected ? 3 : 1,
                ),
              ),
              child: color == null 
                  ? const Icon(Icons.format_color_reset, color: Colors.white54, size: 20)
                  : (isSelected ? const Icon(Icons.check, color: Colors.black, size: 20) : null),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected ? theme.colorScheme.primary : Colors.white54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, 
    IconData icon, 
    String label, 
    VoidCallback onTap,
    {bool isActive = false}
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        children: [
          Icon(
            icon, 
            color: isActive ? theme.colorScheme.primary : Colors.white70,
            size: 24,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isActive ? theme.colorScheme.primary : Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
