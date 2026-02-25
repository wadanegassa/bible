import 'package:flutter/material.dart';
import '../data/models/bible_models.dart';

class VerseCardCreator extends StatelessWidget {
  final Verse verse;

  const VerseCardCreator({super.key, required this.verse});

  static void show(BuildContext context, Verse verse) {
    showDialog(
      context: context,
      builder: (context) => VerseCardCreator(verse: verse),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Decorative Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                    ),
                    child: Icon(Icons.auto_stories, color: theme.colorScheme.primary, size: 30),
                  ),
                  const SizedBox(height: 32),
                  
                  // Verse Text
                  Text(
                    '"${verse.text}"',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontSize: 22,
                      height: 1.6,
                      fontFamily: 'Noto Serif',
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Reference
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      verse.reference.toUpperCase(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Action Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildShareAction(context, Icons.download, 'Save'),
                      _buildShareAction(context, Icons.copy, 'Copy'),
                      _buildShareAction(context, Icons.share, 'Share'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Close Button
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareAction(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: Colors.white60),
        ),
      ],
    );
  }
}
