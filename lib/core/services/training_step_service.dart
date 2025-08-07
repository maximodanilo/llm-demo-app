import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage training step completion state
class TrainingStepService extends ChangeNotifier {
  // Singleton pattern
  static final TrainingStepService _instance = TrainingStepService._internal();
  
  factory TrainingStepService() {
    return _instance;
  }
  
  TrainingStepService._internal() {
    // Load saved progress when the service is initialized
    _loadProgress();
  }
  
  // Keys for shared preferences
  static const String _completedStepsKey = 'completed_steps';
  static const String _stepInputsKey = 'step_inputs';
  
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
      'description': 'Learn how tokens are converted to numerical IDs',
      'icon': Icons.numbers,
      'color': Colors.orange,
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
    _saveProgress();
    notifyListeners();
  }
  
  // Reset all step progress
  void resetProgress() {
    _completedSteps.clear();
    _stepInputs.clear();
    _saveProgress();
    notifyListeners();
  }

  // Set input data for a step
  void setStepInput(int stepId, String input) {
    _stepInputs[stepId] = input;
    _saveProgress();
    notifyListeners();
  }
  
  // Save progress to persistent storage
  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save completed steps as a JSON string of integers
      final completedStepsList = _completedSteps.toList();
      await prefs.setString(_completedStepsKey, jsonEncode(completedStepsList));
      
      // Save step inputs as a JSON string of key-value pairs
      final stepInputsMap = {};
      _stepInputs.forEach((key, value) {
        stepInputsMap[key.toString()] = value;
      });
      await prefs.setString(_stepInputsKey, jsonEncode(stepInputsMap));
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }
  
  // Load progress from persistent storage
  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load completed steps
      final completedStepsJson = prefs.getString(_completedStepsKey);
      if (completedStepsJson != null) {
        final List<dynamic> completedStepsList = jsonDecode(completedStepsJson);
        _completedSteps.clear();
        _completedSteps.addAll(completedStepsList.map((step) => step as int));
      }
      
      // Load step inputs
      final stepInputsJson = prefs.getString(_stepInputsKey);
      if (stepInputsJson != null) {
        final Map<String, dynamic> stepInputsMap = jsonDecode(stepInputsJson);
        _stepInputs.clear();
        stepInputsMap.forEach((key, value) {
          _stepInputs[int.parse(key)] = value as String;
        });
      }
      
      // Notify listeners that data has been loaded
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading progress: $e');
    }
  }

  // Get input data for a step
  String? getStepInput(int stepId) {
    return _stepInputs[stepId];
  }
}
