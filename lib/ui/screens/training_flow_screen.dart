import 'package:flutter/material.dart';
import 'package:llmdemoapp/core/services/training_step_service.dart';
import 'package:llmdemoapp/ui/steps/embedding_lookup_step_section_impl.dart';
import 'package:llmdemoapp/ui/steps/enter_text_step_section_impl.dart';
import 'package:llmdemoapp/ui/steps/positional_encoding_step_section_impl.dart';
import 'package:llmdemoapp/ui/steps/token_to_id_step_section_impl.dart';
import 'package:llmdemoapp/ui/steps/tokenization_step_section_impl.dart';

@immutable
class TrainingFlowScreen extends StatefulWidget {
  final int initialStepIndex;
  
  const TrainingFlowScreen({super.key, required this.initialStepIndex});

  @override
  State<TrainingFlowScreen> createState() => _TrainingFlowScreenState();
}

class _TrainingFlowScreenState extends State<TrainingFlowScreen> {
  final TrainingStepService _stepService = TrainingStepService();
  final ScrollController _scrollController = ScrollController();
  late int currentStepIndex;
  
  @override
  void initState() {
    super.initState();
    // Initialize current step index from widget's initial value
    currentStepIndex = widget.initialStepIndex;
    
    // Scroll to the current step after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentStep();
    });
  }
  
  void _scrollToCurrentStep() {
    if (_scrollController.hasClients) {
      // Calculate approximate position based on step index
      final targetPosition = currentStepIndex * 250.0; // Approximate height per step
      
      // Scroll to the calculated position with animation
      _scrollController.animateTo(
        targetPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> allSteps = [];
    final String? originalText = _stepService.getStepInput(0);
    
    // Build all steps (completed, current, and locked)
    for (int i = 0; i < _stepService.steps.length; i++) {
      final stepInfo = _stepService.steps[i];
      final isCompleted = _stepService.isStepCompleted(i);
      final isCurrentStep = i == currentStepIndex;
      final isUnlocked = _stepService.isStepUnlocked(i);
      
      // Create step header
      final stepHeader = Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: stepInfo['color'],
              shape: BoxShape.circle,
              boxShadow: isCurrentStep ? [
                BoxShadow(
                  color: stepInfo['color'].withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ] : null,
            ),
            child: Text(
              '${i + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            stepInfo['title'],
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (isCompleted)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  tooltip: 'Reset this step',
                  onPressed: () {
                    // Show confirmation dialog for this specific step
                    _showResetStepConfirmation(context, i);
                  },
                ),
              ],
            )
          else if (!isUnlocked)
            const Icon(Icons.lock_outline, color: Colors.grey)
          else if (isCurrentStep)
            Icon(Icons.arrow_right, color: stepInfo['color'])
        ],
      );
      
      // Create step content
      Widget stepContent;
      
      if (!isUnlocked) {
        // Locked step
        stepContent = Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Complete previous steps to unlock',
            style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
          ),
        );
      } else {
        // Unlocked step (either completed or current)
        stepContent = _buildStepWidget(stepInfo, isCompleted, i, originalText);
      }
      
      // Add step card
      allSteps.add(
        Card(
          key: ValueKey('step_$i'),
          margin: const EdgeInsets.only(bottom: 16.0),
          color: isCurrentStep 
              ? Theme.of(context).cardColor 
              : Theme.of(context).cardColor.withOpacity(0.9),
          elevation: isCurrentStep ? 4 : 1,
          shape: isCurrentStep 
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(color: stepInfo['color'], width: 2.0),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                stepHeader,
                if (isUnlocked) const Divider(height: 24),
                stepContent,
                if (isUnlocked && isCurrentStep && !isCompleted)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // For the first step, we need to check if text was entered
                        if (i == 0) {
                          final text = _stepService.getStepInput(0);
                          if (text == null || text.trim().isEmpty) {
                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter some text to continue.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                        }
                        
                        // Complete the step and update the UI in a single setState call
                        // to avoid the "step still running" issue
                        _stepService.completeStep(i);
                        
                        setState(() {
                          // Auto-scroll to the next step if not the last step
                          if (i < _stepService.steps.length - 1) {
                            // Automatically advance to the next step
                            currentStepIndex += 1;
                          }
                          
                          // Schedule scrolling after the UI has been updated
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToCurrentStep();
                          });
                        });
                      },
                      icon: const Icon(Icons.check),
                      label: Text(_getButtonLabel(i)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: stepInfo['color'],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                // Add Next Step button for completed steps
                if (isUnlocked && isCurrentStep && isCompleted && i < _stepService.steps.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Move to the next step
                        setState(() {
                          currentStepIndex += 1;
                          
                          // Scroll to the new current step
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToCurrentStep();
                          });
                        });
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next Step'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: stepInfo['color'],
                      ),
                    ),
                  ),
                // Add Home button for the last completed step
                if (isUnlocked && isCurrentStep && isCompleted && i == _stepService.steps.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Return to home screen
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Return to Home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: stepInfo['color'],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("LLM Training Flow"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset this step and all subsequent steps',
            onPressed: () => _showResetConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: allSteps,
        ),
      ),
    );
  }
  
  // Show a confirmation dialog before resetting progress from current step
  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Reset Progress'),
          content: Text(
            'This will reset your progress for step ${currentStepIndex + 1} and all subsequent steps. '
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
                debugPrint('Current step index: $currentStepIndex');
                
                // Reset progress from current step onwards
                _stepService.resetProgressFromStep(currentStepIndex);
                
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
  
  // Show a confirmation dialog before resetting a specific step
  void _showResetStepConfirmation(BuildContext context, int stepIndex) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Reset Step'),
          content: Text(
            'This will reset your progress for step ${stepIndex + 1} and all subsequent steps. '
            'Your progress on previous steps will be preserved. Are you sure?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                // Reset progress from the specified step onwards
                _stepService.resetProgressFromStep(stepIndex);
                
                // Close the dialog
                Navigator.of(dialogContext).pop();
                
                // Update the UI
                setState(() {
                  // If the reset step is before or equal to the current step,
                  // update the current step to the reset step
                  if (stepIndex <= currentStepIndex) {
                    currentStepIndex = stepIndex;
                  }
                  
                  // Scroll to the current step
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToCurrentStep();
                  });
                });
              },
              child: const Text('RESET', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Get the appropriate button label based on step index
  String _getButtonLabel(int stepIndex) {
    switch (stepIndex) {
      case 0:
        return 'Generate Tokens';
      case 1:
        return 'Map Tokens to IDs';
      case 2:
        return 'Generate Embedding Vectors';
      case 3:
        return 'Add Positional Encoding';
      case 4:
        return 'Apply Attention Mechanism';
      default:
        return 'Complete Step';
    }
  }

  Widget _buildStepWidget(Map<String, dynamic> stepInfo, bool isCompleted, int stepIndex, String? originalText) {
    // Use a consistent key for each step based on its index
    final valueKey = ValueKey('step_content_$stepIndex');
    
    switch (stepIndex) {
      case 0:
        return EnterTextStepSectionImpl(
          key: valueKey,
          title: stepInfo['title'],
          description: stepInfo['description'],
          isEditable: !isCompleted && stepIndex == currentStepIndex,
          isCompleted: isCompleted,
          initialValue: _stepService.getStepInput(0) ?? '',
        );
      case 1:
        // Use the original text from the first step
        return TokenizationStepSectionImpl(
          key: valueKey,
          title: stepInfo['title'],
          description: stepInfo['description'],
          isEditable: !isCompleted && stepIndex == currentStepIndex,
          isCompleted: isCompleted,
          inputText: originalText ?? '',
        );
      case 2:
        // Use the original text from the first step
        return TokenToIdStepSectionImpl(
          key: valueKey,
          title: stepInfo['title'],
          description: stepInfo['description'],
          isEditable: !isCompleted && stepIndex == currentStepIndex,
          isCompleted: isCompleted,
          inputText: originalText ?? '',
        );
      case 3:
        // Use the original text from the first step
        return EmbeddingLookupStepSectionImpl(
          key: valueKey,
          title: stepInfo['title'],
          description: stepInfo['description'],
          isEditable: !isCompleted && stepIndex == currentStepIndex,
          isCompleted: isCompleted,
          inputText: originalText ?? '',
        );
      case 4:
        // Use the original text from the first step
        return PositionalEncodingStepSectionImpl(
          key: valueKey,
          title: stepInfo['title'],
          description: stepInfo['description'],
          isEditable: !isCompleted && stepIndex == currentStepIndex,
          isCompleted: isCompleted,
          inputText: originalText ?? '',
        );
      default:
        return EnterTextStepSectionImpl(
          key: valueKey,
          title: 'Unknown Step',
          description: 'This step is not implemented yet.',
          isEditable: false,
          isCompleted: false,
          initialValue: '',
        );
    }
  }
}
