import 'package:flutter/material.dart';

/// A widget that visualizes the attention matrix between tokens
class AttentionMatrixVisualization extends StatelessWidget {
  final List<List<double>> attentionMatrix;
  final List<String> tokens;
  final Color themeColor;

  const AttentionMatrixVisualization({
    super.key,
    required this.attentionMatrix,
    required this.tokens,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attention Matrix Visualization',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Attention matrix visualization
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: themeColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with tokens
              Row(
                children: [
                  // Empty top-left cell
                  SizedBox(
                    width: 80,
                    height: 40,
                    child: Center(
                      child: Text(
                        'Token',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                        ),
                      ),
                    ),
                  ),
                  
                  // Token headers
                  ...tokens.map((token) => Expanded(
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      child: Text(
                        token,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )),
                ],
              ),
              
              // Matrix rows
              ...List.generate(tokens.length, (rowIndex) {
                return Row(
                  children: [
                    // Row header with token
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: Center(
                        child: Text(
                          tokens[rowIndex],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    
                    // Attention cells
                    ...List.generate(tokens.length, (colIndex) {
                      final attentionValue = attentionMatrix[rowIndex][colIndex];
                      
                      return Expanded(
                        child: Container(
                          height: 40,
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(attentionValue),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: themeColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              attentionValue.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: attentionValue > 0.5 ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }),
            ],
          ),
        ),
        
        // Legend
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            children: [
              Text(
                'Attention Strength: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
              Expanded(
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        themeColor.withOpacity(0.1),
                        themeColor.withOpacity(0.5),
                        themeColor.withOpacity(1.0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('Low'),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_right_alt),
              const SizedBox(width: 4),
              const Text('High'),
            ],
          ),
        ),
      ],
    );
  }
}

/// A widget that visualizes attention flows between tokens
class AttentionFlowVisualization extends StatelessWidget {
  final List<List<double>> attentionMatrix;
  final List<String> tokens;
  final Color themeColor;
  final int focusTokenIndex;

  const AttentionFlowVisualization({
    super.key,
    required this.attentionMatrix,
    required this.tokens,
    required this.themeColor,
    required this.focusTokenIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attention Flow for "${tokens[focusTokenIndex]}"',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Token flow visualization
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: themeColor.withOpacity(0.3)),
          ),
          height: 120,
          child: CustomPaint(
            size: const Size(double.infinity, 100),
            painter: AttentionFlowPainter(
              attentionMatrix: attentionMatrix,
              tokens: tokens,
              themeColor: themeColor,
              focusTokenIndex: focusTokenIndex,
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for drawing attention flow lines
class AttentionFlowPainter extends CustomPainter {
  final List<List<double>> attentionMatrix;
  final List<String> tokens;
  final Color themeColor;
  final int focusTokenIndex;

  AttentionFlowPainter({
    required this.attentionMatrix,
    required this.tokens,
    required this.themeColor,
    required this.focusTokenIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double tokenWidth = size.width / tokens.length;
    final double tokenHeight = 40;
    final double yPosition = size.height - tokenHeight;
    
    // Draw token boxes
    for (int i = 0; i < tokens.length; i++) {
      final Rect tokenRect = Rect.fromLTWH(
        i * tokenWidth,
        yPosition,
        tokenWidth,
        tokenHeight,
      );
      
      // Draw box
      final Paint boxPaint = Paint()
        ..color = i == focusTokenIndex 
            ? themeColor 
            : themeColor.withOpacity(0.2);
      
      final RRect roundedRect = RRect.fromRectAndRadius(
        tokenRect.deflate(4),
        const Radius.circular(4),
      );
      
      canvas.drawRRect(roundedRect, boxPaint);
      
      // Draw token text
      final textSpan = TextSpan(
        text: tokens[i],
        style: TextStyle(
          color: i == focusTokenIndex ? Colors.white : Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
      
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      
      textPainter.layout(
        minWidth: tokenWidth - 8,
        maxWidth: tokenWidth - 8,
      );
      
      textPainter.paint(
        canvas,
        Offset(
          tokenRect.left + 4,
          tokenRect.top + (tokenHeight - textPainter.height) / 2,
        ),
      );
    }
    
    // Draw attention lines from focus token to other tokens
    final List<double> attentionValues = attentionMatrix[focusTokenIndex];
    final Offset focusTokenCenter = Offset(
      (focusTokenIndex * tokenWidth) + (tokenWidth / 2),
      yPosition + (tokenHeight / 2),
    );
    
    for (int i = 0; i < tokens.length; i++) {
      if (i == focusTokenIndex) continue; // Skip self-attention for clarity
      
      final double attentionValue = attentionValues[i];
      final Offset targetTokenCenter = Offset(
        (i * tokenWidth) + (tokenWidth / 2),
        yPosition + (tokenHeight / 2),
      );
      
      // Control points for curved lines
      final Offset controlPoint1 = Offset(
        focusTokenCenter.dx,
        focusTokenCenter.dy - 30 - (attentionValue * 30),
      );
      
      final Offset controlPoint2 = Offset(
        targetTokenCenter.dx,
        targetTokenCenter.dy - 30 - (attentionValue * 30),
      );
      
      // Draw curved line
      final Paint linePaint = Paint()
        ..color = themeColor.withOpacity(attentionValue)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 + (attentionValue * 3);
      
      final Path path = Path()
        ..moveTo(focusTokenCenter.dx, focusTokenCenter.dy)
        ..cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          targetTokenCenter.dx, targetTokenCenter.dy,
        );
      
      canvas.drawPath(path, linePaint);
      
      // Draw attention value
      final textSpan = TextSpan(
        text: attentionValue.toStringAsFixed(2),
        style: TextStyle(
          color: themeColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.white.withOpacity(0.7),
        ),
      );
      
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      
      // Position the text above the midpoint of the curve
      final Offset textPosition = Offset(
        (focusTokenCenter.dx + targetTokenCenter.dx) / 2 - textPainter.width / 2,
        (controlPoint1.dy + controlPoint2.dy) / 2 - textPainter.height / 2,
      );
      
      textPainter.paint(canvas, textPosition);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
