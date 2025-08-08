import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llmdemoapp/core/models/embedding_layer.dart';
import 'package:llmdemoapp/core/models/tokenizer.dart';
import 'package:llmdemoapp/ui/steps/embedding_lookup_step_section_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('EmbeddingLookupStepSectionImpl', () {
    testWidgets('should render correctly with input text', (WidgetTester tester) async {
      // Arrange
      const inputText = 'Hello world';
      const title = 'Embedding Lookup';
      const description = 'See how token IDs are mapped to embedding vectors';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EmbeddingLookupStepSectionImpl(
                title: title,
                description: description,
                isEditable: false,
                isCompleted: false,
                inputText: inputText,
                embeddingDimension: 4, // Use smaller dimension for testing
              ),
            ),
          ),
        ),
      );

      // Wait for widget to build completely
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(title), findsOneWidget);
      expect(find.text(description), findsOneWidget);
      expect(find.text('Original Input:'), findsOneWidget);
      expect(find.text(inputText), findsOneWidget);
      expect(find.text('Embedding Information:'), findsOneWidget);
      expect(find.text('Embedding Dimension: 4'), findsOneWidget);
      expect(find.text('Token to Embedding Mapping:'), findsOneWidget);
      
      // Verify key UI elements are present
      expect(find.text('Original Input:'), findsOneWidget);
      expect(find.text('Embedding Information:'), findsOneWidget);
      expect(find.text('Token to Embedding Mapping:'), findsOneWidget);
      expect(find.text('What are Embeddings?'), findsOneWidget);
      
      // Verify the original input text is displayed
      expect(find.text(inputText), findsOneWidget);
    });

    testWidgets('should validate correctly', (WidgetTester tester) async {
      // Arrange
      const widget = EmbeddingLookupStepSectionImpl(
        title: 'Test',
        description: 'Test',
        isEditable: false,
        isCompleted: false,
        inputText: 'Test',
      );

      // Act & Assert
      expect(widget.validate(), isTrue);
    });

    test('EmbeddingLayer should initialize with correct dimensions', () {
      // Arrange
      final embeddingLayer = EmbeddingLayer();
      const vocabSize = 10;
      const embeddingDim = 8;

      // Act
      embeddingLayer.initializeEmbeddings(vocabSize, embeddingDim);

      // Assert
      expect(embeddingLayer.vocabularySize, equals(vocabSize));
      expect(embeddingLayer.embeddingDimension, equals(embeddingDim));
    });

    test('Tokenizer should convert tokens to IDs correctly', () {
      // Arrange
      final tokenizer = TokenizerFactory.createTokenizer(TokenizerType.word);
      const text = 'Hello world';

      // Act
      final tokens = tokenizer.encode(text);
      final ids = tokenizer.tokensToIds(tokens);

      // Assert
      expect(tokens.length, equals(2)); // 'hello' and 'world'
      expect(ids.length, equals(tokens.length));
      
      // IDs should be different for different tokens
      if (ids.length >= 2) {
        expect(ids[0] != ids[1], isTrue);
      }
    });
  });
}
