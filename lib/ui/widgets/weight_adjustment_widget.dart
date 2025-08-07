import 'package:flutter/material.dart';
import 'package:llmdemoapp/core/models/neuron.dart';

/// A widget that allows interactive adjustment of neuron weights and bias
class WeightAdjustmentWidget extends StatefulWidget {
  /// The neuron to adjust weights for
  final INeuron neuron;
  
  /// Callback when weights or bias are updated
  final Function(List<double> weights, double bias) onWeightsUpdated;

  const WeightAdjustmentWidget({
    Key? key,
    required this.neuron,
    required this.onWeightsUpdated,
  }) : super(key: key);

  @override
  State<WeightAdjustmentWidget> createState() => _WeightAdjustmentWidgetState();
}

class _WeightAdjustmentWidgetState extends State<WeightAdjustmentWidget> {
  // Local copies of weights and bias for UI manipulation
  late List<double> _weights;
  late double _bias;
  
  @override
  void initState() {
    super.initState();
    _weights = List<double>.from(widget.neuron.weights);
    _bias = widget.neuron.bias;
  }
  
  @override
  void didUpdateWidget(WeightAdjustmentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update local copies if neuron changes externally
    if (oldWidget.neuron != widget.neuron) {
      _weights = List<double>.from(widget.neuron.weights);
      _bias = widget.neuron.bias;
    }
  }
  
  // Apply weight changes to the neuron
  void _applyChanges() {
    widget.onWeightsUpdated(_weights, _bias);
  }
  
  // Randomize weights and bias
  void _randomizeWeights() {
    // Create a new neuron with random weights
    final randomNeuron = Neuron(
      inputSize: _weights.length,
      activationType: widget.neuron.activationType,
    );
    
    setState(() {
      _weights = List<double>.from(randomNeuron.weights);
      _bias = randomNeuron.bias;
    });
    
    _applyChanges();
  }
  
  // Reset weights to small values
  void _resetWeights() {
    final resetValue = 0.1;
    
    setState(() {
      _weights = List<double>.filled(_weights.length, resetValue);
      _bias = resetValue;
    });
    
    _applyChanges();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weight & Bias Adjustment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildWeightControls(),
        const SizedBox(height: 16),
        _buildBiasControl(),
        const SizedBox(height: 24),
        _buildActionButtons(),
      ],
    );
  }
  
  Widget _buildWeightControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weights:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(_weights.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text('Weight ${index + 1}:'),
                ),
                Expanded(
                  child: Slider(
                    value: _weights[index],
                    min: -2.0,
                    max: 2.0,
                    divisions: 40,
                    label: _weights[index].toStringAsFixed(2),
                    activeColor: _getWeightColor(_weights[index]),
                    onChanged: (value) {
                      setState(() {
                        _weights[index] = value;
                      });
                    },
                    onChangeEnd: (value) {
                      _applyChanges();
                    },
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    _weights[index].toStringAsFixed(2),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: _getWeightColor(_weights[index]),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
  
  Widget _buildBiasControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bias:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const SizedBox(
              width: 80,
              child: Text('Bias:'),
            ),
            Expanded(
              child: Slider(
                value: _bias,
                min: -2.0,
                max: 2.0,
                divisions: 40,
                label: _bias.toStringAsFixed(2),
                activeColor: _getWeightColor(_bias),
                onChanged: (value) {
                  setState(() {
                    _bias = value;
                  });
                },
                onChangeEnd: (value) {
                  _applyChanges();
                },
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(
                _bias.toStringAsFixed(2),
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: _getWeightColor(_bias),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: _randomizeWeights,
          icon: const Icon(Icons.shuffle),
          label: const Text('Randomize'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade700,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: _resetWeights,
          icon: const Icon(Icons.restart_alt),
          label: const Text('Reset'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
  
  // Get color based on weight value (red for negative, green for positive)
  Color _getWeightColor(double weight) {
    if (weight > 0) {
      // Green shade based on magnitude
      final intensity = (weight / 2.0 * 0.8).clamp(0.0, 0.8);
      return Color.lerp(Colors.green.shade300, Colors.green.shade900, intensity)!;
    } else if (weight < 0) {
      // Red shade based on magnitude
      final intensity = (weight.abs() / 2.0 * 0.8).clamp(0.0, 0.8);
      return Color.lerp(Colors.red.shade300, Colors.red.shade900, intensity)!;
    } else {
      // Zero is gray
      return Colors.grey;
    }
  }
}
