import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llmdemoapp/core/models/tokenizer.dart';
import 'package:llmdemoapp/core/services/training_step_service.dart';
import 'package:llmdemoapp/ui/steps/token_to_id_step_section_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  
  group('TokenToIdStepSectionImpl', () {
    late TrainingStepService service;
    
    setUp(() {
      service = TrainingStepService();
      service.resetProgress();
    });
    
    testWidgets('renders correctly with input text', (WidgetTester tester) async {
      const inputText = 'Hello world';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TokenToIdStepSectionImpl(
              title: 'Token to ID Mapping',
              description: 'Learn how tokens are converted to numerical IDs',
              isEditable: true,
              isCompleted: false,
              inputText: inputText,
            ),
          ),
        ),
      );
      
      // Verify title and description are displayed
      expect(find.text('Token to ID Mapping'), findsOneWidget);
      expect(find.text('Learn how tokens are converted to numerical IDs'), findsOneWidget);
      
      // Verify original text is displayed
      expect(find.text('Original Text:'), findsOneWidget);
      expect(find.text(inputText), findsOneWidget);
      
      // Verify token to ID mapping section exists
      expect(find.text('Token to ID Mapping:'), findsOneWidget);
      
      // Verify special tokens section exists
      expect(find.text('Vocabulary Information:'), findsOneWidget);
      
      // Verify special tokens are displayed
      expect(find.text('[PAD]'), findsOneWidget);
      expect(find.text('[UNK]'), findsOneWidget);
      expect(find.text('[CLS]'), findsOneWidget);
      expect(find.text('[SEP]'), findsOneWidget);
    });
    
    testWidgets('displays correct token to ID mappings', (WidgetTester tester) async {
      const inputText = 'Hello world';
      
      // Get the expected tokens and IDs
      final tokenizer = WordTokenizer();
      final tokens = tokenizer.tokenize(inputText);
      final ids = tokenizer.tokensToIds(tokens);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TokenToIdStepSectionImpl(
              title: 'Token to ID Mapping',
              description: 'Learn how tokens are converted to numerical IDs',
              isEditable: true,
              isCompleted: false,
              inputText: inputText,
            ),
          ),
        ),
      );
      
      // Verify each token is displayed with its corresponding ID
      for (var i = 0; i < tokens.length; i++) {
        expect(find.text(tokens[i]), findsWidgets);
        expect(find.text(ids[i].toString()), findsWidgets);
      }
    });
    
    testWidgets('validate always returns true', (WidgetTester tester) async {
      const widget = TokenToIdStepSectionImpl(
        title: 'Token to ID Mapping',
        description: 'Learn how tokens are converted to numerical IDs',
        isEditable: true,
        isCompleted: false,
        inputText: 'Hello world',
      );
      
      expect(widget.validate(), isTrue);
    });
  });
}
