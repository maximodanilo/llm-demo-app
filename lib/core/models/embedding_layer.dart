import 'dart:math';
import 'package:vector_math/vector_math.dart';

/// Interface for embedding layer implementations
abstract class IEmbeddingLayer {
  /// Initialize embeddings for the vocabulary
  void initializeEmbeddings(int vocabSize, int embeddingDim);
  
  /// Get the embedding vector for a token
  List<double> getEmbedding(int tokenIndex);
  
  /// Update an embedding during training
  void updateEmbedding(int tokenIndex, List<double> gradient, double learningRate);
  
  /// Get similarity between two token embeddings (cosine similarity)
  double getSimilarity(int token1, int token2);
  
  /// Get the k nearest neighbors to a token
  List<int> getNearestNeighbors(int tokenIndex, int k);
  
  /// Get a reduced-dimension representation for visualization
  List<double> getEmbeddingForVisualization(int tokenIndex, {int dimensions = 2});
  
  /// Get the embedding dimension
  int get embeddingDimension;
  
  /// Get the vocabulary size
  int get vocabularySize;
}

/// Initialization strategies for embeddings
enum EmbeddingInitStrategy {
  /// Random initialization with values between -1 and 1
  random,
  
  /// Xavier/Glorot initialization for better training convergence
  xavier,
  
  /// Zero initialization (mostly for testing)
  zeros
}

/// Implementation of the embedding layer
class EmbeddingLayer implements IEmbeddingLayer {
  /// Matrix of embeddings where each row is a token embedding
  late List<List<double>> _embeddings;
  
  /// Dimension of each embedding vector
  late int _embeddingDim;
  
  /// Size of the vocabulary
  late int _vocabSize;
  
  /// Random number generator
  final Random _random;
  
  /// Create an embedding layer with optional seed for reproducibility
  EmbeddingLayer({int? seed}) : _random = Random(seed);
  
  @override
  void initializeEmbeddings(int vocabSize, int embeddingDim, {EmbeddingInitStrategy strategy = EmbeddingInitStrategy.xavier}) {
    _vocabSize = vocabSize;
    _embeddingDim = embeddingDim;
    _embeddings = List.generate(vocabSize, (_) => List.filled(embeddingDim, 0.0));
    
    switch (strategy) {
      case EmbeddingInitStrategy.random:
        _initializeRandom();
        break;
      case EmbeddingInitStrategy.xavier:
        _initializeXavier();
        break;
      case EmbeddingInitStrategy.zeros:
        // Already initialized to zeros
        break;
    }
  }
  
  /// Initialize embeddings with random values between -1 and 1
  void _initializeRandom() {
    for (int i = 0; i < _vocabSize; i++) {
      for (int j = 0; j < _embeddingDim; j++) {
        _embeddings[i][j] = _random.nextDouble() * 2 - 1; // Range: -1 to 1
      }
    }
  }
  
  /// Initialize embeddings with Xavier/Glorot initialization
  void _initializeXavier() {
    // Xavier initialization: variance = 2 / (input_dim + output_dim)
    // For embeddings, we use 2 / embedding_dim as a simplified version
    final double scale = sqrt(2 / _embeddingDim);
    
    for (int i = 0; i < _vocabSize; i++) {
      for (int j = 0; j < _embeddingDim; j++) {
        _embeddings[i][j] = (_random.nextDouble() * 2 - 1) * scale;
      }
    }
  }
  
  @override
  List<double> getEmbedding(int tokenIndex) {
    if (tokenIndex < 0 || tokenIndex >= _vocabSize) {
      throw RangeError('Token index out of range: $tokenIndex');
    }
    
    // Return a copy to prevent external modification
    return List.from(_embeddings[tokenIndex]);
  }
  
  @override
  void updateEmbedding(int tokenIndex, List<double> gradient, double learningRate) {
    if (tokenIndex < 0 || tokenIndex >= _vocabSize) {
      throw RangeError('Token index out of range: $tokenIndex');
    }
    
    if (gradient.length != _embeddingDim) {
      throw ArgumentError('Gradient dimension (${gradient.length}) does not match embedding dimension ($_embeddingDim)');
    }
    
    // Update embedding using gradient descent
    for (int i = 0; i < _embeddingDim; i++) {
      _embeddings[tokenIndex][i] -= gradient[i] * learningRate;
    }
  }
  
  @override
  double getSimilarity(int token1, int token2) {
    final embedding1 = getEmbedding(token1);
    final embedding2 = getEmbedding(token2);
    
    // Calculate cosine similarity
    double dotProduct = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;
    
    for (int i = 0; i < _embeddingDim; i++) {
      dotProduct += embedding1[i] * embedding2[i];
      norm1 += embedding1[i] * embedding1[i];
      norm2 += embedding2[i] * embedding2[i];
    }
    
    // Handle zero vectors
    if (norm1 == 0 || norm2 == 0) {
      return 0.0;
    }
    
    return dotProduct / (sqrt(norm1) * sqrt(norm2));
  }
  
  @override
  List<int> getNearestNeighbors(int tokenIndex, int k) {
    if (k <= 0 || k >= _vocabSize) {
      throw ArgumentError('k must be positive and less than vocabulary size');
    }
    
    final List<MapEntry<int, double>> similarities = [];
    final targetEmbedding = getEmbedding(tokenIndex);
    
    // Calculate similarity with all other tokens
    for (int i = 0; i < _vocabSize; i++) {
      if (i != tokenIndex) {
        final similarity = getSimilarity(tokenIndex, i);
        similarities.add(MapEntry(i, similarity));
      }
    }
    
    // Sort by similarity (descending)
    similarities.sort((a, b) => b.value.compareTo(a.value));
    
    // Return the top k token indices
    return similarities.take(k).map((entry) => entry.key).toList();
  }
  
  @override
  List<double> getEmbeddingForVisualization(int tokenIndex, {int dimensions = 2}) {
    if (dimensions <= 0 || dimensions > _embeddingDim) {
      throw ArgumentError('Visualization dimensions must be positive and not greater than embedding dimension');
    }
    
    // For educational purposes, we'll use a simple approach:
    // Just take the first 'dimensions' components of the embedding
    // In a real implementation, you would use PCA or t-SNE
    final embedding = getEmbedding(tokenIndex);
    return embedding.sublist(0, dimensions);
  }
  
  @override
  int get embeddingDimension => _embeddingDim;
  
  @override
  int get vocabularySize => _vocabSize;
  
  /// Normalize all embeddings to unit length
  void normalizeEmbeddings() {
    for (int i = 0; i < _vocabSize; i++) {
      double squaredSum = 0.0;
      
      // Calculate the squared sum
      for (int j = 0; j < _embeddingDim; j++) {
        squaredSum += _embeddings[i][j] * _embeddings[i][j];
      }
      
      // Skip normalization for zero vectors
      if (squaredSum > 0) {
        final norm = sqrt(squaredSum);
        
        // Normalize to unit length
        for (int j = 0; j < _embeddingDim; j++) {
          _embeddings[i][j] /= norm;
        }
      }
    }
  }
  
  /// Get a copy of all embeddings
  List<List<double>> getAllEmbeddings() {
    return _embeddings.map((embedding) => List<double>.from(embedding)).toList();
  }
  
  /// Set a specific embedding (useful for testing or loading pretrained embeddings)
  void setEmbedding(int tokenIndex, List<double> embedding) {
    if (tokenIndex < 0 || tokenIndex >= _vocabSize) {
      throw RangeError('Token index out of range: $tokenIndex');
    }
    
    if (embedding.length != _embeddingDim) {
      throw ArgumentError('Embedding dimension (${embedding.length}) does not match expected dimension ($_embeddingDim)');
    }
    
    _embeddings[tokenIndex] = List.from(embedding);
  }
}
