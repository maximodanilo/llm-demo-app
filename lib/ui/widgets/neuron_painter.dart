import 'package:flutter/material.dart';
import 'dart:math';

/// A custom painter that draws a neuron with inputs, weights, and output.
class NeuronPainter extends CustomPainter {
  /// The weights for each input.
  final List<double> weights;
  
  /// The bias term.
  final double bias;
  
  /// The input values.
  final List<double> inputs;
  
  /// The output value.
  final double output;
  
  /// The name of the activation function.
  final String activationFunction;
  
  /// Whether to highlight the weighted sum calculation.
  final bool highlightWeightedSum;
  
  /// Whether to highlight the activation function.
  final bool highlightActivation;
  
  /// Creates a new neuron painter.
  const NeuronPainter({
    required this.weights,
    required this.bias,
    required this.inputs,
    required this.output,
    required this.activationFunction,
    this.highlightWeightedSum = false,
    this.highlightActivation = false,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    
    // Define colors
    final Color inputColor = Colors.blue;
    final Color weightColor = Colors.orange;
    final Color biasColor = Colors.purple;
    final Color outputColor = Colors.green;
    final Color neuronColor = Colors.grey.shade800;
    
    // Define positions
    final double neuronRadius = min(width, height) * 0.15;
    final double inputRadius = neuronRadius * 0.6;
    final Offset neuronCenter = Offset(width * 0.5, height * 0.5);
    
    // Draw inputs
    final int inputCount = inputs.length;
    final double inputSpacing = height / (inputCount + 1);
    
    final List<Offset> inputCenters = [];
    for (int i = 0; i < inputCount; i++) {
      final double y = inputSpacing * (i + 1);
      final Offset inputCenter = Offset(width * 0.15, y);
      inputCenters.add(inputCenter);
      
      // Draw input circle
      final Paint inputPaint = Paint()
        ..color = inputColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(inputCenter, inputRadius, inputPaint);
      
      // Draw input value
      final TextSpan inputSpan = TextSpan(
        text: inputs[i].toStringAsFixed(2),
        style: TextStyle(
          color: Colors.white,
          fontSize: inputRadius * 0.8,
          fontWeight: FontWeight.bold,
        ),
      );
      final TextPainter inputPainter = TextPainter(
        text: inputSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      inputPainter.layout();
      inputPainter.paint(
        canvas,
        inputCenter - Offset(inputPainter.width / 2, inputPainter.height / 2),
      );
      
      // Draw connection line
      final Paint linePaint = Paint()
        ..color = weightColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(inputCenter, neuronCenter, linePaint);
      
      // Draw weight
      final Offset weightCenter = Offset(
        (inputCenter.dx + neuronCenter.dx) / 2,
        (inputCenter.dy + neuronCenter.dy) / 2,
      );
      final Paint weightPaint = Paint()
        ..color = weightColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(weightCenter, inputRadius * 0.7, weightPaint);
      
      final TextSpan weightSpan = TextSpan(
        text: weights[i].toStringAsFixed(2),
        style: TextStyle(
          color: Colors.white,
          fontSize: inputRadius * 0.6,
          fontWeight: FontWeight.bold,
        ),
      );
      final TextPainter weightPainter = TextPainter(
        text: weightSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      weightPainter.layout();
      weightPainter.paint(
        canvas,
        weightCenter - Offset(weightPainter.width / 2, weightPainter.height / 2),
      );
    }
    
    // Draw bias
    final Offset biasCenter = Offset(width * 0.15, height * 0.9);
    final Paint biasPaint = Paint()
      ..color = biasColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(biasCenter, inputRadius, biasPaint);
    
    final TextSpan biasSpan = TextSpan(
      text: bias.toStringAsFixed(2),
      style: TextStyle(
        color: Colors.white,
        fontSize: inputRadius * 0.8,
        fontWeight: FontWeight.bold,
      ),
    );
    final TextPainter biasPainter = TextPainter(
      text: biasSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    biasPainter.layout();
    biasPainter.paint(
      canvas,
      biasCenter - Offset(biasPainter.width / 2, biasPainter.height / 2),
    );
    
    // Draw bias connection
    final Paint biasLinePaint = Paint()
      ..color = biasColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(biasCenter, neuronCenter, biasLinePaint);
    
    // Draw neuron
    final Paint neuronPaint = Paint()
      ..color = neuronColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(neuronCenter, neuronRadius, neuronPaint);
    
    // Draw activation function name
    final TextSpan activationSpan = TextSpan(
      text: activationFunction.toUpperCase(),
      style: TextStyle(
        color: Colors.white,
        fontSize: neuronRadius * 0.5,
        fontWeight: FontWeight.bold,
      ),
    );
    final TextPainter activationPainter = TextPainter(
      text: activationSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    activationPainter.layout();
    activationPainter.paint(
      canvas,
      neuronCenter - Offset(activationPainter.width / 2, activationPainter.height / 2),
    );
    
    // Draw output connection
    final Offset outputCenter = Offset(width * 0.85, height * 0.5);
    final Paint outputLinePaint = Paint()
      ..color = outputColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(neuronCenter, outputCenter, outputLinePaint);
    
    // Draw output
    final Paint outputPaint = Paint()
      ..color = outputColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(outputCenter, inputRadius * 1.2, outputPaint);
    
    final TextSpan outputSpan = TextSpan(
      text: output.toStringAsFixed(2),
      style: TextStyle(
        color: Colors.white,
        fontSize: inputRadius * 0.8,
        fontWeight: FontWeight.bold,
      ),
    );
    final TextPainter outputPainter = TextPainter(
      text: outputSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    outputPainter.layout();
    outputPainter.paint(
      canvas,
      outputCenter - Offset(outputPainter.width / 2, outputPainter.height / 2),
    );
    
    // Draw calculation if highlighted
    if (highlightWeightedSum) {
      final String equation = _buildWeightedSumEquation();
      final TextSpan equationSpan = TextSpan(
        text: equation,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
      final TextPainter equationPainter = TextPainter(
        text: equationSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      equationPainter.layout(maxWidth: width * 0.8);
      
      // Draw background for equation
      final Paint bgPaint = Paint()
        ..color = Colors.yellow.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      final Rect bgRect = Rect.fromLTWH(
        width * 0.1,
        height * 0.1,
        width * 0.8,
        equationPainter.height + 20,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(bgRect, const Radius.circular(8)),
        bgPaint,
      );
      
      equationPainter.paint(
        canvas,
        Offset(width * 0.1 + 10, height * 0.1 + 10),
      );
    }
    
    // Draw activation function if highlighted
    if (highlightActivation) {
      // Calculate weighted sum for display
      double weightedSum = bias;
      for (int i = 0; i < inputs.length; i++) {
        weightedSum += inputs[i] * weights[i];
      }
      
      final String activationText = 'Activation: $activationFunction($weightedSum) = $output';
      final TextSpan activationTextSpan = TextSpan(
        text: activationText,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
      final TextPainter activationTextPainter = TextPainter(
        text: activationTextSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      activationTextPainter.layout(maxWidth: width * 0.8);
      
      // Draw background for activation text
      final Paint bgPaint = Paint()
        ..color = Colors.green.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      final Rect bgRect = Rect.fromLTWH(
        width * 0.1,
        height * 0.8,
        width * 0.8,
        activationTextPainter.height + 20,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(bgRect, const Radius.circular(8)),
        bgPaint,
      );
      
      activationTextPainter.paint(
        canvas,
        Offset(width * 0.1 + 10, height * 0.8 + 10),
      );
    }
  }
  
  String _buildWeightedSumEquation() {
    String equation = 'Sum = $bias';
    
    for (int i = 0; i < inputs.length; i++) {
      equation += ' + (${inputs[i]} × ${weights[i]})';
    }
    
    // Calculate the result
    double weightedSum = bias;
    for (int i = 0; i < inputs.length; i++) {
      weightedSum += inputs[i] * weights[i];
    }
    
    equation += ' = $weightedSum';
    return equation;
  }
  
  @override
  bool shouldRepaint(NeuronPainter oldDelegate) {
    return oldDelegate.weights != weights ||
        oldDelegate.bias != bias ||
        oldDelegate.inputs != inputs ||
        oldDelegate.output != output ||
        oldDelegate.activationFunction != activationFunction ||
        oldDelegate.highlightWeightedSum != highlightWeightedSum ||
        oldDelegate.highlightActivation != highlightActivation;
  }
}
