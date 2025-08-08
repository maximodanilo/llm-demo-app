import 'package:flutter/material.dart';
import 'package:llmdemoapp/core/services/training_step_service.dart';
import 'package:llmdemoapp/ui/steps/enter_text_step_section_impl.dart';
import 'package:llmdemoapp/ui/steps/token_to_id_step_section_impl.dart';
import 'package:llmdemoapp/ui/steps/tokenization_step_section_impl.dart';
import 'package:llmdemoapp/ui/steps/training_step_section.dart';

class TrainingFlowScreen extends StatefulWidget {
  final int stepIndex;
  
  const TrainingFlowScreen({super.key, required this.stepIndex});

  @override
  State<TrainingFlowScreen> createState() => _TrainingFlowScreenState();
}

class _TrainingFlowScreenState extends State<TrainingFlowScreen> {
  final TrainingStepService _stepService = TrainingStepService();

  @override
  Widget build(BuildContext context) {
    final stepInfo = _stepService.steps[widget.stepIndex];
    final isCompleted = _stepService.isStepCompleted(widget.stepIndex);

    final stepWidget = _buildStepWidget(stepInfo, isCompleted);

    return Scaffold(
      appBar: AppBar(
        title: Text("LLM Training Flow - Step ${widget.stepIndex + 1}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset this step and all subsequent steps',
            onPressed: () => _showResetConfirmation(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            stepWidget,
            const SizedBox(height: 24),
            if (!isCompleted)
              ElevatedButton.icon(
                onPressed: () {
                  final stepWidgetForValidation = _buildStepWidget(stepInfo, true);

                  if (stepWidgetForValidation.validate()) {
                    if (widget.stepIndex == 0) {
                      _stepService.setStepInput(widget.stepIndex, _stepService.getStepInput(widget.stepIndex) ?? '');
                    }
                    _stepService.completeStep(widget.stepIndex);
                    
                    // Navigate to the next step if available, otherwise go back to home
                    final nextStepIndex = widget.stepIndex + 1;
                    if (nextStepIndex < _stepService.steps.length) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrainingFlowScreen(
                            stepIndex: nextStepIndex,
                          ),
                        ),
                      );
                    } else {
                      // If this was the last step, go back to home
                      Navigator.pop(context);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter some text to continue.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text('Complete Step'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50), // Make button wider
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // Show a confirmation dialog before resetting progress
  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Reset Progress'),
          content: Text(
            'This will reset your progress for step ${widget.stepIndex + 1} and all subsequent steps. '
            'Your progress on previous steps will be preserved. Are you sure?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                // Debug print before reset
                debugPrint('Before reset - Completed steps: ${_stepService.completedSteps}');
                debugPrint('Current step index: ${widget.stepIndex}');
                
                // Reset progress from current step onwards
                _stepService.resetProgressFromStep(widget.stepIndex);
                
                // Debug print after reset
                debugPrint('After reset - Completed steps: ${_stepService.completedSteps}');
                
                // Close the dialog
                Navigator.of(dialogContext).pop();
                
                // Return to home screen
                Navigator.of(context).pop();
              },
              child: const Text('RESET', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  TrainingStepSection _buildStepWidget(Map<String, dynamic> stepInfo, bool isCompleted) {
    switch (widget.stepIndex) {
      case 0:
        return EnterTextStepSectionImpl(
          key: ValueKey(widget.stepIndex),
          title: stepInfo['title'],
          description: stepInfo['description'],
          isEditable: !isCompleted,
          isCompleted: isCompleted,
          initialValue: _stepService.getStepInput(widget.stepIndex) ?? '',

        );
      case 1:
        final previousStepInput = _stepService.getStepInput(0) ?? '';
        return TokenizationStepSectionImpl(
          key: ValueKey(widget.stepIndex),
          title: stepInfo['title'],
          description: stepInfo['description'],
          isEditable: !isCompleted,
          isCompleted: isCompleted,
          inputText: previousStepInput,
        );
      case 2:
        final previousStepInput = _stepService.getStepInput(0) ?? '';
        return TokenToIdStepSectionImpl(
          key: ValueKey(widget.stepIndex),
          title: stepInfo['title'],
          description: stepInfo['description'],
          isEditable: !isCompleted,
          isCompleted: isCompleted,
          inputText: previousStepInput,
        );
      default:
        return EnterTextStepSectionImpl(
          key: ValueKey(widget.stepIndex),
          title: 'Unknown Step',
          description: 'This step is not implemented yet.',
          isEditable: false,
          isCompleted: false,
          initialValue: '',
        );
    }
  }
}
