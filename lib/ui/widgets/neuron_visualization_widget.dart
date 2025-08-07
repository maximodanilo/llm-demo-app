import 'package:flutter/material.dart';
import 'package:llmdemoapp/core/models/neuron.dart';

/// A widget that visualizes a neuron with its inputs, weights, and output
class NeuronVisualizationWidget extends StatefulWidget {
  /// The neuron to visualize
  final INeuron neuron;
  
  /// Input values for the neuron
  final List<double> inputValues;
  
  /// Callback when input values change
  final Function(List<double> inputs) onInputChanged;
  
  /// Callback when neuron is activated
  final Function(double output) onActivated;

  const NeuronVisualizationWidget({
    Key? key,
    required this.neuron,
    required this.inputValues,
    required this.onInputChanged,
    required this.onActivated,
  }) : super(key: key);

  @override
  State<NeuronVisualizationWidget> createState() => _NeuronVisualizationWidgetState();
}

class _NeuronVisualizationWidgetState extends State<NeuronVisualizationWidget> with SingleTickerProviderStateMixin {
  // Animation controller for data flow
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  // Track if animation is playing
  bool _isAnimating = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimating = false;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  // Trigger neuron activation with animation
  void _activateNeuron() {
    setState(() {
      _isAnimating = true;
    });
    
    _animationController.reset();
    _animationController.forward().then((_) {
      // Calculate output after animation completes
      final output = widget.neuron.activate(widget.inputValues);
      widget.onActivated(output);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Neuron Visualization',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(double.infinity, 300),
                painter: NeuronPainter(
                  inputValues: widget.inputValues,
                  weights: widget.neuron.weights,
                  bias: widget.neuron.bias,
                  animationValue: _isAnimating ? _animation.value : 0.0,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildInputControls(),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton.icon(
            onPressed: _activateNeuron,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Activate Neuron'),
          ),
        ),
      ],
    );
  }
  
  Widget _buildInputControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Input Values:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(widget.inputValues.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Text('Input ${index + 1}:'),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: widget.inputValues[index],
                    min: -1.0,
                    max: 1.0,
                    divisions: 20,
                    label: widget.inputValues[index].toStringAsFixed(2),
                    onChanged: (value) {
                      final newInputs = List<double>.from(widget.inputValues);
                      newInputs[index] = value;
                      widget.onInputChanged(newInputs);
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    widget.inputValues[index].toStringAsFixed(2),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

/// Custom painter for neuron visualization
class NeuronPainter extends CustomPainter {
  final List<double> inputValues;
  final List<double> weights;
  final double bias;
  final double animationValue;
  
  NeuronPainter({
    required this.inputValues,
    required this.weights,
    required this.bias,
    required this.animationValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    // Calculate positions
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = 30.0;
    
    // Draw neuron body
    paint.color = Colors.purple.shade300;
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);
    
    // Draw bias
    final biasText = 'Bias: ${bias.toStringAsFixed(2)}';
    textPainter.text = TextSpan(
      text: biasText,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 12,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas, 
      Offset(centerX - textPainter.width / 2, centerY + radius + 5),
    );
    
    // Draw inputs and connections
    final inputRadius = 20.0;
    final inputSpacing = size.height / (inputValues.length + 1);
    
    for (int i = 0; i < inputValues.length; i++) {
      final inputY = (i + 1) * inputSpacing;
      final inputX = size.width * 0.2;
      
      // Draw input node
      paint.color = Colors.blue.shade300;
      canvas.drawCircle(Offset(inputX, inputY), inputRadius, paint);
      
      // Draw input value
      final inputText = inputValues[i].toStringAsFixed(2);
      textPainter.text = TextSpan(
        text: inputText,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas, 
        Offset(inputX - textPainter.width / 2, inputY - textPainter.height / 2),
      );
      
      // Draw connection line
      final weight = weights[i];
      final lineWidth = (weight.abs() * 3).clamp(1.0, 5.0);
      paint.color = weight >= 0 ? Colors.green.withOpacity(0.7) : Colors.red.withOpacity(0.7);
      paint.strokeWidth = lineWidth;
      paint.style = PaintingStyle.stroke;
      
      final path = Path();
      path.moveTo(inputX + inputRadius, inputY);
      
      // Determine animation progress point
      if (animationValue > 0) {
        final startX = inputX + inputRadius;
        final startY = inputY;
        final endX = centerX - radius;
        final endY = centerY;
        
        final currentX = startX + (endX - startX) * animationValue;
        final currentY = startY + (endY - startY) * animationValue;
        
        // Draw animated data point
        if (animationValue > 0 && animationValue < 1) {
          paint.style = PaintingStyle.fill;
          paint.color = Colors.yellow;
          canvas.drawCircle(Offset(currentX, currentY), 5, paint);
          paint.style = PaintingStyle.stroke;
          paint.color = weight >= 0 ? Colors.green.withOpacity(0.7) : Colors.red.withOpacity(0.7);
        }
      }
      
      // Draw the connection line
      canvas.drawLine(
        Offset(inputX + inputRadius, inputY),
        Offset(centerX - radius, centerY),
        paint,
      );
      
      // Draw weight label
      final weightText = 'w: ${weight.toStringAsFixed(2)}';
      textPainter.text = TextSpan(
        text: weightText,
        style: TextStyle(
          color: weight >= 0 ? Colors.green.shade800 : Colors.red.shade800,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      
      final midX = (inputX + centerX) / 2;
      final midY = (inputY + centerY) / 2;
      textPainter.paint(
        canvas, 
        Offset(midX - textPainter.width / 2, midY - 15),
      );
    }
    
    // Draw output node
    final outputX = size.width * 0.8;
    paint.color = Colors.orange.shade300;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(outputX, centerY), inputRadius, paint);
    
    // Draw output connection
    paint.color = Colors.purple.shade700;
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(centerX + radius, centerY),
      Offset(outputX - inputRadius, centerY),
      paint,
    );
    
    // Draw animated output data point
    if (animationValue > 0.5) {
      final adjustedAnimation = (animationValue - 0.5) * 2; // Scale 0.5-1.0 to 0-1.0
      if (adjustedAnimation < 1) {
        final startX = centerX + radius;
        final endX = outputX - inputRadius;
        final currentX = startX + (endX - startX) * adjustedAnimation;
        
        paint.style = PaintingStyle.fill;
        paint.color = Colors.yellow;
        canvas.drawCircle(Offset(currentX, centerY), 5, paint);
      }
    }
    
    // Draw labels
    textPainter.text = const TextSpan(
      text: 'Inputs',
      style: TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas, 
      Offset(size.width * 0.2 - textPainter.width / 2, 20),
    );
    
    textPainter.text = const TextSpan(
      text: 'Neuron',
      style: TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas, 
      Offset(centerX - textPainter.width / 2, 20),
    );
    
    textPainter.text = const TextSpan(
      text: 'Output',
      style: TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas, 
      Offset(outputX - textPainter.width / 2, 20),
    );
  }
  
  @override
  bool shouldRepaint(NeuronPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.inputValues != inputValues ||
           oldDelegate.weights != weights ||
           oldDelegate.bias != bias;
  }
}
