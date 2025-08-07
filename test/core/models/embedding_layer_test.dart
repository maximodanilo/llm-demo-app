import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:llmdemoapp/core/models/embedding_layer.dart';

void main() {
  late IEmbeddingLayer embeddingLayer;
  const int vocabSize = 100;
  const int embeddingDim = 50;

  setUp(() {
    // Use a fixed seed for reproducible tests
    embeddingLayer = EmbeddingLayer(seed: 42);
    embeddingLayer.initializeEmbeddings(vocabSize, embeddingDim);
  });

  group('EmbeddingLayer Initialization', () {
    test('should initialize with correct dimensions', () {
      expect(embeddingLayer.vocabularySize, vocabSize);
      expect(embeddingLayer.embeddingDimension, embeddingDim);
    });

    test('should initialize with different strategies', () {
      // Test Xavier initialization
      final xavierLayer = EmbeddingLayer(seed: 42);
      xavierLayer.initializeEmbeddings(
        vocabSize,
        embeddingDim,
        strategy: EmbeddingInitStrategy.xavier,
      );

      // Test random initialization
      final randomLayer = EmbeddingLayer(seed: 42);
      randomLayer.initializeEmbeddings(
        vocabSize,
        embeddingDim,
        strategy: EmbeddingInitStrategy.random,
      );

      // Test zeros initialization
      final zerosLayer = EmbeddingLayer(seed: 42);
      zerosLayer.initializeEmbeddings(
        vocabSize,
        embeddingDim,
        strategy: EmbeddingInitStrategy.zeros,
      );

      // Verify that zeros are all zeros
      final zerosEmbedding = zerosLayer.getEmbedding(0);
      expect(zerosEmbedding.every((value) => value == 0.0), isTrue);

      // Verify that random and Xavier are different
      final randomEmbedding = randomLayer.getEmbedding(0);
      final xavierEmbedding = xavierLayer.getEmbedding(0);

      expect(randomEmbedding, isNot(equals(xavierEmbedding)));
    });
  });

  group('Embedding Retrieval', () {
    test('should retrieve correct embedding dimensions', () {
      final embedding = embeddingLayer.getEmbedding(0);
      expect(embedding.length, embeddingDim);
    });

    test('should throw exception for out-of-range token index', () {
      expect(() => embeddingLayer.getEmbedding(-1), throwsRangeError);
      expect(() => embeddingLayer.getEmbedding(vocabSize), throwsRangeError);
    });

    test('should return a copy of the embedding', () {
      final embedding1 = embeddingLayer.getEmbedding(0);
      final embedding2 = embeddingLayer.getEmbedding(0);

      // Should be equal but not the same object
      expect(embedding1, equals(embedding2));

      // Modifying one should not affect the other
      embedding1[0] = 999.0;
      expect(embedding1, isNot(equals(embedding2)));

      // Original embedding in the layer should be unchanged
      final embedding3 = embeddingLayer.getEmbedding(0);
      expect(embedding3, equals(embedding2));
    });
  });

  group('Embedding Updates', () {
    test('should update embedding with gradient', () {
      // Get original embedding
      final originalEmbedding = embeddingLayer.getEmbedding(0);

      // Create a gradient of all 0.1 values
      final gradient = List.filled(embeddingDim, 0.1);
      const learningRate = 0.5;

      // Update the embedding
      embeddingLayer.updateEmbedding(0, gradient, learningRate);

      // Get updated embedding
      final updatedEmbedding = embeddingLayer.getEmbedding(0);

      // Verify each dimension was updated correctly
      for (int i = 0; i < embeddingDim; i++) {
        expect(
          updatedEmbedding[i],
          closeTo(originalEmbedding[i] - gradient[i] * learningRate, 1e-10),
        );
      }
    });

    test('should throw exception for invalid gradient dimension', () {
      final invalidGradient = List.filled(embeddingDim + 1, 0.1);
      expect(
        () => embeddingLayer.updateEmbedding(0, invalidGradient, 0.1),
        throwsArgumentError,
      );
    });
  });

  group('Similarity Calculations', () {
    test('should calculate cosine similarity correctly', () {
      // Create a custom embedding layer for controlled testing
      final customLayer = EmbeddingLayer();
      customLayer.initializeEmbeddings(
        3,
        2,
        strategy: EmbeddingInitStrategy.zeros,
      );

      // Set known embeddings
      customLayer.setEmbedding(0, [1.0, 0.0]); // Horizontal vector
      customLayer.setEmbedding(1, [0.0, 1.0]); // Vertical vector
      customLayer.setEmbedding(2, [1.0, 1.0]); // 45-degree vector

      // Test orthogonal vectors (should be 0)
      expect(customLayer.getSimilarity(0, 1), closeTo(0.0, 1e-10));

      // Test same direction vectors (should be 1)
      expect(customLayer.getSimilarity(0, 0), closeTo(1.0, 1e-10));

      // Test 45-degree angle (should be 1/sqrt(2) ≈ 0.7071)
      expect(customLayer.getSimilarity(0, 2), closeTo(1.0 / sqrt(2), 1e-10));
      expect(customLayer.getSimilarity(1, 2), closeTo(1.0 / sqrt(2), 1e-10));
    });

    test('should handle zero vectors in similarity calculation', () {
      final customLayer = EmbeddingLayer();
      customLayer.initializeEmbeddings(
        2,
        2,
        strategy: EmbeddingInitStrategy.zeros,
      );

      // One vector is non-zero
      customLayer.setEmbedding(0, [1.0, 1.0]);

      // Similarity with zero vector should be 0
      expect(customLayer.getSimilarity(0, 1), 0.0);
    });
  });

  group('Nearest Neighbors', () {
    test('should find correct nearest neighbors', () {
      // Create a custom embedding layer for controlled testing
      final customLayer = EmbeddingLayer();
      customLayer.initializeEmbeddings(
        4,
        2,
        strategy: EmbeddingInitStrategy.zeros,
      );

      // Set known embeddings
      customLayer.setEmbedding(0, [1.0, 0.0]);
      (customLayer).setEmbedding(1, [0.9, 0.1]); // Close to 0
      (customLayer).setEmbedding(2, [0.1, 0.9]); // Far from 0
      (customLayer).setEmbedding(3, [0.5, 0.5]); // In between

      // Find 2 nearest neighbors to token 0
      final neighbors = customLayer.getNearestNeighbors(0, 2);

      // Should be tokens 1 and 3 in that order
      expect(neighbors, equals([1, 3]));
    });

    test('should throw exception for invalid k', () {
      expect(
        () => embeddingLayer.getNearestNeighbors(0, 0),
        throwsArgumentError,
      );
      expect(
        () => embeddingLayer.getNearestNeighbors(0, vocabSize),
        throwsArgumentError,
      );
    });
  });

  group('Visualization', () {
    test('should return reduced dimensions for visualization', () {
      final visualized = embeddingLayer.getEmbeddingForVisualization(
        0,
        dimensions: 2,
      );
      expect(visualized.length, 2);

      // Should be the first 2 dimensions of the original embedding
      final original = embeddingLayer.getEmbedding(0);
      expect(visualized[0], original[0]);
      expect(visualized[1], original[1]);
    });

    test('should throw exception for invalid dimensions', () {
      expect(
        () => embeddingLayer.getEmbeddingForVisualization(0, dimensions: 0),
        throwsArgumentError,
      );
      expect(
        () => embeddingLayer.getEmbeddingForVisualization(
          0,
          dimensions: embeddingDim + 1,
        ),
        throwsArgumentError,
      );
    });
  });

  group('Normalization', () {
    test('should normalize embeddings to unit length', () {
      // Create a custom embedding layer
      final customLayer = EmbeddingLayer();
      customLayer.initializeEmbeddings(
        2,
        3,
        strategy: EmbeddingInitStrategy.zeros,
      );

      // Set known embeddings
      customLayer.setEmbedding(0, [
        3.0,
        4.0,
        0.0,
      ]); // Length 5
      (customLayer).setEmbedding(1, [1.0, 1.0, 1.0]); // Length sqrt(3)

      // Normalize
      customLayer.normalizeEmbeddings();

      // Check that vectors are unit length
      final normalized1 = customLayer.getEmbedding(0);
      final normalized2 = customLayer.getEmbedding(1);

      // Calculate lengths
      double length1 = 0.0;
      double length2 = 0.0;

      for (int i = 0; i < 3; i++) {
        length1 += normalized1[i] * normalized1[i];
        length2 += normalized2[i] * normalized2[i];
      }

      length1 = sqrt(length1);
      length2 = sqrt(length2);

      // Should be unit vectors
      expect(length1, closeTo(1.0, 1e-10));
      expect(length2, closeTo(1.0, 1e-10));

      // Check specific values
      expect(normalized1[0], closeTo(3.0 / 5.0, 1e-10));
      expect(normalized1[1], closeTo(4.0 / 5.0, 1e-10));
    });

    test('should handle zero vectors during normalization', () {
      final customLayer = EmbeddingLayer();
      customLayer.initializeEmbeddings(
        2,
        2,
        strategy: EmbeddingInitStrategy.zeros,
      );

      // One vector is non-zero
      customLayer.setEmbedding(0, [3.0, 4.0]);

      // Normalize
      customLayer.normalizeEmbeddings();

      // Zero vector should remain zero
      final zeroVector = customLayer.getEmbedding(1);
      expect(zeroVector[0], 0.0);
      expect(zeroVector[1], 0.0);
    });
  });

  group('Custom Embedding Management', () {
    test('should set and get all embeddings', () {
      final customLayer = EmbeddingLayer();
      customLayer.initializeEmbeddings(
        2,
        2,
        strategy: EmbeddingInitStrategy.zeros,
      );

      // Set custom embeddings
      customLayer.setEmbedding(0, [1.0, 2.0]);
      (customLayer).setEmbedding(1, [3.0, 4.0]);

      // Get all embeddings
      final allEmbeddings = customLayer.getAllEmbeddings();

      // Verify
      expect(allEmbeddings.length, 2);
      expect(allEmbeddings[0], equals([1.0, 2.0]));
      expect(allEmbeddings[1], equals([3.0, 4.0]));

      // Verify that it's a copy
      allEmbeddings[0][0] = 999.0;
      expect(customLayer.getEmbedding(0)[0], 1.0);
    });

    test('should throw exception for invalid embedding dimensions', () {
      final customLayer = EmbeddingLayer();
      customLayer.initializeEmbeddings(
        2,
        2,
        strategy: EmbeddingInitStrategy.zeros,
      );

      expect(
        () => customLayer.setEmbedding(0, [1.0, 2.0, 3.0]),
        throwsArgumentError,
      );
    });
  });
}
