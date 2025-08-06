import 'package:flutter/material.dart';
import 'package:llmdemoapp/core/models/embedding_layer.dart';
import 'package:llmdemoapp/core/models/tokenizer.dart';
import 'package:llmdemoapp/core/models/vocabulary.dart';

/// Screen to demonstrate how tokens are converted to embedding vectors
class EmbeddingScreen extends StatefulWidget {
  final ITokenizer tokenizer;
  final List<String> tokens;
  final List<int> tokenIds;

  const EmbeddingScreen({
    Key? key,
    required this.tokenizer,
    required this.tokens,
    required this.tokenIds,
  }) : super(key: key);

  @override
  State<EmbeddingScreen> createState() => _EmbeddingScreenState();
}

class _EmbeddingScreenState extends State<EmbeddingScreen> {
  late final IVocabulary _vocabulary;
  late final Map<String, int> _vocabularyMap;
  
  // Embedding dimension
  final int _embeddingDim = 8;
  
  // Embedding layer
  late final IEmbeddingLayer _embeddingLayer;
  
  // Map of token IDs to embedding vectors
  late final Map<int, List<double>> _embeddings;
  
  // Selected token for detailed view
  String? _selectedToken;
  int? _selectedTokenId;
  
  // Show full embedding matrix
  bool _showFullMatrix = false;
  
  // Example sentences for demonstration
  final List<String> _exampleSentences = [
    "The cat is sleeping on the mat",
    "The dog is sleeping on the mat"
  ];
  
  // Highlighted tokens in example sentences
  final Set<String> _highlightedTokens = {"is"};
  
  // Embedding visualization settings
  double _cellSize = 40.0;
  double _minValue = -1.0;
  double _maxValue = 1.0;
  
  @override
  void initState() {
    super.initState();
    _vocabulary = widget.tokenizer.vocabulary;
    _vocabularyMap = _vocabulary.getVocabularyMap();
    
    // Initialize embedding layer
    _embeddingLayer = EmbeddingLayer(seed: 42);
    _embeddingLayer.initializeEmbeddings(
      _vocabulary.getSize(),
      _embeddingDim
    );
    
    // Generate embeddings map for easy access
    _embeddings = {};
    for (final entry in _vocabularyMap.entries) {
      _embeddings[entry.value] = _embeddingLayer.getEmbedding(entry.value);
    }
    
    // Select the first token by default if available
    if (widget.tokens.isNotEmpty) {
      _selectedToken = widget.tokens[0];
      _selectedTokenId = widget.tokenIds[0];
    }
  }
  

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Embedding Layer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTokenSelector(),
              const SizedBox(height: 24),
              _buildEmbeddingVisualization(),
              const SizedBox(height: 24),
              _buildExampleSentences(),
              const SizedBox(height: 24),
              _buildMatrixExpander(),
              const SizedBox(height: 24),
              _buildEmbeddingExplanation(),
              const SizedBox(height: 24),
              _buildNextStepButton(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTokenSelector() {
    // Get all tokens from vocabulary for selection
    final allTokens = _vocabularyMap.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select a token to view its embedding vector:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: allTokens.length,
            itemBuilder: (context, index) {
              final entry = allTokens[index];
              final token = entry.key;
              final tokenId = entry.value;
              final isSelected = token == _selectedToken;
              final isHighlighted = _highlightedTokens.contains(token);
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(token),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedToken = token;
                        _selectedTokenId = tokenId;
                      });
                    }
                  },
                  labelStyle: TextStyle(
                    fontWeight: isSelected || isHighlighted ? FontWeight.bold : FontWeight.normal,
                  ),
                  avatar: CircleAvatar(
                    radius: 12,
                    backgroundColor: isSelected 
                        ? Theme.of(context).colorScheme.primary
                        : isHighlighted
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.surfaceVariant,
                    child: Text(
                      '$tokenId',
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected 
                            ? Theme.of(context).colorScheme.onPrimary
                            : isHighlighted
                                ? Theme.of(context).colorScheme.onSecondary
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildEmbeddingVisualization() {
    if (_selectedToken == null || _selectedTokenId == null) {
      return const Center(
        child: Text('Select a token to view its embedding'),
      );
    }
    
    final embedding = _embeddings[_selectedTokenId!] ?? [];
    if (embedding.isEmpty) {
      return const Center(
        child: Text('No embedding found for this token'),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Embedding vector for "$_selectedToken" (ID: $_selectedTokenId):',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            // Dimension labels
            Column(
              children: [
                SizedBox(height: _cellSize / 2),
                ...List.generate(_embeddingDim, (index) => SizedBox(
                  height: _cellSize,
                  width: 30,
                  child: Center(
                    child: Text(
                      'D${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )),
              ],
            ),
            // Embedding visualization
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Value scale
                    Row(
                      children: [
                        SizedBox(
                          width: _cellSize * 2,
                          child: const Center(
                            child: Text(
                              'Negative',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _cellSize * 2,
                          child: const Center(
                            child: Text(
                              'Neutral',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _cellSize * 2,
                          child: const Center(
                            child: Text(
                              'Positive',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Color scale
                    Container(
                      height: 10,
                      width: _cellSize * 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade900,
                            Colors.blue.shade300,
                            Colors.grey.shade300,
                            Colors.red.shade300,
                            Colors.red.shade900,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Embedding cells
                    ...List.generate(_embeddingDim, (dimIndex) {
                      final value = embedding[dimIndex];
                      final normalizedValue = (value - _minValue) / (_maxValue - _minValue);
                      
                      // Color based on value (blue for negative, red for positive)
                      final color = value < 0
                          ? Color.lerp(Colors.blue.shade900, Colors.blue.shade300, normalizedValue * 2)!
                          : Color.lerp(Colors.grey.shade300, Colors.red.shade900, normalizedValue / 2)!;
                      
                      return Container(
                        height: _cellSize,
                        width: _cellSize * 6,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            // Colored cell representing the value
                            Container(
                              width: _cellSize * 6 * normalizedValue,
                              color: color,
                            ),
                            // Value text
                            Expanded(
                              child: Center(
                                child: Text(
                                  value.toStringAsFixed(2),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildEmbeddingExplanation() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What are Embeddings?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Embeddings are dense vector representations of tokens in a continuous vector space. '
              'Each dimension captures some semantic aspect of the token. '
              'Similar tokens have similar embedding vectors.',
            ),
            const SizedBox(height: 8),
            const Text(
              'In real language models, embeddings typically have 256-1024 dimensions. '
              'Here we show a simplified 8-dimensional representation for educational purposes.',
            ),
            const SizedBox(height: 8),
            const Text(
              'Notice how in the example sentences, only the word "is" is highlighted. '
              'This demonstrates how the same token shares the same embedding across different contexts. '
              'The embedding for "is" is identical whether it appears in "The cat is sleeping" or "The dog is sleeping".',
            ),
            const SizedBox(height: 8),
            Text(
              'Note: These embeddings are initialized with Xavier/Glorot initialization for demonstration. '
              'Real embeddings are learned during model training to capture semantic relationships.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNextStepButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Navigate to the next screen in the LLM demo flow
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => NextScreen(
          //       tokenizer: widget.tokenizer,
          //       tokens: widget.tokens,
          //       tokenIds: widget.tokenIds,
          //       embeddings: _embeddings,
          //     ),
          //   ),
          // );
          
          // For now, just show a message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Next step will be implemented soon!'),
            ),
          );
        },
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Next Step: Attention Mechanism'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
  
  Widget _buildExampleSentences() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Example Sentences',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._exampleSentences.map((sentence) => _buildHighlightedSentence(sentence)),
            const SizedBox(height: 8),
            const Text(
              'Note: Highlighted words share the same embedding vector across different sentences.',
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHighlightedSentence(String sentence) {
    final words = sentence.split(' ');
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Wrap(
        spacing: 4,
        children: words.map((word) {
          final isHighlighted = _highlightedTokens.contains(word.toLowerCase());
          
          return InkWell(
            onTap: () {
              // Find the token in vocabulary and select it
              final token = word.toLowerCase();
              if (_vocabularyMap.containsKey(token)) {
                setState(() {
                  _selectedToken = token;
                  _selectedTokenId = _vocabularyMap[token];
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: isHighlighted ? BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(4),
              ) : null,
              child: Text(
                word,
                style: TextStyle(
                  fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildMatrixExpander() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _showFullMatrix = !_showFullMatrix;
                });
              },
              child: Row(
                children: [
                  Icon(
                    _showFullMatrix ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _showFullMatrix ? 'Hide Embedding Matrix' : 'Show Embedding Matrix',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            if (_showFullMatrix) ...[  
              const SizedBox(height: 16),
              _buildEmbeddingMatrix(),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmbeddingMatrix() {
    // Get tokens sorted by ID for consistent display
    final sortedTokens = _vocabularyMap.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    
    // Filter to show only a reasonable number of tokens
    final displayTokens = sortedTokens.take(10).toList();
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 10,
        headingRowHeight: 40,
        dataRowHeight: 40,
        border: TableBorder.all(color: Colors.grey.shade300),
        columns: [
          const DataColumn(label: Text('Token')),
          const DataColumn(label: Text('ID')),
          ...List.generate(_embeddingDim, (i) => 
            DataColumn(label: Text('D${i+1}', style: const TextStyle(fontSize: 12)))
          ),
        ],
        rows: displayTokens.map((entry) {
          final token = entry.key;
          final tokenId = entry.value;
          final embedding = _embeddings[tokenId] ?? List.filled(_embeddingDim, 0.0);
          final isHighlighted = _highlightedTokens.contains(token);
          
          return DataRow(
            color: isHighlighted ? MaterialStateProperty.all(
              Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3)
            ) : null,
            cells: [
              DataCell(Text(
                token, 
                style: TextStyle(fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal),
              )),
              DataCell(Text(tokenId.toString())),
              ...embedding.map((value) => DataCell(
                Text(
                  value.toStringAsFixed(2),
                  style: TextStyle(
                    color: value < 0 ? Colors.blue.shade700 : Colors.red.shade700,
                    fontSize: 12,
                  ),
                ),
              )).toList(),
            ],
          );
        }).toList(),
      ),
    );
  }
  
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Embeddings'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Embedding Layer in Language Models',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Converts token IDs into dense vector representations',
              ),
              Text(
                '• Each token has a unique embedding vector',
              ),
              Text(
                '• Similar tokens have similar vectors in the embedding space',
              ),
              SizedBox(height: 8),
              Text(
                '• Blue represents negative values',
              ),
              Text(
                '• Red represents positive values',
              ),
              Text(
                '• The length of the colored bar shows the magnitude',
              ),
              SizedBox(height: 8),
              Text(
                'In a real language model, these embeddings are learned during '
                'training to capture semantic relationships between tokens.',
              ),
              SizedBox(height: 8),
              Text(
                'Why only "is" is highlighted in the example sentences:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '• Each unique token has exactly one embedding vector',
              ),
              Text(
                '• The word "is" appears in both sentences and shares the same embedding',
              ),
              Text(
                '• This demonstrates how embeddings are reused across contexts',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
