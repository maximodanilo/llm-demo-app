import 'package:flutter/material.dart';
import 'package:llmdemoapp/ui/steps/training_step_section.dart';
import 'package:llmdemoapp/ui/widgets/collapsible_education_section.dart';

/// Widget that introduces the Feed-Forward Network (FFN) layer in transformer models
class FfnIntroStepSectionImpl extends StatefulWidget implements TrainingStepSection {
  @override
  final String title;
  @override
  final String description;
  @override
  final bool isEditable;
  @override
  final bool isCompleted;
  final String inputText;
  final VoidCallback? onStepCompleted;

  const FfnIntroStepSectionImpl({
    super.key,
    required this.title,
    required this.description,
    required this.isEditable,
    required this.isCompleted,
    required this.inputText,
    this.onStepCompleted,
  });

  @override
  State<FfnIntroStepSectionImpl> createState() => _FfnIntroStepSectionImplState();

  @override
  bool validate() {
    // This step is valid by default as it's an introduction
    return true;
  }
}

class _FfnIntroStepSectionImplState extends State<FfnIntroStepSectionImpl> {
  bool _isLoading = true;
  bool _showContinuePrompt = false;

  @override
  void initState() {
    super.initState();
    // Simulate loading process
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Educational content about FFN
        CollapsibleEducationSection(
          title: 'What is a Feed-Forward Network?',
          themeColor: Colors.indigo,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'A Feed-Forward Network (FFN) is a crucial component in each transformer block. It processes each token embedding independently after the attention mechanism.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Key points about the FFN:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Applies the same transformation to each token position'),
              Text('• Consists of two linear transformations with an activation function in between'),
              Text('• Includes a residual connection and layer normalization'),
              Text('• Enhances the representational power of the model'),
              SizedBox(height: 16),
              Text(
                'In the next steps, we\'ll build this network neuron by neuron and see how it transforms token embeddings.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // FFN overview diagram
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Feed-Forward Network Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Simple FFN diagram
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomPaint(
                      size: const Size(300, 180),
                      painter: FfnDiagramPainter(),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                const Text(
                  'The diagram above shows the basic structure of a Feed-Forward Network in a transformer block. Each token embedding passes through this network independently.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Coffee brewing analogy
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Real-World Analogy: Coffee Brewing',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Coffee icon with interactive element
                    InkWell(
                      onTap: widget.isEditable && !widget.isCompleted ? () {
                        // Find the hidden button and trigger its onPressed
                        setState(() {
                          _showContinuePrompt = true;
                        });
                      } : null,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.brown.shade200,
                          borderRadius: BorderRadius.circular(8),
                          border: _showContinuePrompt ? Border.all(color: Colors.indigo, width: 2) : null,
                        ),
                        child: const Icon(Icons.coffee, size: 48, color: Colors.brown),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Analogy explanation
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Think of the FFN like brewing coffee:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text('• Input beans (x) → Grind beans (W₁·x)'),
                          Text('• Brew grounds (activation/extraction)'),
                          Text('• Filter coffee (W₂·a)'),
                          Text('• Mix with hot water (residual: original + coffee)'),
                          Text('• Stir for uniform taste (LayerNorm)'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Inner continue button that appears after interaction
        if (widget.isEditable && !widget.isCompleted && _showContinuePrompt)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Notify parent that step is complete
                  final TrainingStepSection section = widget;
                  if (section.validate()) {
                    // Show a success message using ScaffoldMessenger
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Step completed successfully!'),
                        backgroundColor: Colors.indigo,
                        duration: Duration(seconds: 1),
                      ),
                    );
                    
                    // Use a callback to notify the parent screen
                    if (widget.onStepCompleted != null) {
                      widget.onStepCompleted!();
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Apply Feed-Forward Network'),
              ),
            ),
          ),

        // Hidden completion trigger (backup)
        if (widget.isEditable && !widget.isCompleted)
          Opacity(
            opacity: 0,
            child: ElevatedButton(
              onPressed: () {
                // Notify parent that step is complete
                final TrainingStepSection section = widget;
                if (section.validate()) {
                  // Show a success message using ScaffoldMessenger
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Step completed successfully!'),
                      backgroundColor: Colors.indigo,
                      duration: Duration(seconds: 1),
                    ),
                  );
                  
                  // Use a callback to notify the parent screen
                  if (widget.onStepCompleted != null) {
                    widget.onStepCompleted!();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const SizedBox.shrink(),
            ),
          ),
      ],
    ),
    );
  }
}

/// Custom painter for drawing a simple FFN diagram
class FfnDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.indigo
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    final fillPaint = Paint()
      ..color = Colors.indigo.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Draw input layer
    final inputX = size.width * 0.1;
    final inputY = size.height * 0.5;
    final inputRadius = size.height * 0.1;
    canvas.drawCircle(Offset(inputX, inputY), inputRadius, fillPaint);
    canvas.drawCircle(Offset(inputX, inputY), inputRadius, paint);
    
    // Draw text for input
    textPainter.text = const TextSpan(
      text: 'x',
      style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(inputX - textPainter.width / 2, inputY - textPainter.height / 2));

    // Draw hidden layer (3 neurons)
    final hiddenX = size.width * 0.5;
    final hiddenY1 = size.height * 0.3;
    final hiddenY2 = size.height * 0.5;
    final hiddenY3 = size.height * 0.7;
    final hiddenRadius = size.height * 0.08;
    
    // Draw hidden neurons
    canvas.drawCircle(Offset(hiddenX, hiddenY1), hiddenRadius, fillPaint);
    canvas.drawCircle(Offset(hiddenX, hiddenY1), hiddenRadius, paint);
    canvas.drawCircle(Offset(hiddenX, hiddenY2), hiddenRadius, fillPaint);
    canvas.drawCircle(Offset(hiddenX, hiddenY2), hiddenRadius, paint);
    canvas.drawCircle(Offset(hiddenX, hiddenY3), hiddenRadius, fillPaint);
    canvas.drawCircle(Offset(hiddenX, hiddenY3), hiddenRadius, paint);
    
    // Draw connections from input to hidden
    canvas.drawLine(Offset(inputX + inputRadius, inputY), Offset(hiddenX - hiddenRadius, hiddenY1), paint);
    canvas.drawLine(Offset(inputX + inputRadius, inputY), Offset(hiddenX - hiddenRadius, hiddenY2), paint);
    canvas.drawLine(Offset(inputX + inputRadius, inputY), Offset(hiddenX - hiddenRadius, hiddenY3), paint);

    // Draw output layer
    final outputX = size.width * 0.9;
    final outputY = size.height * 0.5;
    final outputRadius = size.height * 0.1;
    canvas.drawCircle(Offset(outputX, outputY), outputRadius, fillPaint);
    canvas.drawCircle(Offset(outputX, outputY), outputRadius, paint);
    
    // Draw text for output
    textPainter.text = const TextSpan(
      text: 'y',
      style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(outputX - textPainter.width / 2, outputY - textPainter.height / 2));
    
    // Draw connections from hidden to output
    canvas.drawLine(Offset(hiddenX + hiddenRadius, hiddenY1), Offset(outputX - outputRadius, outputY), paint);
    canvas.drawLine(Offset(hiddenX + hiddenRadius, hiddenY2), Offset(outputX - outputRadius, outputY), paint);
    canvas.drawLine(Offset(hiddenX + hiddenRadius, hiddenY3), Offset(outputX - outputRadius, outputY), paint);
    
    // Draw labels
    final labelStyle = TextStyle(color: Colors.indigo.shade700, fontWeight: FontWeight.bold, fontSize: 10);
    
    // Input label
    textPainter.text = TextSpan(text: 'Input', style: labelStyle);
    textPainter.layout();
    textPainter.paint(canvas, Offset(inputX - textPainter.width / 2, inputY + inputRadius + 5));
    
    // Hidden layer label
    textPainter.text = TextSpan(text: 'Hidden Layer', style: labelStyle);
    textPainter.layout();
    textPainter.paint(canvas, Offset(hiddenX - textPainter.width / 2, size.height - 20));
    
    // Output label
    textPainter.text = TextSpan(text: 'Output', style: labelStyle);
    textPainter.layout();
    textPainter.paint(canvas, Offset(outputX - textPainter.width / 2, outputY + outputRadius + 5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
