import 'dart:math';
import 'package:flutter/material.dart';
import 'package:llmdemoapp/core/models/tokenizer.dart';
import 'package:llmdemoapp/ui/steps/training_step_section.dart';
import 'package:llmdemoapp/ui/widgets/attention_matrix_visualization.dart';
import 'package:llmdemoapp/ui/widgets/collapsible_education_section.dart';

/// Widget that demonstrates how the attention mechanism works in transformer models
class AttentionMechanismStepSectionImpl extends StatefulWidget
    implements TrainingStepSection {
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

  const AttentionMechanismStepSectionImpl({
    super.key,
    required this.title,
    required this.description,
    required this.isEditable,
    required this.isCompleted,
    required this.inputText,
    this.onStepCompleted,
  });
  
  @override
  State<AttentionMechanismStepSectionImpl> createState() => _AttentionMechanismStepSectionImplState();
  
  @override
  bool validate() {
    // This step is valid by default as it's a display of a process
    return true;
  }
}

class _AttentionMechanismStepSectionImplState extends State<AttentionMechanismStepSectionImpl> {
  late ITokenizer _tokenizer;
  late List<String> _tokens;
  late List<List<double>> _attentionMatrix;
  bool _isLoading = true;
  int _selectedTokenIndex = 0;
  final Random _random = Random(42); // Fixed seed for reproducibility
  
  @override
  void initState() {
    super.initState();
    _initializeModels();
  }
  
  void _initializeModels() {
    setState(() {
      _isLoading = true;
    });
    
    // Initialize tokenizer
    _tokenizer = TokenizerFactory.createTokenizer(TokenizerType.word);
    
    // Process the input text to get tokens
    if (widget.inputText.isNotEmpty) {
      final tokens = _tokenizer.encode(widget.inputText);
      
      // Store tokens for display in the UI (limit to first 5 tokens for clarity)
      _tokens = tokens.length > 5 ? tokens.sublist(0, 5) : tokens;
      
      // Generate a simulated attention matrix
      _generateAttentionMatrix();
    } else {
      // Default empty tokens if no input text
      _tokens = [];
      _attentionMatrix = [];
    }
    
    setState(() {
      _isLoading = false;
    });
  }
  
  void _generateAttentionMatrix() {
    final int tokenCount = _tokens.length;
    _attentionMatrix = List.generate(
      tokenCount,
      (i) => List.generate(
        tokenCount,
        (j) {
          // Generate attention values that make linguistic sense
          // Words tend to attend more to themselves and adjacent words
          double value;
          
          if (i == j) {
            // Self-attention is usually high
            value = 0.7 + (_random.nextDouble() * 0.3);
          } else {
            // Base attention value
            value = _random.nextDouble() * 0.6;
            
            // Adjacent tokens have higher attention
            if ((i - j).abs() == 1) {
              value += 0.2;
            }
            
            // Normalize to ensure values are between 0 and 1
            value = value.clamp(0.0, 1.0);
          }
          
          return value;
        },
      ),
    );
    
    // Normalize each row to sum to 1.0 (softmax approximation)
    for (int i = 0; i < tokenCount; i++) {
      double sum = _attentionMatrix[i].fold(0.0, (sum, value) => sum + value);
      for (int j = 0; j < tokenCount; j++) {
        _attentionMatrix[i][j] = _attentionMatrix[i][j] / sum;
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Educational content about attention mechanism
        CollapsibleEducationSection(
          title: 'What is the Attention Mechanism?',
          themeColor: Colors.deepOrange,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'The attention mechanism allows a model to focus on different parts of the input sequence when generating each output. It\'s a key innovation that enables transformers to capture long-range dependencies and relationships between tokens.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                'Key concepts:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 4),
              Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• Query, Key, Value (QKV): Three projections of the input used to compute attention'),
                    Text('• Attention Scores: Measure how much each token should attend to other tokens'),
                    Text('• Multi-Head Attention: Multiple attention mechanisms running in parallel'),
                    Text('• Self-Attention: Tokens attending to other tokens in the same sequence'),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'The attention mechanism is what gives transformers their power to understand context and relationships between words, regardless of their distance in the sequence.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Attention visualization
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attention Visualization',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'See how tokens attend to each other in the sequence. The attention matrix shows the strength of attention between each pair of tokens.',
                ),
                const SizedBox(height: 16),
                
                _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _tokens.isEmpty
                    ? Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.deepOrange.shade200),
                        ),
                        child: const Center(
                          child: Text(
                            'No tokens available.\nPlease enter some text in the first step.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Attention matrix visualization
                          AttentionMatrixVisualization(
                            attentionMatrix: _attentionMatrix,
                            tokens: _tokens,
                            themeColor: Colors.deepOrange,
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Token selector for attention flow
                          Text(
                            'Select a token to see its attention flow:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange.shade700,
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
                                    selected: _selectedTokenIndex == index,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _selectedTokenIndex = index;
                                        });
                                      }
                                    },
                                    selectedColor: Colors.deepOrange,
                                    labelStyle: TextStyle(
                                      color: _selectedTokenIndex == index
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Attention flow visualization
                          AttentionFlowVisualization(
                            attentionMatrix: _attentionMatrix,
                            tokens: _tokens,
                            themeColor: Colors.deepOrange,
                            focusTokenIndex: _selectedTokenIndex,
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
        
        // Attention formula explanation
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attention Formula',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'The scaled dot-product attention is computed as:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Attention(Q, K, V) = softmax(QK^T / √d_k)V',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Where Q (query), K (key), and V (value) are matrices, and d_k is the dimension of the key vectors. The scaling factor √d_k prevents the dot products from growing too large in magnitude.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        
        // The Continue button is now handled by the parent TrainingFlowScreen
      ],
    );
  }
}
