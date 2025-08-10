import 'package:flutter_test/flutter_test.dart';
import 'package:llmdemoapp/core/services/embedding_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('EmbeddingService Integration Tests', () {
    const String testText = 'Hello world';
    
    test('EmbeddingService should provide consistent embeddings across steps', () {
      // Initialize the embedding service as it would be in the embedding lookup step
      final embeddingLookupService = EmbeddingService();
      embeddingLookupService.initialize(seed: 42, embeddingDimension: 32);
      final embeddingLookupResult = embeddingLookupService.processText(testText);
      
      // Get the embeddings from the embedding lookup step
      final embeddingLookupEmbeddings = embeddingLookupResult['embeddings'];
      
      // Initialize the embedding service as it would be in the positional encoding step
      final positionalEncodingService = EmbeddingService();
      positionalEncodingService.initialize(seed: 42, embeddingDimension: 32);
      final positionalEncodingResult = positionalEncodingService.processText(testText);
      
      // Get the embeddings from the positional encoding step
      final positionalEncodingEmbeddings = positionalEncodingResult['embeddings'];
      
      // Verify that the embeddings are identical
      expect(embeddingLookupEmbeddings.length, equals(positionalEncodingEmbeddings.length),
          reason: 'Both steps should have the same number of embeddings');
      
      for (int i = 0; i < embeddingLookupEmbeddings.length; i++) {
        final embeddingLookupVector = embeddingLookupEmbeddings[i];
        final positionalEncodingVector = positionalEncodingEmbeddings[i];
        
        expect(embeddingLookupVector.length, equals(positionalEncodingVector.length),
            reason: 'Embedding vectors should have the same dimension');
        
        for (int j = 0; j < embeddingLookupVector.length; j++) {
          expect(embeddingLookupVector[j], equals(positionalEncodingVector[j]),
              reason: 'Embedding values should be identical at dimension $j for token $i');
        }
      }
    });
    
    test('EmbeddingService should be a singleton', () {
      // Create two instances of the embedding service
      final service1 = EmbeddingService();
      final service2 = EmbeddingService();
      
      // Verify that they are the same instance
      expect(identical(service1, service2), isTrue,
          reason: 'EmbeddingService should be a singleton');
      
      // Initialize the first instance
      service1.initialize(seed: 42, embeddingDimension: 32);
      
      // Process text with both instances
      final result1 = service1.processText(testText);
      final result2 = service2.processText(testText);
      
      // Verify that the results are identical
      expect(result1['embeddings'], equals(result2['embeddings']),
          reason: 'Both instances should produce the same embeddings');
    });
    
    test('EmbeddingService should handle reinitialization gracefully', () {
      // Create an instance of the embedding service
      final service = EmbeddingService();
      
      // Initialize with one set of parameters
      service.initialize(seed: 42, embeddingDimension: 32);
      final result1 = service.processText(testText);
      
      // Try to reinitialize with different parameters (should be ignored)
      service.initialize(seed: 43, embeddingDimension: 64);
      final result2 = service.processText(testText);
      
      // Verify that the results are identical (first initialization should stick)
      expect(result1['embeddings'], equals(result2['embeddings']),
          reason: 'Reinitialization should be ignored');
    });
  });
}
