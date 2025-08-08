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
      
      // Verify section headers are displayed
      expect(find.text('Original Text:'), findsOneWidget);
      expect(find.text('Token to ID Mapping:'), findsOneWidget);
      
      // Verify original text is displayed
      expect(find.text('Original Text:'), findsOneWidget);
      expect(find.text(inputText), findsOneWidget);
      
      // Verify vocabulary information is displayed
      expect(find.text('Vocabulary Information'), findsOneWidget);
      expect(find.text('Special predefined tokens:'), findsOneWidget);
      
      // Verify token to ID mapping section exists
      expect(find.text('Token to ID Mapping:'), findsOneWidget);
      
      
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
      final tokens = tokenizer.encode(inputText);
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
      
      // Verify tokens are displayed
      for (var token in tokens) {
        expect(find.text(token), findsWidgets);
      }
      
      // Verify IDs are displayed with their prefix
      for (var id in ids) {
        expect(find.text('ID: $id'), findsWidgets);
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
