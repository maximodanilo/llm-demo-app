import 'package:flutter/material.dart';
import 'package:llmdemoapp/core/models/embedding_layer.dart';
import 'package:llmdemoapp/core/models/tokenizer.dart';
import 'package:llmdemoapp/ui/steps/training_step_section.dart';
import 'package:llmdemoapp/ui/widgets/collapsible_education_section.dart';
import 'package:llmdemoapp/ui/widgets/positional_encoding_visualization.dart';

/// Widget that demonstrates how positional encoding is added to embeddings
class PositionalEncodingStepSectionImpl extends StatefulWidget
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

  const PositionalEncodingStepSectionImpl({
    super.key,
    required this.title,
    required this.description,
    required this.isEditable,
    required this.isCompleted,
    required this.inputText,
    this.onStepCompleted,
  });
  
  @override
  State<PositionalEncodingStepSectionImpl> createState() => _PositionalEncodingStepSectionImplState();
  
  @override
  bool validate() {
    // This step is valid by default as it's a display of a process
    return true;
  }

}

class _PositionalEncodingStepSectionImplState extends State<PositionalEncodingStepSectionImpl> {
  late EmbeddingLayer _embeddingLayer;
  late ITokenizer _tokenizer;
  late List<List<double>> _embeddings;
  late List<String> _tokens;
  bool _isLoading = true;
  
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
    
    // Initialize embedding layer
    _embeddingLayer = EmbeddingLayer(seed: 42);
    _embeddingLayer.initializeEmbeddings(10000, 32, strategy: EmbeddingInitStrategy.xavier);
    
    // Process the input text to get embeddings
    if (widget.inputText.isNotEmpty) {
      final tokens = _tokenizer.encode(widget.inputText);
      final tokenIds = _tokenizer.tokensToIds(tokens);
      
      // Store tokens for display in the UI (limit to first 5 tokens for clarity)
      _tokens = tokens.length > 5 ? tokens.sublist(0, 5) : tokens;
      
      // Get embeddings for each token (limit to first 5 tokens for clarity)
      final limitedTokenIds = tokenIds.length > 5 ? tokenIds.sublist(0, 5) : tokenIds;
      _embeddings = limitedTokenIds.map((id) => _embeddingLayer.getEmbedding(id)).toList();
    } else {
      // Default empty embeddings if no input text
      _embeddings = [];
      _tokens = [];
    }
    
    setState(() {
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Educational content about positional encoding
        CollapsibleEducationSection(
          title: 'What is Positional Encoding?',
          themeColor: Colors.teal,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Positional encoding adds information about token position in the sequence to the embedding vectors. This is crucial because transformer models process all tokens in parallel and would otherwise lose sequence order information.',
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
                    Text('• Sine/Cosine Functions: Most models use sinusoidal functions at different frequencies'),
                    Text('• Unique Position Signatures: Each position gets a unique encoding pattern'),
                    Text('• Learned vs. Fixed: Some models learn position embeddings, others use fixed formulas'),
                    Text('• Vector Addition: Position vectors are added directly to token embeddings'),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Without positional encoding, the model would treat "The cat chased the mouse" and "The mouse chased the cat" as identical sequences since they contain the same tokens.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Positional encoding visualization
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Positional Encoding Visualization',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'See how positional encoding vectors are added to token embeddings to preserve sequence information:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                
                // Show loading indicator or visualization
                _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _embeddings.isEmpty
                    ? Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.teal.shade200),
                        ),
                        child: const Center(
                          child: Text(
                            'No embeddings available.\nPlease enter some text in the first step.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : PositionalEncodingVisualization(
                        embeddings: _embeddings,
                        tokens: _tokens,
                        themeColor: Colors.teal,
                      ),
              ],
            ),
          ),
        ),
        
        // Formula explanation
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Positional Encoding Formula',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'For position pos and dimension i:',
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
                    'PE(pos, 2i) = sin(pos / 10000^(2i/d))\nPE(pos, 2i+1) = cos(pos / 10000^(2i/d))',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Where d is the embedding dimension. This formula creates a unique pattern for each position that the model can learn to interpret.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        
        // Step completion button
        if (widget.isEditable && !widget.isCompleted)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  // Notify parent that step is complete using the TrainingStepService directly
                  // This avoids the Navigator.pop(true) approach which might be causing issues
                  final TrainingStepSection section = widget;
                  if (section.validate()) {
                    // Show a success message using ScaffoldMessenger
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Step completed successfully!'),
                        backgroundColor: Colors.teal,
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
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Continue to Next Step'),
              ),
            ),
          ),
      ],
    );
  }
}
