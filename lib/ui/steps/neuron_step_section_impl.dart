import 'package:flutter/material.dart';
import 'package:llmdemoapp/core/models/neuron.dart';
import 'package:llmdemoapp/core/services/training_step_service.dart';
import 'package:llmdemoapp/ui/widgets/neuron_painter.dart';
import 'training_step_section.dart';

/// Implementation of the Neuron step in the training flow.
class NeuronStepSectionImpl extends StatefulWidget implements TrainingStepSection {
  @override
  final String title;
  
  @override
  final String description;
  
  @override
  final bool isEditable;
  
  @override
  final bool isCompleted;

  /// Creates a new neuron step section.
  const NeuronStepSectionImpl({
    super.key,
    required this.title,
    required this.description,
    required this.isEditable,
    required this.isCompleted,
  });
  
  @override
  bool validate() {
    final service = TrainingStepService();
    // The step ID is assumed to be 7 for this specific widget.
    // We'll consider this step valid if the user has interacted with it
    final stepData = service.getStepInput(7);
    return stepData != null && stepData.isNotEmpty;
  }

  @override
  State<NeuronStepSectionImpl> createState() => _NeuronStepSectionImplState();
}

class _NeuronStepSectionImplState extends State<NeuronStepSectionImpl> {
  final TrainingStepService _stepService = TrainingStepService();
  
  // Default neuron with 2 inputs
  late Neuron _neuron;
  
  // Output value
  late double _output;
  
  // UI state
  bool _showWeightedSum = false;
  bool _showActivation = false;
  String _selectedActivation = 'relu';
  
  // Controllers for input sliders
  final List<double> _inputValues = [0.5, 0.8];
  
  // Controllers for weight sliders
  final List<double> _weightValues = [0.5, 0.5];
  
  // Controller for bias slider
  double _biasValue = 0.0;

  @override
  void initState() {
    super.initState();
    
    // Initialize neuron
    _neuron = Neuron(
      weights: _weightValues,
      bias: _biasValue,
      activationFunction: _selectedActivation,
    );
    
    // Calculate initial output
    _output = _neuron.compute(_inputValues);
    
    // Try to load saved state
    _loadSavedState();
  }
  
  void _loadSavedState() {
    final savedData = _stepService.getStepInput(7);
    if (savedData != null && savedData.isNotEmpty) {
      try {
        final parts = savedData.split('|');
        if (parts.length >= 5) {
          setState(() {
            _selectedActivation = parts[0];
            _biasValue = double.parse(parts[1]);
            
            final weightParts = parts[2].split(',');
            if (weightParts.length == _weightValues.length) {
              for (int i = 0; i < weightParts.length; i++) {
                _weightValues[i] = double.parse(weightParts[i]);
              }
            }
            
            final inputParts = parts[3].split(',');
            if (inputParts.length == _inputValues.length) {
              for (int i = 0; i < inputParts.length; i++) {
                _inputValues[i] = double.parse(inputParts[i]);
              }
            }
            
            _showWeightedSum = parts[4] == 'true';
            
            if (parts.length > 5) {
              _showActivation = parts[5] == 'true';
            }
            
            // Recreate neuron with loaded values
            _neuron = Neuron(
              weights: _weightValues,
              bias: _biasValue,
              activationFunction: _selectedActivation,
            );
            
            // Recalculate output
            _output = _neuron.compute(_inputValues);
          });
        }
      } catch (e) {
        debugPrint('Error loading saved neuron state: $e');
      }
    }
  }
  
  void _saveState() {
    // Format: activationFunction|bias|weight1,weight2|input1,input2|showWeightedSum|showActivation
    final weightString = _weightValues.map((w) => w.toString()).join(',');
    final inputString = _inputValues.map((i) => i.toString()).join(',');
    final stateString = '$_selectedActivation|$_biasValue|$weightString|$inputString|$_showWeightedSum|$_showActivation';
    _stepService.setStepInput(7, stateString);
  }
  
  void _updateNeuron() {
    setState(() {
      _neuron = Neuron(
        weights: _weightValues,
        bias: _biasValue,
        activationFunction: _selectedActivation,
      );
      _output = _neuron.compute(_inputValues);
      _saveState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(widget.description),
        const SizedBox(height: 16),
        
        // Neuron visualization
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Neuron Visualization',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Neuron diagram
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomPaint(
                      size: const Size(400, 280),
                      painter: NeuronPainter(
                        weights: _weightValues,
                        bias: _biasValue,
                        inputs: _inputValues,
                        output: _output,
                        activationFunction: _selectedActivation,
                        highlightWeightedSum: _showWeightedSum,
                        highlightActivation: _showActivation,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Activation function selector
                Row(
                  children: [
                    const Text('Activation Function:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _selectedActivation,
                      onChanged: widget.isEditable ? (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedActivation = newValue;
                            _updateNeuron();
                          });
                        }
                      } : null,
                      items: const [
                        DropdownMenuItem(value: 'relu', child: Text('ReLU')),
                        DropdownMenuItem(value: 'sigmoid', child: Text('Sigmoid')),
                        DropdownMenuItem(value: 'tanh', child: Text('Tanh')),
                        DropdownMenuItem(value: 'linear', child: Text('Linear')),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Input controls
                const Text('Inputs:', style: TextStyle(fontWeight: FontWeight.bold)),
                for (int i = 0; i < _inputValues.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Text('Input ${i + 1}:'),
                        Expanded(
                          child: Slider(
                            value: _inputValues[i],
                            min: -1.0,
                            max: 1.0,
                            divisions: 20,
                            label: _inputValues[i].toStringAsFixed(2),
                            onChanged: widget.isEditable ? (value) {
                              setState(() {
                                _inputValues[i] = value;
                                _output = _neuron.compute(_inputValues);
                                _saveState();
                              });
                            } : null,
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: Text(_inputValues[i].toStringAsFixed(2)),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Weight controls
                const Text('Weights:', style: TextStyle(fontWeight: FontWeight.bold)),
                for (int i = 0; i < _weightValues.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Text('Weight ${i + 1}:'),
                        Expanded(
                          child: Slider(
                            value: _weightValues[i],
                            min: -1.0,
                            max: 1.0,
                            divisions: 20,
                            label: _weightValues[i].toStringAsFixed(2),
                            onChanged: widget.isEditable ? (value) {
                              setState(() {
                                _weightValues[i] = value;
                                _updateNeuron();
                              });
                            } : null,
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: Text(_weightValues[i].toStringAsFixed(2)),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Bias control
                Row(
                  children: [
                    const Text('Bias:'),
                    Expanded(
                      child: Slider(
                        value: _biasValue,
                        min: -1.0,
                        max: 1.0,
                        divisions: 20,
                        label: _biasValue.toStringAsFixed(2),
                        onChanged: widget.isEditable ? (value) {
                          setState(() {
                            _biasValue = value;
                            _updateNeuron();
                          });
                        } : null,
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: Text(_biasValue.toStringAsFixed(2)),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Visualization controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilterChip(
                      label: const Text('Show Weighted Sum'),
                      selected: _showWeightedSum,
                      onSelected: widget.isEditable ? (selected) {
                        setState(() {
                          _showWeightedSum = selected;
                          _saveState();
                        });
                      } : null,
                    ),
                    FilterChip(
                      label: const Text('Show Activation'),
                      selected: _showActivation,
                      onSelected: widget.isEditable ? (selected) {
                        setState(() {
                          _showActivation = selected;
                          _saveState();
                        });
                      } : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Educational explanation
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How a Neuron Works',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'A neuron is the basic computational unit of a neural network. It works by:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. Receiving input values',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Each input represents a feature or the output from a previous layer.',
                ),
                const SizedBox(height: 8),
                const Text(
                  '2. Applying weights to inputs',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Each input is multiplied by a weight, which determines its importance.',
                ),
                const SizedBox(height: 8),
                const Text(
                  '3. Adding a bias term',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  'A bias term is added to shift the result and help the model fit better.',
                ),
                const SizedBox(height: 8),
                const Text(
                  '4. Applying an activation function',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  'The activation function introduces non-linearity, allowing the network to learn complex patterns.',
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Complete button (if editable)
        if (widget.isEditable && !widget.isCompleted)
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Mark this step as completed
                _stepService.completeStep(7);
              },
              child: const Text('Complete This Step'),
            ),
          ),
      ],
    );
  }
}
