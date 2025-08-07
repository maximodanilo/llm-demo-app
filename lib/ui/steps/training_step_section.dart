import 'package:flutter/widgets.dart';

/// Interface for a training flow step section.
abstract class TrainingStepSection extends Widget {
  const TrainingStepSection({super.key});

  String get title;
  String get description;
  bool get isEditable;
  bool get isCompleted;
  
  /// Validates the step and returns whether it is valid
  bool validate();
}
