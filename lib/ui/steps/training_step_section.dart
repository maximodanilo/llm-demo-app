import 'package:flutter/widgets.dart';

/// Interface for a training flow step section.
abstract class TrainingStepSection extends Widget {
  String get title;
  String get description;
  bool get isEditable;
  bool get isCompleted;
  // Optionally: validation, result extraction, etc.
}
