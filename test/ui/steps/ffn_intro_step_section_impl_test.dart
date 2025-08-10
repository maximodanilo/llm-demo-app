import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llmdemoapp/ui/steps/ffn_intro_step_section_impl.dart';

void main() {
  group('FfnIntroStepSectionImpl', () {
    testWidgets('should render correctly', (WidgetTester tester) async {
      // Arrange
      const title = 'Feed-Forward Network';
      const description = 'Introduction to the Feed-Forward Network layer';
      const isEditable = true;
      const isCompleted = false;
      const inputText = 'Sample text';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 1200, // Larger height to ensure content fits
              child: FfnIntroStepSectionImpl(
                title: title,
                description: description,
                isEditable: isEditable,
                isCompleted: isCompleted,
                inputText: inputText,
                onStepCompleted: () {},
              ),
            ),
          ),
        ),
      );

      // Wait for the loading indicator to disappear
      await tester.pump(const Duration(milliseconds: 600));

      // Assert
      expect(find.text('What is a Feed-Forward Network?'), findsOneWidget);
      expect(find.text('Feed-Forward Network Overview'), findsOneWidget);
      expect(find.text('Real-World Analogy: Coffee Brewing'), findsOneWidget);
      
      // Check for the diagram - we now know there are multiple CustomPaint widgets
      expect(find.byType(CustomPaint), findsWidgets);
      
      // Check for the continue button
      expect(find.text('Continue to Next Step'), findsOneWidget);
    });

    testWidgets('should call onStepCompleted when continue button is pressed',
        (WidgetTester tester) async {
      // Arrange
      const title = 'Feed-Forward Network';
      const description = 'Introduction to the Feed-Forward Network layer';
      const isEditable = true;
      const isCompleted = false;
      const inputText = 'Sample text';
      bool stepCompleted = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 1200, // Larger height to ensure content fits
              child: FfnIntroStepSectionImpl(
                title: title,
                description: description,
                isEditable: isEditable,
                isCompleted: isCompleted,
                inputText: inputText,
                onStepCompleted: () {
                  stepCompleted = true;
                },
              ),
            ),
          ),
        ),
      );

      // Wait for the loading indicator to disappear
      await tester.pump(const Duration(milliseconds: 600));

      // Find and scroll to the continue button
      await tester.dragUntilVisible(
        find.text('Continue to Next Step'),
        find.byType(SingleChildScrollView),
        const Offset(0, 50),
      );
      
      // Find and tap the continue button
      final continueButton = find.text('Continue to Next Step');
      expect(continueButton, findsOneWidget);
      await tester.tap(continueButton);
      await tester.pump();

      // Assert
      expect(stepCompleted, true);
    });

    testWidgets('should not show continue button when not editable',
        (WidgetTester tester) async {
      // Arrange
      const title = 'Feed-Forward Network';
      const description = 'Introduction to the Feed-Forward Network layer';
      const isEditable = false;
      const isCompleted = false;
      const inputText = 'Sample text';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 1200, // Larger height to ensure content fits
              child: FfnIntroStepSectionImpl(
                title: title,
                description: description,
                isEditable: isEditable,
                isCompleted: isCompleted,
                inputText: inputText,
              ),
            ),
          ),
        ),
      );

      // Wait for the loading indicator to disappear
      await tester.pump(const Duration(milliseconds: 600));

      // Scroll through the entire widget to check for the button
      bool foundButton = false;
      try {
        await tester.dragUntilVisible(
          find.text('Continue to Next Step'),
          find.byType(SingleChildScrollView),
          const Offset(0, 50),
        );
        foundButton = true;
      } catch (e) {
        // Button not found, which is expected
        foundButton = false;
      }

      // Assert
      expect(foundButton, false);
    });

    testWidgets('should not show continue button when completed',
        (WidgetTester tester) async {
      // Arrange
      const title = 'Feed-Forward Network';
      const description = 'Introduction to the Feed-Forward Network layer';
      const isEditable = true;
      const isCompleted = true;
      const inputText = 'Sample text';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 1200, // Larger height to ensure content fits
              child: FfnIntroStepSectionImpl(
                title: title,
                description: description,
                isEditable: isEditable,
                isCompleted: isCompleted,
                inputText: inputText,
              ),
            ),
          ),
        ),
      );

      // Wait for the loading indicator to disappear
      await tester.pump(const Duration(milliseconds: 600));

      // Scroll through the entire widget to check for the button
      bool foundButton = false;
      try {
        await tester.dragUntilVisible(
          find.text('Continue to Next Step'),
          find.byType(SingleChildScrollView),
          const Offset(0, 50),
        );
        foundButton = true;
      } catch (e) {
        // Button not found, which is expected
        foundButton = false;
      }

      // Assert
      expect(foundButton, false);
    });

    test('validate should return true', () {
      // Arrange
      const widget = FfnIntroStepSectionImpl(
        title: 'Feed-Forward Network',
        description: 'Introduction to the Feed-Forward Network layer',
        isEditable: true,
        isCompleted: false,
        inputText: 'Sample text',
      );

      // Act & Assert
      expect(widget.validate(), true);
    });
  });
}
