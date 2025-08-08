import 'package:flutter/material.dart';
import 'package:llmdemoapp/core/models/embedding_layer.dart';
import 'package:llmdemoapp/core/models/tokenizer.dart';
import 'package:llmdemoapp/ui/steps/training_step_section.dart';
import 'package:llmdemoapp/ui/widgets/collapsible_education_section.dart';
import 'package:llmdemoapp/ui/widgets/embedding_wave_visualization.dart';

/// Implementation of the Embedding Lookup step in the LLM training flow
class EmbeddingLookupStepSectionImpl extends StatefulWidget
    implements TrainingStepSection {
  @override
  final String title;

  @override
  final String description;

  @override
  final bool isEditable;

  @override
  final bool isCompleted;

  /// The original input text from the first step
  final String inputText;

  /// Embedding dimension to use for visualization
  final int embeddingDimension;

  const EmbeddingLookupStepSectionImpl({
    super.key,
    required this.title,
    required this.description,
    required this.isEditable,
    required this.isCompleted,
    required this.inputText,
    this.embeddingDimension = 8,
  });

  @override
  State<EmbeddingLookupStepSectionImpl> createState() =>
      _EmbeddingLookupStepSectionImplState();

  @override
  bool validate() {
    // This step is always valid once shown
    return true;
  }
}

class _EmbeddingLookupStepSectionImplState
    extends State<EmbeddingLookupStepSectionImpl> {
  late final ITokenizer _tokenizer;
  late final EmbeddingLayer _embeddingLayer;
  late final List<String> _tokens;
  late final List<int> _tokenIds;
  late final List<List<double>> _embeddings;

  @override
  void initState() {
    super.initState();

    // Initialize tokenizer
    _tokenizer = TokenizerFactory.createTokenizer(TokenizerType.word);

    // Tokenize the input text
    _tokens = _tokenizer.encode(widget.inputText);

    // Convert tokens to IDs
    _tokenIds = _tokenizer.tokensToIds(_tokens);

    // Initialize embedding layer with vocabulary size and embedding dimension
    _embeddingLayer = EmbeddingLayer();
    _embeddingLayer.initializeEmbeddings(
      _tokenizer.vocabulary.getSize(),
      widget.embeddingDimension,
      strategy: EmbeddingInitStrategy.xavier,
    );

    // Get embeddings for each token
    _embeddings =
        _tokenIds.map((id) => _embeddingLayer.getEmbedding(id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and description
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),

          // Educational content about embeddings
          CollapsibleEducationSection(
            title: 'What are Embeddings?',
            themeColor: Colors.purple,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Embeddings are dense vector representations of words or tokens in a continuous vector space. They capture semantic meaning by positioning similar words closer together in this space.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Key properties of embeddings:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '• Dimensionality: Typically ranges from 50 to 4096 dimensions',
                      ),
                      Text(
                        '• Semantic similarity: Similar words have similar vectors',
                      ),
                      Text(
                        '• Arithmetic: Vector operations can reveal relationships (king - man + woman ≈ queen)',
                      ),
                      Text(
                        '• Learned: Embeddings are learned during model training or pre-training',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'In LLMs, embeddings form the foundation of how models understand language. They convert discrete tokens into continuous representations that neural networks can process.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Embedding information
          Card(
            elevation: 2,
            color: Colors.purple.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Embedding Information:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Embedding Dimension: ${widget.embeddingDimension}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Vocabulary Size: ${_tokenizer.vocabulary.getSize()}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Initialization: Xavier/Glorot',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Token to embedding mapping
          Text(
            'Token to Embedding Mapping:',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // List of tokens with their embeddings
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _tokens.length,
            itemBuilder: (context, index) {
              return _buildEmbeddingCard(
                token: _tokens[index],
                tokenId: _tokenIds[index],
                embedding: _embeddings[index],
                index: index,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmbeddingCard({
    required String token,
    required int tokenId,
    required List<double> embedding,
    required int index,
  }) {
    final colorIntensity = index % 3 * 0.2;
    final cardColor = Colors.purple.withValues(alpha: 0.1 + colorIntensity);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Token and ID
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    token,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'ID: $tokenId',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Embedding vector visualization
            Text(
              'Embedding Vector:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildEmbeddingVisualization(embedding),
          ],
        ),
      ),
    );
  }

  Widget _buildEmbeddingVisualization(List<double> embedding) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Wave visualization
        EmbeddingWaveVisualization(
          embedding: embedding,
          waveColor: Colors.purple,
        ),
        
        // Collapsible section for raw embedding vector
        const SizedBox(height: 8),
        CollapsibleEducationSection(
          title: 'Raw Embedding Vector',
          themeColor: Colors.purple,
          initiallyExpanded: false,
          content: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'The raw numerical values of the embedding vector:',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  '[${embedding.map((e) => e.toStringAsFixed(3)).join(', ')}]',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
