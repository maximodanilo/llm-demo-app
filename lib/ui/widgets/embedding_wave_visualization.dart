import 'dart:math';
import 'package:flutter/material.dart';

/// A widget that visualizes embedding vectors as a wave
class EmbeddingWaveVisualization extends StatelessWidget {
  /// The embedding vector to visualize
  final List<double> embedding;
  
  /// The color of the wave
  final Color waveColor;

  const EmbeddingWaveVisualization({
    Key? key,
    required this.embedding,
    required this.waveColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CustomPaint(
              painter: WavePainter(
                embedding: embedding,
                waveColor: waveColor,
              ),
              size: Size.infinite,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dimensions: ${embedding.length}',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                'Range: [${embedding.reduce(min).toStringAsFixed(2)}, ${embedding.reduce(max).toStringAsFixed(2)}]',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Custom painter that draws the embedding vector as a wave
class WavePainter extends CustomPainter {
  final List<double> embedding;
  final Color waveColor;
  
  WavePainter({
    required this.embedding,
    required this.waveColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (embedding.isEmpty) return;
    
    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    
    final fillPaint = Paint()
      ..color = waveColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final fillPath = Path();
    
    final width = size.width;
    final height = size.height;
    final segmentWidth = width / (embedding.length - 1);
    
    // Find min and max values for normalization
    final minValue = embedding.reduce(min);
    final maxValue = embedding.reduce(max);
    final range = maxValue - minValue;
    
    // Start at the bottom left
    path.moveTo(0, height / 2);
    fillPath.moveTo(0, height);
    fillPath.lineTo(0, height / 2);
    
    for (int i = 0; i < embedding.length; i++) {
      // Normalize the value to be between 0 and 1
      final normalizedValue = (embedding[i] - minValue) / (range > 0 ? range : 1);
      
      // Map to y coordinate (0 at bottom, 1 at top)
      final y = height - (normalizedValue * height);
      final x = i * segmentWidth;
      
      path.lineTo(x, y);
      fillPath.lineTo(x, y);
    }
    
    // Complete the fill path by connecting to the bottom right
    fillPath.lineTo(width, height / 2);
    fillPath.lineTo(width, height);
    fillPath.close();
    
    // Draw the fill first, then the line on top
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
    
    // Draw a horizontal center line
    final centerLinePaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawLine(
      Offset(0, height / 2),
      Offset(width, height / 2),
      centerLinePaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.waveColor != waveColor ||
           oldDelegate.embedding != embedding;
  }
}
