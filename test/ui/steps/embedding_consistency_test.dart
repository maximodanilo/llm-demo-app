import 'package:flutter_test/flutter_test.dart';
import 'package:llmdemoapp/core/models/embedding_layer.dart';
import 'package:llmdemoapp/core/models/tokenizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Embedding Consistency Tests', () {
    const String testText = 'Hello world';
    late ITokenizer tokenizer;
    late List<String> tokens;
    late List<int> tokenIds;

    setUp(() {
      // Initialize tokenizer
      tokenizer = TokenizerFactory.createTokenizer(TokenizerType.word);
      tokens = tokenizer.encode(testText);
      tokenIds = tokenizer.tokensToIds(tokens);
    });

    test('Embedding layer should produce consistent embeddings with same seed', () {
      // Create two embedding layers with the same seed
      final embeddingLayer1 = EmbeddingLayer(seed: 42);
      final embeddingLayer2 = EmbeddingLayer(seed: 42);
      
      // Initialize both with the same parameters
      const int vocabSize = 10000;
      const int embeddingDim = 32;
      embeddingLayer1.initializeEmbeddings(vocabSize, embeddingDim, strategy: EmbeddingInitStrategy.xavier);
      embeddingLayer2.initializeEmbeddings(vocabSize, embeddingDim, strategy: EmbeddingInitStrategy.xavier);
      
      // Get embeddings for the same token ID from both layers
      for (int i = 0; i < tokenIds.length; i++) {
        final int tokenId = tokenIds[i];
        final embedding1 = embeddingLayer1.getEmbedding(tokenId);
        final embedding2 = embeddingLayer2.getEmbedding(tokenId);
        
        // Embeddings should be identical
        expect(embedding1, equals(embedding2), reason: 'Embeddings for token "${tokens[i]}" (ID: $tokenId) should be identical with the same seed');
        
        // Verify each dimension individually for better error reporting
        for (int j = 0; j < embeddingDim; j++) {
          expect(embedding1[j], equals(embedding2[j]), 
              reason: 'Dimension $j of embeddings for token "${tokens[i]}" (ID: $tokenId) differs');
        }
      }
    });

    test('Embedding layer should produce different embeddings with different seeds', () {
      // Create two embedding layers with different seeds
      final embeddingLayer1 = EmbeddingLayer(seed: 42);
      final embeddingLayer2 = EmbeddingLayer(seed: 43);
      
      // Initialize both with the same parameters
      const int vocabSize = 10000;
      const int embeddingDim = 32;
      embeddingLayer1.initializeEmbeddings(vocabSize, embeddingDim, strategy: EmbeddingInitStrategy.xavier);
      embeddingLayer2.initializeEmbeddings(vocabSize, embeddingDim, strategy: EmbeddingInitStrategy.xavier);
      
      // Get embeddings for the same token ID from both layers
      bool foundDifference = false;
      for (int i = 0; i < tokenIds.length && !foundDifference; i++) {
        final int tokenId = tokenIds[i];
        final embedding1 = embeddingLayer1.getEmbedding(tokenId);
        final embedding2 = embeddingLayer2.getEmbedding(tokenId);
        
        // Check if embeddings are different
        for (int j = 0; j < embeddingDim; j++) {
          if (embedding1[j] != embedding2[j]) {
            foundDifference = true;
            break;
          }
        }
      }
      
      expect(foundDifference, isTrue, reason: 'Embeddings should differ with different seeds');
    });

    test('Embedding layer should be deterministic with the same seed', () {
      // Create an embedding layer
      final embeddingLayer = EmbeddingLayer(seed: 42);
      
      // Initialize with parameters
      const int vocabSize = 10000;
      const int embeddingDim = 32;
      embeddingLayer.initializeEmbeddings(vocabSize, embeddingDim, strategy: EmbeddingInitStrategy.xavier);
      
      // Get embeddings for token IDs
      final List<List<double>> firstEmbeddings = tokenIds.map((id) => embeddingLayer.getEmbedding(id)).toList();
      
      // Reinitialize the embedding layer with the same seed
      final embeddingLayerReinitialized = EmbeddingLayer(seed: 42);
      embeddingLayerReinitialized.initializeEmbeddings(vocabSize, embeddingDim, strategy: EmbeddingInitStrategy.xavier);
      
      // Get embeddings again
      final List<List<double>> secondEmbeddings = tokenIds.map((id) => embeddingLayerReinitialized.getEmbedding(id)).toList();
      
      // Compare embeddings
      for (int i = 0; i < tokenIds.length; i++) {
        expect(firstEmbeddings[i], equals(secondEmbeddings[i]), 
            reason: 'Embeddings for token "${tokens[i]}" should be deterministic with the same seed');
      }
    });

    test('Simulating embedding lookup and positional encoding steps should use consistent embeddings', () {
      // This test simulates what happens in both steps to ensure they would produce the same embeddings
      
      // Simulate embedding lookup step
      final embeddingLookupLayer = EmbeddingLayer(seed: 42);
      embeddingLookupLayer.initializeEmbeddings(10000, 32, strategy: EmbeddingInitStrategy.xavier);
      final embeddingLookupEmbeddings = tokenIds.map((id) => embeddingLookupLayer.getEmbedding(id)).toList();
      
      // Simulate positional encoding step
      final positionalEncodingLayer = EmbeddingLayer(seed: 42);
      positionalEncodingLayer.initializeEmbeddings(10000, 32, strategy: EmbeddingInitStrategy.xavier);
      final positionalEncodingEmbeddings = tokenIds.map((id) => positionalEncodingLayer.getEmbedding(id)).toList();
      
      // Compare embeddings from both steps
      for (int i = 0; i < tokenIds.length; i++) {
        expect(embeddingLookupEmbeddings[i], equals(positionalEncodingEmbeddings[i]), 
            reason: 'Embeddings for token "${tokens[i]}" should be identical between steps');
        
        // Verify each dimension individually for better error reporting
        for (int j = 0; j < 32; j++) {
          expect(embeddingLookupEmbeddings[i][j], equals(positionalEncodingEmbeddings[i][j]), 
              reason: 'Dimension $j of embeddings for token "${tokens[i]}" differs between steps');
        }
      }
    });
  });
}
