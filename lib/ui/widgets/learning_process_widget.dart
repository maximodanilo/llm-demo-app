import 'package:flutter/material.dart';
import 'package:llmdemoapp/core/models/neuron.dart';

/// A widget that visualizes the learning process of a neuron
class LearningProcessWidget extends StatefulWidget {
  /// The neuron to visualize learning for
  final INeuron neuron;
  
  /// Input values for the neuron
  final List<double> inputValues;
  
  /// Current learning rate
  final double learningRate;
  
  /// Callback when learning rate changes
  final Function(double rate) onLearningRateChanged;
  
  /// Callback when training is performed
  final Function(double targetOutput) onTrainingPerformed;

  const LearningProcessWidget({
    Key? key,
    required this.neuron,
    required this.inputValues,
    required this.learningRate,
    required this.onLearningRateChanged,
    required this.onTrainingPerformed,
  }) : super(key: key);

  @override
  State<LearningProcessWidget> createState() => _LearningProcessWidgetState();
}

class _LearningProcessWidgetState extends State<LearningProcessWidget> with SingleTickerProviderStateMixin {
  // Current target output for training
  double _targetOutput = 1.0;
  
  // Current step in the learning process visualization
  int _currentStep = 0;
  
  // Animation controller for step transitions
  late AnimationController _animationController;
  
  // Learning process steps
  final List<String> _steps = [
    'Forward Pass',
    'Calculate Error',
    'Backpropagation',
    'Update Weights',
    'Verify Results',
  ];
  
  // Current neuron output
  double _currentOutput = 0.0;
  
  // Error value
  double _error = 0.0;
  
  // Gradient value
  double _gradient = 0.0;
  
  // Weight updates
  List<double> _weightUpdates = [];
  double _biasUpdate = 0.0;
  
  // Training history for visualization
  final List<_TrainingPoint> _trainingHistory = [];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
    
    // Initialize weight updates
    _weightUpdates = List<double>.filled(widget.neuron.weights.length, 0.0);
    
    // Calculate initial output
    _calculateCurrentOutput();
  }
  
  @override
  void didUpdateWidget(LearningProcessWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.inputValues != widget.inputValues ||
        oldWidget.neuron != widget.neuron) {
      _calculateCurrentOutput();
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  // Calculate current neuron output
  void _calculateCurrentOutput() {
    _currentOutput = widget.neuron.activate(widget.inputValues);
    _error = _targetOutput - _currentOutput;
  }
  
  // Move to the next step in the learning process
  void _nextStep() {
    setState(() {
      if (_currentStep < _steps.length - 1) {
        _currentStep++;
        _animationController.forward(from: 0.0);
        
        // Perform calculations for the current step
        _performStepCalculations();
      } else {
        // Reset to first step
        _currentStep = 0;
        _animationController.forward(from: 0.0);
        _performStepCalculations();
      }
    });
  }
  
  // Perform calculations for the current learning step
  void _performStepCalculations() {
    switch (_currentStep) {
      case 0: // Forward Pass
        _calculateCurrentOutput();
        break;
      case 1: // Calculate Error
        _error = _targetOutput - _currentOutput;
        break;
      case 2: // Backpropagation
        _calculateGradient();
        break;
      case 3: // Update Weights
        _calculateWeightUpdates();
        break;
      case 4: // Verify Results
        // This will be handled by the onTrainingPerformed callback
        widget.onTrainingPerformed(_targetOutput);
        
        // Record training point for history
        _trainingHistory.add(_TrainingPoint(
          targetOutput: _targetOutput,
          actualOutput: _currentOutput,
          error: _error,
        ));
        
        // Keep only the last 10 points
        if (_trainingHistory.length > 10) {
          _trainingHistory.removeAt(0);
        }
        
        // Recalculate output after training
        _calculateCurrentOutput();
        break;
    }
  }
  
  // Calculate gradient for backpropagation
  void _calculateGradient() {
    // For simplicity, we'll calculate a basic gradient
    // In a real implementation, this would depend on the activation function
    switch (widget.neuron.activationType) {
      case ActivationFunction.relu:
        _gradient = _currentOutput > 0 ? _error : 0.0;
        break;
      case ActivationFunction.sigmoid:
        _gradient = _error * _currentOutput * (1 - _currentOutput);
        break;
      case ActivationFunction.tanh:
        _gradient = _error * (1 - _currentOutput * _currentOutput);
        break;
      case ActivationFunction.linear:
        _gradient = _error;
        break;
    }
  }
  
  // Calculate weight updates
  void _calculateWeightUpdates() {
    for (int i = 0; i < _weightUpdates.length; i++) {
      _weightUpdates[i] = widget.learningRate * _gradient * widget.inputValues[i];
    }
    _biasUpdate = widget.learningRate * _gradient;
  }
  
  // Perform full training cycle
  void _performTraining() {
    // Reset to first step
    setState(() {
      _currentStep = 0;
      _performStepCalculations();
    });
    
    // Perform the training
    widget.onTrainingPerformed(_targetOutput);
    
    // Record training point
    _trainingHistory.add(_TrainingPoint(
      targetOutput: _targetOutput,
      actualOutput: _currentOutput,
      error: _error,
    ));
    
    // Keep only the last 10 points
    if (_trainingHistory.length > 10) {
      _trainingHistory.removeAt(0);
    }
    
    // Recalculate output after training
    _calculateCurrentOutput();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Learning Process',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildTargetControls(),
        const SizedBox(height: 16),
        _buildLearningRateControl(),
        const SizedBox(height: 24),
        _buildLearningSteps(),
        const SizedBox(height: 24),
        _buildTrainingHistory(),
      ],
    );
  }
  
  Widget _buildTargetControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Output: ${_targetOutput.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Slider(
          value: _targetOutput,
          min: -1.0,
          max: 1.0,
          divisions: 20,
          label: _targetOutput.toStringAsFixed(2),
          onChanged: (value) {
            setState(() {
              _targetOutput = value;
              _error = _targetOutput - _currentOutput;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Current Output: ${_currentOutput.toStringAsFixed(4)}'),
            Text(
              'Error: ${_error.toStringAsFixed(4)}',
              style: TextStyle(
                color: _error.abs() < 0.1 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildLearningRateControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learning Rate: ${widget.learningRate.toStringAsFixed(3)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Slider(
          value: widget.learningRate,
          min: 0.001,
          max: 0.5,
          divisions: 50,
          label: widget.learningRate.toStringAsFixed(3),
          onChanged: (value) {
            widget.onLearningRateChanged(value);
          },
        ),
        const Text(
          'Tip: Lower learning rates provide more stable but slower learning. '
          'Higher rates learn faster but may oscillate or overshoot.',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
  
  Widget _buildLearningSteps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Learning Steps:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _nextStep,
                  icon: const Icon(Icons.navigate_next),
                  label: const Text('Next Step'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _performTraining,
                  icon: const Icon(Icons.flash_on),
                  label: const Text('Full Cycle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildStepperView(),
      ],
    );
  }
  
  Widget _buildStepperView() {
    return Stepper(
      currentStep: _currentStep,
      controlsBuilder: (context, details) {
        return const SizedBox.shrink(); // Hide default controls
      },
      steps: List.generate(_steps.length, (index) {
        return Step(
          title: Text(_steps[index]),
          content: _buildStepContent(index),
          isActive: _currentStep == index,
          state: _currentStep > index 
              ? StepState.complete 
              : (_currentStep == index ? StepState.editing : StepState.indexed),
        );
      }),
    );
  }
  
  Widget _buildStepContent(int step) {
    switch (step) {
      case 0: // Forward Pass
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The neuron calculates the weighted sum of inputs plus bias, '
              'then applies the activation function.',
            ),
            const SizedBox(height: 8),
            Text('Inputs: ${widget.inputValues.map((e) => e.toStringAsFixed(2)).join(", ")}'),
            Text('Weights: ${widget.neuron.weights.map((e) => e.toStringAsFixed(2)).join(", ")}'),
            Text('Bias: ${widget.neuron.bias.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text(
              'Output: ${_currentOutput.toStringAsFixed(4)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        );
      case 1: // Calculate Error
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The error is calculated as the difference between the target output '
              'and the actual output.',
            ),
            const SizedBox(height: 8),
            Text('Target Output: ${_targetOutput.toStringAsFixed(4)}'),
            Text('Actual Output: ${_currentOutput.toStringAsFixed(4)}'),
            const SizedBox(height: 8),
            Text(
              'Error: ${_error.toStringAsFixed(4)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _error.abs() < 0.1 ? Colors.green : Colors.red,
              ),
            ),
          ],
        );
      case 2: // Backpropagation
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The gradient is calculated based on the error and the derivative '
              'of the activation function.',
            ),
            const SizedBox(height: 8),
            Text('Error: ${_error.toStringAsFixed(4)}'),
            Text('Activation Function: ${widget.neuron.activationType.toString().split('.').last}'),
            const SizedBox(height: 8),
            Text(
              'Gradient: ${_gradient.toStringAsFixed(4)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        );
      case 3: // Update Weights
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The weights and bias are updated based on the gradient, '
              'learning rate, and input values.',
            ),
            const SizedBox(height: 8),
            Text('Learning Rate: ${widget.learningRate.toStringAsFixed(3)}'),
            Text('Gradient: ${_gradient.toStringAsFixed(4)}'),
            const SizedBox(height: 8),
            const Text('Weight Updates:'),
            ...List.generate(_weightUpdates.length, (index) {
              return Text(
                'Weight ${index + 1}: ${widget.neuron.weights[index].toStringAsFixed(4)} - '
                '${_weightUpdates[index].toStringAsFixed(4)} = '
                '${(widget.neuron.weights[index] - _weightUpdates[index]).toStringAsFixed(4)}',
              );
            }),
            Text(
              'Bias: ${widget.neuron.bias.toStringAsFixed(4)} - '
              '${_biasUpdate.toStringAsFixed(4)} = '
              '${(widget.neuron.bias - _biasUpdate).toStringAsFixed(4)}',
            ),
          ],
        );
      case 4: // Verify Results
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'After updating the weights and bias, the neuron output is recalculated '
              'to verify the improvement.',
            ),
            const SizedBox(height: 8),
            Text('Previous Error: ${_error.toStringAsFixed(4)}'),
            Text('New Output: ${_currentOutput.toStringAsFixed(4)}'),
            Text('Target Output: ${_targetOutput.toStringAsFixed(4)}'),
            const SizedBox(height: 8),
            Text(
              'New Error: ${(_targetOutput - _currentOutput).toStringAsFixed(4)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: (_targetOutput - _currentOutput).abs() < _error.abs() 
                    ? Colors.green 
                    : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              (_targetOutput - _currentOutput).abs() < _error.abs()
                  ? 'The error has decreased! Learning is working.'
                  : 'The error has increased. Try adjusting the learning rate.',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildTrainingHistory() {
    if (_trainingHistory.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Training History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: CustomPaint(
            size: const Size(double.infinity, 150),
            painter: TrainingHistoryPainter(
              trainingHistory: _trainingHistory,
              targetOutput: _targetOutput,
            ),
          ),
        ),
      ],
    );
  }
}

/// Data class for tracking training history
class _TrainingPoint {
  final double targetOutput;
  final double actualOutput;
  final double error;
  
  _TrainingPoint({
    required this.targetOutput,
    required this.actualOutput,
    required this.error,
  });
}

/// Custom painter for training history visualization
class TrainingHistoryPainter extends CustomPainter {
  final List<_TrainingPoint> trainingHistory;
  final double targetOutput;
  
  TrainingHistoryPainter({
    required this.trainingHistory,
    required this.targetOutput,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (trainingHistory.isEmpty) return;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Draw coordinate system
    _drawCoordinateSystem(canvas, size);
    
    // Draw target line
    paint.color = Colors.green.withOpacity(0.5);
    canvas.drawLine(
      Offset(0, _mapOutputToY(targetOutput, size)),
      Offset(size.width, _mapOutputToY(targetOutput, size)),
      paint,
    );
    
    // Draw actual output line
    paint.color = Colors.blue;
    _drawHistoryLine(canvas, size, paint, (point) => point.actualOutput);
    
    // Draw error line
    paint.color = Colors.red;
    _drawHistoryLine(canvas, size, paint, (point) => point.error);
    
    // Draw points
    _drawHistoryPoints(canvas, size);
    
    // Draw legend
    _drawLegend(canvas, size);
  }
  
  void _drawCoordinateSystem(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0;
    
    // Draw horizontal center line (zero line)
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
    
    // Draw grid lines
    for (int i = -2; i <= 2; i++) {
      if (i == 0) continue;
      final y = size.height / 2 - i * size.height / 4;
      
      paint.color = Colors.grey.shade200;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
    
    // Draw labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    
    for (int i = -2; i <= 2; i++) {
      final y = size.height / 2 - i * size.height / 4;
      final value = i * 0.5;
      
      textPainter.text = TextSpan(
        text: value.toStringAsFixed(1),
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas, 
        Offset(5, y - textPainter.height / 2),
      );
    }
  }
  
  void _drawHistoryLine(
    Canvas canvas, 
    Size size, 
    Paint paint, 
    double Function(_TrainingPoint point) valueSelector
  ) {
    final path = Path();
    bool isFirstPoint = true;
    
    for (int i = 0; i < trainingHistory.length; i++) {
      final x = i * size.width / (trainingHistory.length - 1);
      final y = _mapOutputToY(valueSelector(trainingHistory[i]), size);
      
      if (isFirstPoint) {
        path.moveTo(x, y);
        isFirstPoint = false;
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
  }
  
  void _drawHistoryPoints(Canvas canvas, Size size) {
    final pointPaint = Paint()
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < trainingHistory.length; i++) {
      final point = trainingHistory[i];
      final x = i * size.width / (trainingHistory.length - 1);
      
      // Draw actual output point
      pointPaint.color = Colors.blue;
      canvas.drawCircle(
        Offset(x, _mapOutputToY(point.actualOutput, size)),
        3,
        pointPaint,
      );
      
      // Draw error point
      pointPaint.color = Colors.red;
      canvas.drawCircle(
        Offset(x, _mapOutputToY(point.error, size)),
        3,
        pointPaint,
      );
    }
  }
  
  void _drawLegend(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );
    
    // Target line
    paint.color = Colors.green.withOpacity(0.5);
    canvas.drawRect(
      Rect.fromLTWH(size.width - 100, 10, 10, 2),
      paint,
    );
    
    textPainter.text = const TextSpan(
      text: 'Target',
      style: TextStyle(
        color: Colors.black87,
        fontSize: 10,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - 85, 5));
    
    // Output line
    paint.color = Colors.blue;
    canvas.drawRect(
      Rect.fromLTWH(size.width - 100, 25, 10, 2),
      paint,
    );
    
    textPainter.text = const TextSpan(
      text: 'Output',
      style: TextStyle(
        color: Colors.black87,
        fontSize: 10,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - 85, 20));
    
    // Error line
    paint.color = Colors.red;
    canvas.drawRect(
      Rect.fromLTWH(size.width - 100, 40, 10, 2),
      paint,
    );
    
    textPainter.text = const TextSpan(
      text: 'Error',
      style: TextStyle(
        color: Colors.black87,
        fontSize: 10,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - 85, 35));
  }
  
  double _mapOutputToY(double output, Size size) {
    // Map output range [-1, 1] to y range [size.height, 0]
    // with 0 at the center (size.height / 2)
    return size.height / 2 - output * size.height / 4;
  }
  
  @override
  bool shouldRepaint(TrainingHistoryPainter oldDelegate) {
    return oldDelegate.trainingHistory != trainingHistory ||
           oldDelegate.targetOutput != targetOutput;
  }
}
