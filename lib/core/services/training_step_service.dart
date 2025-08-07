import 'package:flutter/material.dart';

/// Service to manage training step completion state
class TrainingStepService extends ChangeNotifier {
  // Singleton pattern
  static final TrainingStepService _instance = TrainingStepService._internal();
  
  factory TrainingStepService() {
    return _instance;
  }
  
  TrainingStepService._internal();
  
  // Step information
  final List<Map<String, dynamic>> steps = [
    {
      'id': 0,
      'title': 'Enter Text',
      'description': 'Provide input text for the LLM to process',
      'icon': Icons.text_fields,
      'color': Colors.blue,
    },
    {
      'id': 1,
      'title': 'Tokenization',
      'description': 'See how text is split into tokens',
      'icon': Icons.splitscreen,
      'color': Colors.green,
    },
  ];
  
  // Track completed steps
  final Set<int> _completedSteps = {}; // No steps are completed initially

  // Track input data for each step
  final Map<int, String> _stepInputs = {};
  
  // Get completed steps
  Set<int> get completedSteps => Set.unmodifiable(_completedSteps);
  
  // Check if a step is completed
  bool isStepCompleted(int stepId) {
    return _completedSteps.contains(stepId);
  }
  
  // Check if a step is valid (can be considered complete)
  bool isStepValid(int stepId) {
    // For now, we'll just check if the step is completed
    // In a real implementation, this would call the step's validate() method
    return isStepCompleted(stepId);
  }
  
  // Check if a step is unlocked (available)
  bool isStepUnlocked(int stepId) {
    // First step is always unlocked
    if (stepId == 0) return true;
    
    // A step is unlocked if the previous step is completed
    return isStepCompleted(stepId - 1);
  }
  
  // Mark a step as completed
  void completeStep(int stepId) {
    _completedSteps.add(stepId);
    notifyListeners();
  }
  
  // Reset all step progress
  void resetProgress() {
    _completedSteps.clear();
    _stepInputs.clear();
    notifyListeners();
  }

  // Set input data for a step
  void setStepInput(int stepId, String input) {
    _stepInputs[stepId] = input;
    notifyListeners();
  }

  // Get input data for a step
  String? getStepInput(int stepId) {
    return _stepInputs[stepId];
  }
}
