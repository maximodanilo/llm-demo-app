import 'package:flutter/material.dart';
import 'package:llmdemoapp/ui/screens/training_flow_screen.dart';
import 'package:llmdemoapp/core/services/training_step_service.dart';

/// Home screen for the LLM Demo App displaying all the educational steps
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Use the training step service to manage step state
  final TrainingStepService _stepService = TrainingStepService();
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _stepKeys = [];

  @override
  void initState() {
    super.initState();
    // Initialize GlobalKeys for each step
    for (int i = 0; i < _stepService.steps.length; i++) {
      _stepKeys.add(GlobalKey());
    }

    // Listen for changes in step completion status
    _stepService.addListener(_onStepServiceChanged);

    // Scroll to the current step after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentStep();
    });
  }
  
  void _onStepServiceChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _scrollToCurrentStep() {
    // Find the first incomplete step
    int currentStepIndex = _stepService.steps.indexWhere((s) => !_stepService.isStepCompleted(s['id']));

    // If all steps are completed, do nothing
    if (currentStepIndex == -1) {
      currentStepIndex = _stepService.steps.length - 1;
    }

    // Scroll to that step using its GlobalKey
    final key = _stepKeys[currentStepIndex];
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.5, // Center the item in the viewport
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _stepService.removeListener(_onStepServiceChanged);
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LLM Educational Flow'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Learn How Large Language Models Work',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Step through each phase of the LLM processing pipeline',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            // Steps as a scrollable feed
            Center(
              child: Column(
                children: List.generate(_stepService.steps.length, (index) {
                  final step = _stepService.steps[index];
                  final isUnlocked = _stepService.isStepUnlocked(index);
                  final isCompleted = _stepService.isStepCompleted(index);
            
                  return Container(
                    key: _stepKeys[index],
                    constraints: const BoxConstraints(maxWidth: 500), // Set max width for cards
                    child: _buildStepCard(
                      title: step['title'],
                      description: step['description'],
                      icon: step['icon'],
                      color: step['color'],
                      isUnlocked: isUnlocked,
                      isCompleted: isCompleted,
                      stepIndex: index,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isUnlocked,
    required bool isCompleted,
    required int stepIndex,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Card(
        elevation: 4,
        clipBehavior: Clip.none, // Allow the number to overflow
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          clipBehavior: Clip.none, // Allow the number to overflow
          children: [
            InkWell(
              onTap: isUnlocked
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrainingFlowScreen(initialStepIndex: stepIndex),
                        ),
                      );
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isUnlocked ? Colors.white : Colors.grey[200],
                  border: isUnlocked
                      ? Border.all(color: color, width: 2)
                      : null,
                  // Show a different style if the step is completed
                  gradient: isCompleted && stepIndex > 0 
                      ? LinearGradient(
                          colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ) 
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 40,
                      color: isUnlocked ? color : Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? Colors.black : Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isUnlocked ? Colors.black54 : Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (!isUnlocked)
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            'Complete previous step',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            // 3D step number indicator
            Positioned(
              top: -10,
              left: 10,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isUnlocked ? color : Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${stepIndex + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
