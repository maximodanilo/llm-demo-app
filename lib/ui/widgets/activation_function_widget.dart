import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:llmdemoapp/core/models/neuron.dart';

/// A widget that visualizes different activation functions
class ActivationFunctionWidget extends StatefulWidget {
  /// The currently selected activation function
  final ActivationFunction activationType;

  /// Callback when activation function changes
  final Function(ActivationFunction type) onActivationChanged;

  const ActivationFunctionWidget({
    Key? key,
    required this.activationType,
    required this.onActivationChanged,
  }) : super(key: key);

  @override
  State<ActivationFunctionWidget> createState() =>
      _ActivationFunctionWidgetState();
}

class _ActivationFunctionWidgetState extends State<ActivationFunctionWidget> {
  // Input value for testing activation functions
  double _inputValue = 0.0;

  // Map of activation function outputs
  final Map<ActivationFunction, double> _outputs = {};

  @override
  void initState() {
    super.initState();
    _calculateOutputs();
  }

  // Calculate outputs for all activation functions
  void _calculateOutputs() {
    _outputs[ActivationFunction.relu] = _applyReLU(_inputValue);
    _outputs[ActivationFunction.sigmoid] = _applySigmoid(_inputValue);
    _outputs[ActivationFunction.tanh] = _applyTanh(_inputValue);
    _outputs[ActivationFunction.linear] = _inputValue;
  }

  // ReLU activation function
  double _applyReLU(double x) {
    return x > 0 ? x : 0;
  }

  // Sigmoid activation function
  double _applySigmoid(double x) {
    return 1 / (1 + math.exp(-x));
  }

  // Tanh activation function
  double _applyTanh(double x) {
    final expX = math.exp(x);
    final expNegX = math.exp(-x);
    return (expX - expNegX) / (expX + expNegX);
  }

  // Calculate derivative for the given activation function
  double _calculateDerivative(ActivationFunction type, double x) {
    switch (type) {
      case ActivationFunction.relu:
        return x > 0 ? 1.0 : 0.0;
      case ActivationFunction.sigmoid:
        final sigmoid = _applySigmoid(x);
        return sigmoid * (1 - sigmoid);
      case ActivationFunction.tanh:
        final tanh = _applyTanh(x);
        return 1 - (tanh * tanh);
      case ActivationFunction.linear:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activation Functions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildActivationSelector(),
        const SizedBox(height: 24),
        _buildInputSlider(),
        const SizedBox(height: 24),
        _buildFunctionGraph(),
        const SizedBox(height: 16),
        _buildOutputTable(),
      ],
    );
  }

  Widget _buildActivationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Activation Function:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildActivationChip(ActivationFunction.relu, 'ReLU'),
            _buildActivationChip(ActivationFunction.sigmoid, 'Sigmoid'),
            _buildActivationChip(ActivationFunction.tanh, 'Tanh'),
            _buildActivationChip(ActivationFunction.linear, 'Linear'),
          ],
        ),
      ],
    );
  }

  Widget _buildActivationChip(ActivationFunction type, String label) {
    final isSelected = widget.activationType == type;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          widget.onActivationChanged(type);
        }
      },
      backgroundColor: isSelected ? null : Colors.grey.shade200,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Widget _buildInputSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Input Value: ${_inputValue.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Slider(
          value: _inputValue,
          min: -5.0,
          max: 5.0,
          divisions: 100,
          label: _inputValue.toStringAsFixed(2),
          onChanged: (value) {
            setState(() {
              _inputValue = value;
              _calculateOutputs();
            });
          },
        ),
      ],
    );
  }

  Widget _buildFunctionGraph() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CustomPaint(
          size: const Size(double.infinity, 200),
          painter: ActivationFunctionPainter(
            activationType: widget.activationType,
            inputValue: _inputValue,
            showDerivative: true,
          ),
        ),
      ),
    );
  }

  Widget _buildOutputTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Function Outputs:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1.5),
            2: FlexColumnWidth(1.5),
          },
          children: [
            const TableRow(
              decoration: BoxDecoration(color: Colors.black12),
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Function',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Output',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Derivative',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            _buildTableRow('ReLU', ActivationFunction.relu),
            _buildTableRow('Sigmoid', ActivationFunction.sigmoid),
            _buildTableRow('Tanh', ActivationFunction.tanh),
            _buildTableRow('Linear', ActivationFunction.linear),
          ],
        ),
      ],
    );
  }

  TableRow _buildTableRow(String name, ActivationFunction type) {
    final isSelected = widget.activationType == type;
    final output = _outputs[type] ?? 0.0;
    final derivative = _calculateDerivative(type, _inputValue);

    return TableRow(
      decoration: BoxDecoration(
        color:
            isSelected
                ? Theme.of(
                  context,
                ).colorScheme.primaryContainer.withOpacity(0.3)
                : null,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(output.toStringAsFixed(4)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(derivative.toStringAsFixed(4)),
        ),
      ],
    );
  }
}

/// Custom painter for activation function visualization
class ActivationFunctionPainter extends CustomPainter {
  final ActivationFunction activationType;
  final double inputValue;
  final bool showDerivative;

  ActivationFunctionPainter({
    required this.activationType,
    required this.inputValue,
    this.showDerivative = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    // Draw coordinate system
    _drawCoordinateSystem(canvas, size);

    // Draw function graph
    paint.color = Colors.blue;
    _drawFunction(canvas, size, paint);

    // Draw derivative if requested
    if (showDerivative) {
      paint.color = Colors.red;
      paint.strokeWidth = 1.5;
      _drawDerivative(canvas, size, paint);
    }

    // Draw current input point
    _drawInputPoint(canvas, size);
  }

  void _drawCoordinateSystem(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey
          ..strokeWidth = 1.0;

    // X-axis
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Y-axis
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    // Draw grid
    paint.color = Colors.grey.withOpacity(0.3);

    // Vertical grid lines
    for (int i = -5; i <= 5; i++) {
      if (i == 0) continue; // Skip the axis
      final x = size.width / 2 + i * size.width / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal grid lines
    for (int i = -2; i <= 2; i++) {
      if (i == 0) continue; // Skip the axis
      final y = size.height / 2 - i * size.height / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // X-axis labels
    for (int i = -5; i <= 5; i += 2) {
      if (i == 0) continue;
      final x = size.width / 2 + i * size.width / 10;

      textPainter.text = TextSpan(
        text: i.toString(),
        style: const TextStyle(color: Colors.black54, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height / 2 + 5),
      );
    }

    // Y-axis labels
    for (int i = -2; i <= 2; i++) {
      if (i == 0) continue;
      final y = size.height / 2 - i * size.height / 4;

      textPainter.text = TextSpan(
        text: i.toString(),
        style: const TextStyle(color: Colors.black54, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size.width / 2 + 5, y - textPainter.height / 2),
      );
    }
  }

  void _drawFunction(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    bool isFirstPoint = true;

    for (int i = 0; i <= size.width; i++) {
      final x = (i / size.width) * 10 - 5; // Map to range -5 to 5
      final y = _calculateFunction(x);

      // Map y to canvas coordinates
      final canvasX = i.toDouble();
      final canvasY = size.height / 2 - y * size.height / 4;

      if (isFirstPoint) {
        path.moveTo(canvasX, canvasY);
        isFirstPoint = false;
      } else {
        path.lineTo(canvasX, canvasY);
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawDerivative(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    bool isFirstPoint = true;

    for (int i = 0; i <= size.width; i++) {
      final x = (i / size.width) * 10 - 5; // Map to range -5 to 5
      final y = _calculateDerivative(x);

      // Map y to canvas coordinates
      final canvasX = i.toDouble();
      final canvasY = size.height / 2 - y * size.height / 4;

      if (isFirstPoint) {
        path.moveTo(canvasX, canvasY);
        isFirstPoint = false;
      } else {
        path.lineTo(canvasX, canvasY);
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawInputPoint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.green
          ..style = PaintingStyle.fill;

    // Map input value to canvas coordinates
    final canvasX = (inputValue + 5) * size.width / 10;
    final y = _calculateFunction(inputValue);
    final canvasY = size.height / 2 - y * size.height / 4;

    // Draw point
    canvas.drawCircle(Offset(canvasX, canvasY), 5, paint);

    // Draw input line
    paint.color = Colors.green.withOpacity(0.5);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;

    canvas.drawLine(
      Offset(canvasX, size.height / 2),
      Offset(canvasX, canvasY),
      paint,
    );

    // Draw output line
    canvas.drawLine(
      Offset(size.width / 2, canvasY),
      Offset(canvasX, canvasY),
      paint,
    );

    // Draw labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.text = TextSpan(
      text: 'x = ${inputValue.toStringAsFixed(2)}',
      style: TextStyle(
        color: Colors.green.shade700,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(canvasX - textPainter.width / 2, size.height / 2 + 20),
    );

    textPainter.text = TextSpan(
      text: 'y = ${y.toStringAsFixed(2)}',
      style: TextStyle(
        color: Colors.green.shade700,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size.width / 2 - textPainter.width - 5,
        canvasY - textPainter.height / 2,
      ),
    );
  }

  double _calculateFunction(double x) {
    switch (activationType) {
      case ActivationFunction.relu:
        return x > 0 ? x : 0;
      case ActivationFunction.sigmoid:
        return 1 / (1 + math.exp(-x));
      case ActivationFunction.tanh:
        final expX = math.exp(x);
        final expNegX = math.exp(-x);
        return (expX - expNegX) / (expX + expNegX);
      case ActivationFunction.linear:
        return x;
    }
  }

  double _calculateDerivative(double x) {
    switch (activationType) {
      case ActivationFunction.relu:
        return x > 0 ? 1.0 : 0.0;
      case ActivationFunction.sigmoid:
        final sigmoid = 1 / (1 + math.exp(-x));
        return sigmoid * (1 - sigmoid);
      case ActivationFunction.tanh:
        final tanh =
            (math.exp(x) - math.exp(-x)) / (math.exp(x) + math.exp(-x));
        return 1 - (tanh * tanh);
      case ActivationFunction.linear:
        return 1.0;
    }
  }

  @override
  bool shouldRepaint(ActivationFunctionPainter oldDelegate) {
    return oldDelegate.activationType != activationType ||
        oldDelegate.inputValue != inputValue ||
        oldDelegate.showDerivative != showDerivative;
  }
}
