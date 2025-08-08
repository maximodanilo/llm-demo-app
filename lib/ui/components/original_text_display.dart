import 'package:flutter/material.dart';

/// A reusable component to display the original input text in a disabled state
class OriginalTextDisplay extends StatelessWidget {
  /// The original input text to display
  final String text;
  
  /// Optional title to display above the text
  final String? title;
  
  /// Optional color theme for the component
  final Color? themeColor;

  const OriginalTextDisplay({
    super.key,
    required this.text,
    this.title,
    this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveThemeColor = themeColor ?? Colors.grey;
    
    return Card(
      elevation: 1,
      color: effectiveThemeColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: effectiveThemeColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.text_fields, size: 16, color: effectiveThemeColor),
                const SizedBox(width: 8),
                Text(
                  title ?? 'Original Input Text',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: effectiveThemeColor,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Icon(Icons.lock_outline, size: 14, color: effectiveThemeColor.withOpacity(0.7)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: effectiveThemeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: effectiveThemeColor.withOpacity(0.2)),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.black87.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
