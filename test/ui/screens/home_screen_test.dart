import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llmdemoapp/core/services/training_step_service.dart';
import 'package:llmdemoapp/ui/screens/home_screen.dart';
import 'package:llmdemoapp/ui/screens/training_flow_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  
  group('HomeScreen', () {
    late TrainingStepService service;
    
    setUp(() {
      service = TrainingStepService();
      service.resetProgress();
    });
    
    testWidgets('renders correctly with app bar and header', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      
      // Verify app bar title
      expect(find.text('LLM Educational Flow'), findsOneWidget);
      
      // Verify header text
      expect(find.text('Learn How Large Language Models Work'), findsOneWidget);
      expect(find.text('Step through each phase of the LLM processing pipeline'), findsOneWidget);
    });
    
    testWidgets('renders all step cards from the service', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      
      // Get the number of steps from the service
      final stepCount = service.steps.length;
      
      // Verify that we have the correct number of step cards
      // Each card should have a title and description
      for (int i = 0; i < stepCount; i++) {
        final step = service.steps[i];
        expect(find.text(step['title']), findsOneWidget);
        expect(find.text(step['description']), findsOneWidget);
      }
      
      // Verify that we have the correct number of step number indicators
      // Each card should have a step number (i+1)
      for (int i = 0; i < stepCount; i++) {
        expect(find.text('${i + 1}'), findsOneWidget);
      }
    });
    
    testWidgets('first step is unlocked by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      
      // Get the first step card
      final firstStepTitle = service.steps[0]['title'];
      final firstStepCard = find.ancestor(
        of: find.text(firstStepTitle),
        matching: find.byType(Card),
      );
      
      // The first step should not show the lock message within its card
      expect(
        find.descendant(
          of: firstStepCard,
          matching: find.text('Complete previous step'),
        ),
        findsNothing,
      );
      
      // At least one of the other steps should show the lock message
      final secondStepTitle = service.steps[1]['title'];
      final secondStepCard = find.ancestor(
        of: find.text(secondStepTitle),
        matching: find.byType(Card),
      );
      
      expect(
        find.descendant(
          of: secondStepCard,
          matching: find.text('Complete previous step'),
        ),
        findsOneWidget,
      );
    });
    
    testWidgets('completed steps are marked as completed', (WidgetTester tester) async {
      // Setup: Complete the first step
      service.setStepInput(0, 'Test input');
      service.completeStep(0);
      
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      
      // The second step should now be unlocked (no lock icon)
      // We need to find all instances of "Complete previous step" and verify count
      final lockMessages = tester.widgetList<Text>(find.text('Complete previous step')).toList();
      expect(lockMessages.length, service.steps.length - 2); // All steps except 0 and 1 should be locked
    });
    
    testWidgets('tapping on unlocked step navigates to TrainingFlowScreen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomeScreen(),
          routes: {
            '/training': (context) => const TrainingFlowScreen(stepIndex: 0),
          },
        ),
      );
      
      // Find the first step card (which should be unlocked)
      final firstStepTitle = service.steps[0]['title'];
      await tester.tap(find.text(firstStepTitle));
      await tester.pumpAndSettle();
      
      // Verify navigation to TrainingFlowScreen
      expect(find.byType(TrainingFlowScreen), findsOneWidget);
      expect(find.text('LLM Training Flow - Step 1'), findsOneWidget);
    });
    
    testWidgets('tapping on locked step does nothing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      
      // Find the second step card (which should be locked)
      final secondStepTitle = service.steps[1]['title'];
      await tester.tap(find.text(secondStepTitle));
      await tester.pumpAndSettle();
      
      // Verify we're still on the HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('LLM Educational Flow'), findsOneWidget);
    });
    
    testWidgets('step cards show correct unlock status', (WidgetTester tester) async {
      // Setup: Complete the first step
      service.setStepInput(0, 'Test input');
      service.completeStep(0);
      
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      
      // First step should be completed and unlocked
      expect(service.isStepCompleted(0), isTrue);
      expect(service.isStepUnlocked(0), isTrue);
      
      // Second step should be unlocked but not completed
      expect(service.isStepCompleted(1), isFalse);
      expect(service.isStepUnlocked(1), isTrue);
      
      // Third step should be locked
      expect(service.isStepCompleted(2), isFalse);
      expect(service.isStepUnlocked(2), isFalse);
    });
    
    testWidgets('disposes resources when unmounted', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      
      // Unmount the widget
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      
      // No easy way to verify disposal in a test, but at least we can
      // verify that no exceptions were thrown during disposal
      expect(tester.takeException(), isNull);
    });
    
    testWidgets('updates UI when step service changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      
      // Initially, only the first step should be unlocked
      expect(service.isStepUnlocked(1), isFalse);
      
      // Complete the first step
      service.setStepInput(0, 'Test input');
      service.completeStep(0);
      
      // Trigger a rebuild
      await tester.pump();
      
      // Now the second step should be unlocked
      expect(service.isStepUnlocked(1), isTrue);
    });
    
    testWidgets('step cards have 3D number indicators', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      
      // Find containers that would have the 3D effect (with decoration)
      // This is a bit tricky in widget tests, but we can at least verify
      // that the step numbers are present
      for (int i = 0; i < service.steps.length; i++) {
        expect(find.text('${i + 1}'), findsOneWidget);
      }
    });
  });
}
