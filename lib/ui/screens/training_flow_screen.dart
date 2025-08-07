import 'package:flutter/material.dart';
import '../steps/enter_text_step_section_impl.dart';
import '../../core/services/training_step_service.dart';

class TrainingFlowScreen extends StatefulWidget {
  final int stepIndex;
  
  const TrainingFlowScreen({super.key, required this.stepIndex});

  @override
  State<TrainingFlowScreen> createState() => _TrainingFlowScreenState();
}

class _TrainingFlowScreenState extends State<TrainingFlowScreen> {
  String? _enteredText;
  bool _stepCompleted = false;
  final TrainingStepService _stepService = TrainingStepService();

  void _onTextSubmitted(String text) {
    setState(() {
      _enteredText = text;
      _stepCompleted = text.trim().isNotEmpty;
    });
    
    // Validate the step before marking it as complete
    if (text.trim().isNotEmpty) {
      // In a real implementation, we would call the step's validate method
      _stepService.completeStep(widget.stepIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("LLM Training Flow - Step ${widget.stepIndex + 1}")),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          EnterTextStepSectionImpl(
            title: "Enter Training Text",
            description: "Type your training sentence to begin the process.",
            isEditable: !_stepCompleted,
            isCompleted: _stepCompleted,
            initialValue: _enteredText ?? '',
            onTextSubmitted: _onTextSubmitted,
          ),
          if (_stepCompleted)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Text(
                'You entered: "${_enteredText ?? ''}"',
                style: const TextStyle(fontSize: 18, color: Colors.blueGrey),
              ),
            ),
        ],
      ),
    );
  }
}
