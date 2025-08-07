import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llmdemoapp/ui/steps/enter_text_step_section_impl.dart';

void main() {
  group('EnterTextStepSectionImpl', () {
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

    testWidgets('calls onTextSubmitted when submitted', (WidgetTester tester) async {
      String? submittedText;
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

      await tester.enterText(find.byType(TextField), 'Hello world');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(submittedText, 'Hello world');
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
  });
}
