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
    {
      'id': 2,
      'title': 'Token to ID Mapping',
      'description': 'Tokens mapped to vocabulary indices',
      'icon': Icons.numbers,
      'color': Colors.orange,
    },
    {
      'id': 3,
      'title': 'Embedding Lookup',
      'description': 'Token IDs mapped to embedding vectors',
      'icon': Icons.view_module,
      'color': Colors.purple,
    },
    {
      'id': 4,
      'title': 'Positional Encoding',
      'description': 'Embeddings enhanced with positional information',
      'icon': Icons.location_on,
      'color': Colors.teal,
    },
    {
      'id': 5,
      'title': 'Attention Mechanism',
      'description': 'Visualize how tokens attend to each other',
      'icon': Icons.visibility,
      'color': Colors.indigo,
    },
    {
      'id': 6,
      'title': 'Feedforward Processing',
      'description': 'Embeddings processed through transformer layers',
      'icon': Icons.layers,
      'color': Colors.deepOrange,
    },
    {
      'id': 7,
      'title': 'Output Prediction',
      'description': 'See model\'s output probabilities and predictions',
      'icon': Icons.auto_awesome,
      'color': Colors.pink,
    },
  ];
  
  // Track completed steps
  final Set<int> _completedSteps = {}; // No steps are completed initially
  
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
    notifyListeners();
  }
}
