import 'package:flutter_test/flutter_test.dart';
import 'package:llmdemoapp/core/services/training_step_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Setup SharedPreferences mock
  SharedPreferences.setMockInitialValues({});
  group('TrainingStepService', () {
    late TrainingStepService service;

    setUp(() async {
      // Reset SharedPreferences mock for each test
      SharedPreferences.setMockInitialValues({});
      
      service = TrainingStepService();
      // Reset progress to ensure clean state for each test
      service.resetProgress();
      
      // Wait for any async operations to complete
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('resetProgressFromStep should reset current step and all subsequent steps', () {
      // Setup: Complete steps 0, 1, and 2
      service.setStepInput(0, 'Test input for step 0');
      service.completeStep(0);
      
      service.setStepInput(1, 'Test input for step 1');
      service.completeStep(1);
      
      service.setStepInput(2, 'Test input for step 2');
      service.completeStep(2);
      
      // Verify setup
      expect(service.completedSteps, contains(0));
      expect(service.completedSteps, contains(1));
      expect(service.completedSteps, contains(2));
      expect(service.getStepInput(0), equals('Test input for step 0'));
      expect(service.getStepInput(1), equals('Test input for step 1'));
      expect(service.getStepInput(2), equals('Test input for step 2'));
      
      // Act: Reset from step 1 onwards
      service.resetProgressFromStep(1);
      
      // Assert: Step 0 should remain completed, steps 1 and 2 should be reset
      expect(service.completedSteps, contains(0));
      expect(service.completedSteps, isNot(contains(1)));
      expect(service.completedSteps, isNot(contains(2)));
      
      // Step 0 input should remain, steps 1 and 2 inputs should be reset
      expect(service.getStepInput(0), equals('Test input for step 0'));
      expect(service.getStepInput(1), isNull);
      expect(service.getStepInput(2), isNull);
    });
    
    test('resetProgress should reset all steps', () {
      // Setup: Complete steps 0 and 1
      service.setStepInput(0, 'Test input');
      service.completeStep(0);
      service.completeStep(1);
      
      // Act: Reset all progress
      service.resetProgress();
      
      // Assert: No steps should be completed
      expect(service.completedSteps, isEmpty);
      expect(service.getStepInput(0), isNull);
    });
  });
}
