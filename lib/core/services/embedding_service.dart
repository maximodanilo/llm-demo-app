import 'package:llmdemoapp/core/models/embedding_layer.dart';
import 'package:llmdemoapp/core/models/tokenizer.dart';

/// Service responsible for providing consistent embeddings across different steps
class EmbeddingService {
  /// Singleton instance
  static final EmbeddingService _instance = EmbeddingService._internal();

  /// Factory constructor to return the singleton instance
  factory EmbeddingService() {
    return _instance;
  }

  /// Private constructor for singleton pattern
  EmbeddingService._internal();

  /// The embedding layer used across all steps
  late final EmbeddingLayer _embeddingLayer;
  
  /// The tokenizer used across all steps
  late final ITokenizer _tokenizer;
  
  /// Whether the service has been initialized
  bool _isInitialized = false;

  /// Initialize the embedding service with consistent parameters
  void initialize({int? seed, int embeddingDimension = 32}) {
    if (_isInitialized) return;
    
    // Create tokenizer
    _tokenizer = TokenizerFactory.createTokenizer(TokenizerType.word);
    
    // Create embedding layer with fixed seed for consistency
    _embeddingLayer = EmbeddingLayer(seed: seed ?? 42);
    _embeddingLayer.initializeEmbeddings(
      10000, // Vocabulary size
      embeddingDimension,
      strategy: EmbeddingInitStrategy.xavier,
    );
    
    _isInitialized = true;
  }
  
  /// Get the shared embedding layer
  EmbeddingLayer get embeddingLayer {
    _ensureInitialized();
    return _embeddingLayer;
  }
  
  /// Get the shared tokenizer
  ITokenizer get tokenizer {
    _ensureInitialized();
    return _tokenizer;
  }
  
  /// Process text to get tokens, token IDs, and embeddings
  /// Returns a map with 'tokens', 'tokenIds', and 'embeddings'
  Map<String, dynamic> processText(String text, {int maxTokens = 5}) {
    _ensureInitialized();
    
    // Tokenize the input text
    final tokens = _tokenizer.encode(text);
    
    // Convert tokens to IDs
    final tokenIds = _tokenizer.tokensToIds(tokens);
    
    // Limit tokens for clarity if needed
    final limitedTokens = tokens.length > maxTokens ? tokens.sublist(0, maxTokens) : tokens;
    final limitedTokenIds = tokenIds.length > maxTokens ? tokenIds.sublist(0, maxTokens) : tokenIds;
    
    // Get embeddings for each token
    final embeddings = limitedTokenIds.map((id) => _embeddingLayer.getEmbedding(id)).toList();
    
    return {
      'tokens': limitedTokens,
      'tokenIds': limitedTokenIds,
      'embeddings': embeddings,
    };
  }
  
  /// Ensure the service is initialized before use
  void _ensureInitialized() {
    if (!_isInitialized) {
      initialize();
    }
  }
}
