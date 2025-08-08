import 'package:flutter/material.dart';

/// A collapsible widget that displays educational content with an expandable/collapsible UI.
/// 
/// This widget provides a consistent way to show educational information across the app
/// while allowing users to collapse it to save space when not needed.
class CollapsibleEducationSection extends StatefulWidget {
  /// The title of the educational section
  final String title;
  
  /// The content to display when expanded
  final Widget content;
  
  /// The color theme for the section
  final Color themeColor;
  
  /// Whether the section should start expanded
  final bool initiallyExpanded;

  const CollapsibleEducationSection({
    super.key,
    required this.title,
    required this.content,
    required this.themeColor,
    this.initiallyExpanded = false,
  });

  @override
  State<CollapsibleEducationSection> createState() => _CollapsibleEducationSectionState();
}

class _CollapsibleEducationSectionState extends State<CollapsibleEducationSection> {
  late bool _isExpanded;
  
  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: widget.themeColor.withOpacity(0.3), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with expand/collapse button
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: widget.themeColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.themeColor,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: widget.themeColor,
                  ),
                ],
              ),
            ),
          ),
          
          // Expandable content
          AnimatedCrossFade(
            firstChild: Container(), // Empty container when collapsed
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
              child: widget.content,
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
