import 'dart:convert';
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
    // 1. Step completion and validation tests
    group('Step completion and validation', () {
      test('isStepCompleted should return correct completion status', () {
        // Initially no steps are completed
        expect(service.isStepCompleted(0), isFalse);
        expect(service.isStepCompleted(1), isFalse);
        
        // Complete step 0
        service.completeStep(0);
        
        // Verify step 0 is completed but step 1 is not
        expect(service.isStepCompleted(0), isTrue);
        expect(service.isStepCompleted(1), isFalse);
      });
      
      test('isStepValid should reflect completion status', () {
        // Initially no steps are valid (completed)
        expect(service.isStepValid(0), isFalse);
        
        // Complete step 0
        service.completeStep(0);
        
        // Verify step 0 is now valid
        expect(service.isStepValid(0), isTrue);
      });
      
      test('completedSteps getter should return unmodifiable set', () {
        service.completeStep(0);
        service.completeStep(1);
        
        final completedSteps = service.completedSteps;
        expect(completedSteps, contains(0));
        expect(completedSteps, contains(1));
        
        // Verify the set is unmodifiable
        expect(() => completedSteps.add(2), throwsUnsupportedError);
      });
    });
    
    // 2. Step input persistence tests
    group('Step input persistence', () {
      test('setStepInput and getStepInput should store and retrieve inputs correctly', () {
        // Initially no inputs are set
        expect(service.getStepInput(0), isNull);
        
        // Set input for step 0
        const testInput = 'This is a test input';
        service.setStepInput(0, testInput);
        
        // Verify input is stored correctly
        expect(service.getStepInput(0), equals(testInput));
      });
      
      test('Multiple step inputs should be stored independently', () {
        // Set inputs for multiple steps
        service.setStepInput(0, 'Input for step 0');
        service.setStepInput(1, 'Input for step 1');
        service.setStepInput(2, 'Input for step 2');
        
        // Verify each input is stored correctly
        expect(service.getStepInput(0), equals('Input for step 0'));
        expect(service.getStepInput(1), equals('Input for step 1'));
        expect(service.getStepInput(2), equals('Input for step 2'));
      });
      
      test('resetProgress should clear all step inputs', () {
        // Set inputs for multiple steps
        service.setStepInput(0, 'Input for step 0');
        service.setStepInput(1, 'Input for step 1');
        
        // Reset progress
        service.resetProgress();
        
        // Verify all inputs are cleared
        expect(service.getStepInput(0), isNull);
        expect(service.getStepInput(1), isNull);
      });
    });
    
    // 3. Step unlocking logic tests
    group('Step unlocking logic', () {
      test('First step should always be unlocked', () {
        expect(service.isStepUnlocked(0), isTrue);
      });
      
      test('Subsequent steps should be locked until previous step is completed', () {
        // Initially step 1 should be locked
        expect(service.isStepUnlocked(1), isFalse);
        
        // Complete step 0
        service.completeStep(0);
        
        // Now step 1 should be unlocked
        expect(service.isStepUnlocked(1), isTrue);
        
        // But step 2 should still be locked
        expect(service.isStepUnlocked(2), isFalse);
      });
      
      test('All steps should unlock in sequence as previous steps are completed', () {
        // Complete steps in sequence
        service.completeStep(0);
        expect(service.isStepUnlocked(1), isTrue);
        
        service.completeStep(1);
        expect(service.isStepUnlocked(2), isTrue);
      });
    });
    
    // 4. Persistence and loading tests
    group('Persistence and loading', () {
      // Create a more direct test approach that doesn't rely on the post-frame callback
      // Instead, we'll test the persistence and loading by using the service's methods directly
      
      test('setStepInput should save to SharedPreferences and be retrievable', () async {
        // Setup: Clear any existing data
        SharedPreferences.setMockInitialValues({});
        final service = TrainingStepService();
        
        // Act: Set a step input
        service.setStepInput(0, 'Test input for step 0');
        
        // Verify: The input can be retrieved from the service
        expect(service.getStepInput(0), equals('Test input for step 0'));
        
        // Create a new service instance to verify persistence
        final newService = TrainingStepService();
        
        // The new service should have the same data after loading from SharedPreferences
        // We'll manually trigger the loading since we can't rely on the post-frame callback in tests
        await newService.testOnlyLoadProgress();
        
        // Verify the data was loaded correctly
        expect(newService.getStepInput(0), equals('Test input for step 0'));
      });
      
      test('completeStep should save to SharedPreferences and be retrievable', () async {
        // Setup: Clear any existing data
        SharedPreferences.setMockInitialValues({});
        final service = TrainingStepService();
        
        // Act: Complete a step
        service.completeStep(0);
        
        // Verify: The step is marked as completed
        expect(service.isStepCompleted(0), isTrue);
        
        // Create a new service instance to verify persistence
        final newService = TrainingStepService();
        
        // Manually trigger loading
        await newService.testOnlyLoadProgress();
        
        // Verify the completed step was loaded correctly
        expect(newService.isStepCompleted(0), isTrue);
      });
      
      test('resetProgress should clear data from SharedPreferences', () async {
        // Setup: Initialize with some data
        SharedPreferences.setMockInitialValues({});
        final service = TrainingStepService();
        
        // Complete steps and set inputs
        service.setStepInput(0, 'Test input');
        service.completeStep(0);
        service.completeStep(1);
        
        // Verify setup
        expect(service.isStepCompleted(0), isTrue);
        expect(service.isStepCompleted(1), isTrue);
        expect(service.getStepInput(0), equals('Test input'));
        
        // Act: Reset progress
        service.resetProgress();
        
        // Verify: Data is cleared from the service
        expect(service.isStepCompleted(0), isFalse);
        expect(service.isStepCompleted(1), isFalse);
        expect(service.getStepInput(0), isNull);
        
        // Create a new service instance to verify persistence
        final newService = TrainingStepService();
        
        // Manually trigger loading
        await newService.testOnlyLoadProgress();
        
        // Verify the reset was persisted
        expect(newService.isStepCompleted(0), isFalse);
        expect(newService.isStepCompleted(1), isFalse);
        expect(newService.getStepInput(0), isNull);
      });
      
      test('if stepInputsJson is null, step inputs should remain empty', () async {
        // Setup: Initialize SharedPreferences with only completed steps, no inputs
        final List<dynamic> mockCompletedSteps = [0];
        
        SharedPreferences.setMockInitialValues({
          'completed_steps': jsonEncode(mockCompletedSteps),
          // No 'step_inputs' key
        });
        
        // Create a service and manually load progress
        final service = TrainingStepService();
        await service.testOnlyLoadProgress();
        
        // Verify completed steps were loaded
        expect(service.isStepCompleted(0), isTrue);
        
        // Verify step inputs are null (not loaded since they don't exist)
        expect(service.getStepInput(0), isNull);
        expect(service.getStepInput(1), isNull);
      });
      
      test('service should handle malformed step inputs JSON', () async {
        // Setup: Initialize SharedPreferences with invalid JSON for step inputs
        SharedPreferences.setMockInitialValues({
          'step_inputs': '{invalid json}', // Malformed JSON
        });
        
        // Create a service and manually load progress
        final service = TrainingStepService();
        await service.testOnlyLoadProgress();
        
        // Service should not crash and step inputs should be empty
        expect(service.getStepInput(0), isNull);
      });
    });
  });
}
