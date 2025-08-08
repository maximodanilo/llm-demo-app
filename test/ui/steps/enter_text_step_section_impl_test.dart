import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llmdemoapp/core/services/training_step_service.dart';
import 'package:llmdemoapp/ui/steps/enter_text_step_section_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  group('EnterTextStepSectionImpl', () {
    late TrainingStepService service;
    
    setUp(() {
      service = TrainingStepService();
      service.resetProgress();
    });
    testWidgets('renders title, description, and text field', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EnterTextStepSectionImpl(
            title: 'Enter Text',
            description: 'Type something',
            isEditable: true,
            isCompleted: false,
            initialValue: '',
            ),
        ),
      ));

      expect(find.text('Enter Text'), findsOneWidget);
      expect(find.text('Type something'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('saves text to service when entered', (WidgetTester tester) async {
      const stepId = 0;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EnterTextStepSectionImpl(
            title: 'Enter Text',
            description: 'Type something',
            isEditable: true,
            isCompleted: false,
            initialValue: '',
          ),
        ),
      ));

      // Enter text in the field
      await tester.enterText(find.byType(TextField), 'Hello world');
      await tester.pump();
      
      // Verify the text was saved to the service
      expect(service.getStepInput(stepId), equals('Hello world'));
    });

    testWidgets('validate returns true when text is not empty', (WidgetTester tester) async {
      const stepId = 0;
      service.setStepInput(stepId, 'Hello world');
      
      final widget = EnterTextStepSectionImpl(
        title: 'Enter Text',
        description: 'Type something',
        isEditable: true,
        isCompleted: false,
        initialValue: 'Hello world',
      );
      
      expect(widget.validate(), isTrue);
    });
    
    testWidgets('validate returns false when text is empty', (WidgetTester tester) async {
      const stepId = 0;
      service.setStepInput(stepId, ''); // Empty text
      
      final widget = EnterTextStepSectionImpl(
        title: 'Enter Text',
        description: 'Type something',
        isEditable: true,
        isCompleted: false,
        initialValue: '',
      );
      
      expect(widget.validate(), isFalse);
    });
    
    testWidgets('renders as read-only when not editable', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EnterTextStepSectionImpl(
            title: 'Enter Text',
            description: 'Type something',
            isEditable: false,
            isCompleted: true,
            initialValue: 'some text',
            ),
        ),
      ));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
      expect(find.text('Step completed'), findsOneWidget);
    });
    
    testWidgets('initializes with correct initial value', (WidgetTester tester) async {
      const initialText = 'Initial text value';
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EnterTextStepSectionImpl(
            title: 'Enter Text',
            description: 'Type something',
            isEditable: true,
            isCompleted: false,
            initialValue: initialText,
          ),
        ),
      ));
      
      // Find the TextField and verify its controller has the initial value
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, equals(initialText));
    });
    
    testWidgets('maintains cursor position when typing', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EnterTextStepSectionImpl(
            title: 'Enter Text',
            description: 'Type something',
            isEditable: true,
            isCompleted: false,
            initialValue: '',
          ),
        ),
      ));
      
      // Get the text field
      final textField = find.byType(TextField);
      
      // Enter some text
      await tester.enterText(textField, 'Hello');
      await tester.pump();
      
      // Get the controller
      final controller = (tester.widget<TextField>(textField).controller as TextEditingController);
      
      // Set cursor position to the middle
      controller.selection = TextSelection.fromPosition(const TextPosition(offset: 2));
      await tester.pump();
      
      // Type more text at that position
      await tester.enterText(textField, 'Hel_lo');
      await tester.pump();
      
      // Verify the text and that the service was updated
      expect(controller.text, equals('Hel_lo'));
      expect(service.getStepInput(0), equals('Hel_lo'));
    });
  });
}
