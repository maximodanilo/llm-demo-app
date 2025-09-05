import 'package:flutter/material.dart';
import 'package:llmdemoapp/core/models/neuron.dart';
import 'package:llmdemoapp/core/services/training_step_service.dart';
import 'package:llmdemoapp/ui/widgets/neuron_painter.dart';
import 'training_step_section.dart';
import 'dart:math' show min;

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
  
  /// The original input text from the first step
  final String? inputText;
  
  /// Callback when the step is completed
  final VoidCallback? onStepCompleted;

  /// Creates a new neuron step section.
  const NeuronStepSectionImpl({
    super.key,
    required this.title,
    required this.description,
    required this.isEditable,
    required this.isCompleted,
    this.inputText,
    this.onStepCompleted,
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
  bool _showContinuePrompt = false;
  
  // Default neuron with 2 inputs
  late Neuron _neuron;
  
  // Output value
  late double _output;
  
  // UI state
  bool _showWeightedSum = false;
  bool _showActivation = false;
  String _selectedActivation = 'relu';
  
  // Controllers for input sliders - will be overridden by embeddings when available
  List<double> _inputValues = [];
  
  // Controllers for weight sliders - will be adjusted based on input size
  List<double> _weightValues = [];
  
  // Controller for bias slider
  double _biasValue = 0.0;
  
  // Selected embedding index from previous step
  int _selectedEmbeddingIndex = 0;
  
  // Embeddings from previous step
  List<List<double>> _embeddings = [];
  List<String> _tokens = [];

  @override
  void initState() {
    super.initState();
    
    // Set default values if no embeddings are available
    _inputValues = [0.0, 0.0];
    _weightValues = [0.5, 0.5];
    
    // Initialize neuron with default values
    _neuron = Neuron(
      weights: _weightValues,
      bias: _biasValue,
      activationFunction: _selectedActivation,
    );
    
    // Calculate initial output with default values
    _output = _neuron.compute(_inputValues);
    
    // Load embeddings from previous step if available
    // This will override the default values if embeddings exist
    _loadEmbeddings();
    
    // Try to load saved state (this takes precedence over embeddings)
    _loadSavedState();
  }
  
  void _loadEmbeddings() {
    try {
      // Get embedding data from step 3 (Embedding Lookup) - not step 4
      final embeddingData = _stepService.getStepInput(3);
      if (embeddingData != null) {
        debugPrint('DEBUG: Embedding data from step 3: ${embeddingData.substring(0, min(100, embeddingData.length))}...');
      }
      
      if (embeddingData != null && embeddingData.isNotEmpty) {
        // Parse the embedding data
        final parts = embeddingData.split('|');
        debugPrint('DEBUG: Split parts length: ${parts.length}');
        
        if (parts.length >= 2) {
          // Format: tokens|embeddings
          final tokenList = parts[0].split(',');
          final embeddingsList = parts[1].split(';');
          
          debugPrint('DEBUG: Found ${tokenList.length} tokens and ${embeddingsList.length} embeddings');
          
          if (tokenList.isNotEmpty && embeddingsList.isNotEmpty && tokenList.length == embeddingsList.length) {
            _tokens = tokenList;
            _embeddings = embeddingsList.map((e) {
              final values = e.split(',').map(double.parse).toList();
              debugPrint('DEBUG: Embedding values: ${values.take(5)}...');
              return values;
            }).toList();
            
            // Use the first embedding as default input values (just the first 2 values)
            if (_embeddings.isNotEmpty && _embeddings[0].length >= 2) {
              _inputValues = _embeddings[0].take(2).toList();
              debugPrint('DEBUG: Using input values: $_inputValues');
              
              // Recalculate neuron output with new input values
              _neuron = Neuron(
                weights: _weightValues,
                bias: _biasValue,
                activationFunction: _selectedActivation,
              );
              _output = _neuron.compute(_inputValues);
              debugPrint('DEBUG: Calculated output: $_output');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading embeddings: $e');
    }
  }
  
  void _loadSavedState() {
    try {
      final savedState = _stepService.getStepInput(7);
      if (savedState != null && savedState.isNotEmpty) {
        final parts = savedState.split('|');
        if (parts.length >= 5) {
          setState(() {
            _selectedEmbeddingIndex = int.parse(parts[0]);
            _inputValues = parts[1].split(',').map(double.parse).toList();
            _weightValues = parts[2].split(',').map(double.parse).toList();
            _biasValue = double.parse(parts[3]);
            _selectedActivation = parts[4];
            
            // Recreate neuron with saved values
            _neuron = Neuron(
              weights: _weightValues,
              bias: _biasValue,
              activationFunction: _selectedActivation,
            );
            
            // Recalculate output
            _output = _neuron.compute(_inputValues);
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading saved state: $e');
    }
  }
  
  void _saveState() {
    if (!widget.isEditable) return;
    
    final stateString = [
      _selectedEmbeddingIndex.toString(),
      _inputValues.join(','),
      _weightValues.join(','),
      _biasValue.toString(),
      _selectedActivation,
    ].join('|');
    
    _stepService.setStepInput(7, stateString);
  }
  
  void _selectEmbedding(int index) {
    if (index < 0 || index >= _embeddings.length) return;
    
    setState(() {
      _selectedEmbeddingIndex = index;
      
      // Use the first two values of the embedding as input
      if (_embeddings[index].length >= 2) {
        _inputValues = _embeddings[index].take(2).toList();
        
        // Recalculate output
        _output = _neuron.compute(_inputValues);
        
        // Save state
        _saveState();
      }
    });
  }
  
  void _updateInputValue(int index, double value) {
    if (index < 0 || index >= _inputValues.length) return;
    
    setState(() {
      _inputValues[index] = value;
      _output = _neuron.compute(_inputValues);
      _saveState();
    });
  }
  
  void _updateWeightValue(int index, double value) {
    if (index < 0 || index >= _weightValues.length) return;
    
    setState(() {
      _weightValues[index] = value;
      _neuron = Neuron(
        weights: _weightValues,
        bias: _biasValue,
        activationFunction: _selectedActivation,
      );
      _output = _neuron.compute(_inputValues);
      _saveState();
    });
  }
  
  void _updateBiasValue(double value) {
    setState(() {
      _biasValue = value;
      _neuron = Neuron(
        weights: _weightValues,
        bias: _biasValue,
        activationFunction: _selectedActivation,
      );
      _output = _neuron.compute(_inputValues);
      _saveState();
    });
  }
  
  void _updateActivationFunction(String function) {
    setState(() {
      _selectedActivation = function;
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Neuron visualization section
          Card(
            elevation: 3,
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
                  
                  // Neuron diagram with interactive element
                  GestureDetector(
                    onTap: widget.isEditable && !widget.isCompleted ? () {
                      setState(() {
                        _showContinuePrompt = true;
                      });
                    } : null,
                    child: Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: _showContinuePrompt ? Border.all(color: Colors.pink, width: 2) : null,
                      ),
                      child: CustomPaint(
                        size: const Size(400, 280),
                        painter: NeuronPainter(
                          weights: _neuron.weights,
                          bias: _neuron.bias,
                          inputs: _inputValues,
                          output: _output,
                          activationFunction: _neuron.activationFunction,
                          highlightWeightedSum: _showWeightedSum,
                          highlightActivation: _showActivation,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Embedding selector (if embeddings are available)
                  if (_embeddings.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Token Embedding:', 
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.pink.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                _tokens.length,
                                (index) => Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ChoiceChip(
                                    label: Text(_tokens[index]),
                                    selected: _selectedEmbeddingIndex == index,
                                    onSelected: widget.isEditable ? (selected) {
                                      if (selected) {
                                        _selectEmbedding(index);
                                      }
                                    } : null,
                                    selectedColor: Colors.pink,
                                    labelStyle: TextStyle(
                                      color: _selectedEmbeddingIndex == index
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Input sliders
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Input Values:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(
                          _inputValues.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Text('Input ${index + 1}: ${_inputValues[index].toStringAsFixed(2)}'),
                                ),
                                Expanded(
                                  child: Slider(
                                    value: _inputValues[index],
                                    min: -1.0,
                                    max: 1.0,
                                    divisions: 20,
                                    label: _inputValues[index].toStringAsFixed(2),
                                    onChanged: widget.isEditable
                                        ? (value) => _updateInputValue(index, value)
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Weight sliders
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Weight Values:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(
                          _weightValues.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Text('Weight ${index + 1}: ${_weightValues[index].toStringAsFixed(2)}'),
                                ),
                                Expanded(
                                  child: Slider(
                                    value: _weightValues[index],
                                    min: -1.0,
                                    max: 1.0,
                                    divisions: 20,
                                    label: _weightValues[index].toStringAsFixed(2),
                                    onChanged: widget.isEditable
                                        ? (value) => _updateWeightValue(index, value)
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Bias slider
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bias Value:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: Text('Bias: ${_biasValue.toStringAsFixed(2)}'),
                            ),
                            Expanded(
                              child: Slider(
                                value: _biasValue,
                                min: -1.0,
                                max: 1.0,
                                divisions: 20,
                                label: _biasValue.toStringAsFixed(2),
                                onChanged: widget.isEditable
                                    ? (value) => _updateBiasValue(value)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Activation function selector
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Activation Function:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: _selectedActivation,
                          onChanged: widget.isEditable
                              ? (value) {
                                  if (value != null) {
                                    _updateActivationFunction(value);
                                  }
                                }
                              : null,
                          items: const [
                            DropdownMenuItem(
                              value: 'relu',
                              child: Text('ReLU'),
                            ),
                            DropdownMenuItem(
                              value: 'sigmoid',
                              child: Text('Sigmoid'),
                            ),
                            DropdownMenuItem(
                              value: 'tanh',
                              child: Text('Tanh'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Output display
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Neuron Output:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.pink.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.pink.shade200),
                          ),
                          child: Text(
                            'Output: ${_output.toStringAsFixed(4)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
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
                          backgroundColor: Colors.pink,
                          duration: Duration(seconds: 1),
                        ),
                      );
                      
                      // Mark this step as completed
                      _stepService.completeStep(7);
                      
                      // Call the onStepCompleted callback if provided
                      if (widget.onStepCompleted != null) {
                        widget.onStepCompleted!();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('View Output Prediction'),
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
                        backgroundColor: Colors.pink,
                        duration: Duration(seconds: 1),
                      ),
                    );
                    
                    // Mark this step as completed
                    _stepService.completeStep(7);
                    
                    // Call the onStepCompleted callback if provided
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

/// Widget to visualize a neuron
class NeuronVisualization extends StatelessWidget {
  final List<double> inputValues;
  final List<double> weightValues;
  final double bias;
  final double output;
  final bool showWeightedSum;
  final bool showActivation;
  final String activationFunction;
  
  const NeuronVisualization({
    super.key,
    required this.inputValues,
    required this.weightValues,
    required this.bias,
    required this.output,
    required this.showWeightedSum,
    required this.showActivation,
    required this.activationFunction,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        size: const Size(400, 280),
        painter: NeuronPainter(
          weights: weightValues,
          bias: bias,
          inputs: inputValues,
          output: output,
          activationFunction: activationFunction,
          highlightWeightedSum: showWeightedSum,
          highlightActivation: showActivation,
        ),
      ),
    );
  }
}
