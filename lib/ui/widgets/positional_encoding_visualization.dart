import 'dart:math';
import 'package:flutter/material.dart';

/// A widget that visualizes positional encoding and how it's added to embeddings
class PositionalEncodingVisualization extends StatefulWidget {
  /// The embedding vectors to visualize
  final List<List<double>> embeddings;
  
  /// The color theme for the visualization
  final Color themeColor;
  
  /// The maximum number of positions to show
  final int maxPositions;

  const PositionalEncodingVisualization({
    Key? key,
    required this.embeddings,
    required this.themeColor,
    this.maxPositions = 5,
  }) : super(key: key);

  @override
  State<PositionalEncodingVisualization> createState() => _PositionalEncodingVisualizationState();
}

class _PositionalEncodingVisualizationState extends State<PositionalEncodingVisualization> {
  late List<List<double>> _positionalEncodings;
  late List<List<double>> _combinedEmbeddings;
  int _selectedPosition = 0;
  bool _showCombined = false;
  
  @override
  void initState() {
    super.initState();
    _generatePositionalEncodings();
  }
  
  @override
  void didUpdateWidget(PositionalEncodingVisualization oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.embeddings != widget.embeddings) {
      _generatePositionalEncodings();
    }
  }
  
  /// Generate positional encodings using the sinusoidal formula
  void _generatePositionalEncodings() {
    final int numEmbeddings = min(widget.embeddings.length, widget.maxPositions);
    final int embeddingDim = widget.embeddings.isNotEmpty ? widget.embeddings[0].length : 0;
    
    _positionalEncodings = List.generate(numEmbeddings, (pos) {
      return List.generate(embeddingDim, (i) {
        if (i % 2 == 0) {
          // Sine for even dimensions
          return sin(pos / pow(10000, (2 * i) / embeddingDim));
        } else {
          // Cosine for odd dimensions
          return cos(pos / pow(10000, (2 * (i - 1)) / embeddingDim));
        }
      });
    });
    
    // Combine embeddings with positional encodings
    _combinedEmbeddings = List.generate(numEmbeddings, (pos) {
      if (pos < widget.embeddings.length) {
        return List.generate(embeddingDim, (i) {
          return widget.embeddings[pos][i] + _positionalEncodings[pos][i];
        });
      } else {
        return List.filled(embeddingDim, 0.0);
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.embeddings.isEmpty) {
      return const Center(child: Text('No embeddings to visualize'));
    }
    
    final int numEmbeddings = min(widget.embeddings.length, widget.maxPositions);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Position selector
        Row(
          children: [
            const Text('Select Position: ', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(numEmbeddings, (pos) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text('Position $pos'),
                        selected: _selectedPosition == pos,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedPosition = pos;
                            });
                          }
                        },
                        selectedColor: widget.themeColor.withValues(alpha: 0.6),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Toggle for showing combined or separate
        Row(
          children: [
            const Text('View Mode: ', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Separate'),
              selected: !_showCombined,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _showCombined = false;
                  });
                }
              },
              selectedColor: widget.themeColor.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Combined'),
              selected: _showCombined,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _showCombined = true;
                  });
                }
              },
              selectedColor: widget.themeColor.withValues(alpha: 0.6),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Visualization
        if (_showCombined) 
          _buildCombinedVisualization()
        else
          _buildSeparateVisualization(),
      ],
    );
  }
  
  Widget _buildSeparateVisualization() {
    final embeddingDim = widget.embeddings[0].length;
    final truncatedDim = min(embeddingDim, 20); // Show at most 20 dimensions for clarity
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Original embedding
        _buildVectorLabel('Token Embedding (E)'),
        _buildVectorVisualization(
          widget.embeddings[_selectedPosition].sublist(0, truncatedDim),
          Colors.purple,
        ),
        const SizedBox(height: 16),
        
        // Positional encoding
        _buildVectorLabel('Positional Encoding (PE)'),
        _buildVectorVisualization(
          _positionalEncodings[_selectedPosition].sublist(0, truncatedDim),
          Colors.teal,
          showGrid: true,
        ),
        const SizedBox(height: 16),
        
        // Addition arrow
        Center(
          child: Icon(
            Icons.add_circle,
            color: Colors.grey.shade700,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        
        // Combined result
        _buildVectorLabel('Combined (E + PE)'),
        _buildVectorVisualization(
          _combinedEmbeddings[_selectedPosition].sublist(0, truncatedDim),
          Colors.orange,
          showBorder: true,
        ),
      ],
    );
  }
  
  Widget _buildCombinedVisualization() {
    final embeddingDim = widget.embeddings[0].length;
    final truncatedDim = min(embeddingDim, 20); // Show at most 20 dimensions for clarity
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildVectorLabel('Combined Visualization'),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: CustomPaint(
            painter: CombinedVectorPainter(
              embedding: widget.embeddings[_selectedPosition].sublist(0, truncatedDim),
              positionalEncoding: _positionalEncodings[_selectedPosition].sublist(0, truncatedDim),
              combined: _combinedEmbeddings[_selectedPosition].sublist(0, truncatedDim),
              themeColor: widget.themeColor,
            ),
            size: Size.infinite,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Embedding', Colors.purple),
            const SizedBox(width: 16),
            _buildLegendItem('Positional Encoding', Colors.teal),
            const SizedBox(width: 16),
            _buildLegendItem('Combined', Colors.orange),
          ],
        ),
      ],
    );
  }
  
  Widget _buildVectorLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
  
  Widget _buildVectorVisualization(List<double> vector, Color color, {bool showGrid = false, bool showBorder = false}) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: showBorder ? Border.all(color: color, width: 2) : null,
      ),
      child: CustomPaint(
        painter: VectorPainter(
          vector: vector,
          color: color,
          showGrid: showGrid,
        ),
        size: Size.infinite,
      ),
    );
  }
  
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

/// Custom painter for visualizing a vector
class VectorPainter extends CustomPainter {
  final List<double> vector;
  final Color color;
  final bool showGrid;
  
  VectorPainter({
    required this.vector,
    required this.color,
    this.showGrid = false,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (vector.isEmpty) return;
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    
    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    final width = size.width;
    final height = size.height;
    final segmentWidth = width / (vector.length - 1);
    
    // Find min and max values for normalization
    final minValue = vector.reduce(min);
    final maxValue = vector.reduce(max);
    final range = maxValue - minValue;
    
    // Draw grid if requested
    if (showGrid) {
      // Horizontal grid lines
      for (int i = 1; i < 4; i++) {
        final y = height * i / 4;
        canvas.drawLine(
          Offset(0, y),
          Offset(width, y),
          gridPaint,
        );
      }
      
      // Vertical grid lines
      for (int i = 0; i < vector.length; i++) {
        final x = i * segmentWidth;
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, height),
          gridPaint,
        );
      }
    }
    
    // Draw the vector as a line
    final path = Path();
    final fillPath = Path();
    
    // Start at the bottom left
    path.moveTo(0, height / 2);
    fillPath.moveTo(0, height);
    fillPath.lineTo(0, height / 2);
    
    for (int i = 0; i < vector.length; i++) {
      // Normalize the value to be between 0 and 1
      final normalizedValue = (vector[i] - minValue) / (range > 0 ? range : 1);
      
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
  bool shouldRepaint(covariant VectorPainter oldDelegate) {
    return oldDelegate.vector != vector ||
           oldDelegate.color != color ||
           oldDelegate.showGrid != showGrid;
  }
}

/// Custom painter for visualizing combined vectors
class CombinedVectorPainter extends CustomPainter {
  final List<double> embedding;
  final List<double> positionalEncoding;
  final List<double> combined;
  final Color themeColor;
  
  CombinedVectorPainter({
    required this.embedding,
    required this.positionalEncoding,
    required this.combined,
    required this.themeColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (embedding.isEmpty) return;
    
    // Use distinct colors for each vector type
    final embeddingPaint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    
    final pePaint = Paint()
      ..color = Colors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    
    final combinedPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    final width = size.width;
    final height = size.height;
    final segmentWidth = width / (embedding.length - 1);
    
    // Find min and max values across all vectors for consistent normalization
    final allValues = [...embedding, ...positionalEncoding, ...combined];
    final minValue = allValues.reduce(min);
    final maxValue = allValues.reduce(max);
    final range = maxValue - minValue;
    
    // Draw grid
    // Horizontal grid lines
    for (int i = 1; i < 4; i++) {
      final y = height * i / 4;
      canvas.drawLine(
        Offset(0, y),
        Offset(width, y),
        gridPaint,
      );
    }
    
    // Vertical grid lines
    for (int i = 0; i < embedding.length; i++) {
      final x = i * segmentWidth;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, height),
        gridPaint,
      );
    }
    
    // Draw the embedding vector
    final embeddingPath = Path();
    embeddingPath.moveTo(0, _normalizeY(embedding[0], minValue, range, height));
    
    for (int i = 1; i < embedding.length; i++) {
      final y = _normalizeY(embedding[i], minValue, range, height);
      final x = i * segmentWidth;
      embeddingPath.lineTo(x, y);
    }
    
    // Draw the positional encoding vector
    final pePath = Path();
    pePath.moveTo(0, _normalizeY(positionalEncoding[0], minValue, range, height));
    
    for (int i = 1; i < positionalEncoding.length; i++) {
      final y = _normalizeY(positionalEncoding[i], minValue, range, height);
      final x = i * segmentWidth;
      pePath.lineTo(x, y);
    }
    
    // Draw the combined vector
    final combinedPath = Path();
    combinedPath.moveTo(0, _normalizeY(combined[0], minValue, range, height));
    
    for (int i = 1; i < combined.length; i++) {
      final y = _normalizeY(combined[i], minValue, range, height);
      final x = i * segmentWidth;
      combinedPath.lineTo(x, y);
    }
    
    // Draw the vectors
    canvas.drawPath(embeddingPath, embeddingPaint);
    canvas.drawPath(pePath, pePaint);
    canvas.drawPath(combinedPath, combinedPaint);
    
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
  
  double _normalizeY(double value, double minValue, double range, double height) {
    final normalizedValue = (value - minValue) / (range > 0 ? range : 1);
    return height - (normalizedValue * height);
  }
  
  @override
  bool shouldRepaint(covariant CombinedVectorPainter oldDelegate) {
    return oldDelegate.embedding != embedding ||
           oldDelegate.positionalEncoding != positionalEncoding ||
           oldDelegate.combined != combined ||
           oldDelegate.themeColor != themeColor;
  }
}
