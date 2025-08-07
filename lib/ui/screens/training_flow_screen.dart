import 'package:flutter/material.dart';
import '../steps/enter_text_step_section_impl.dart';

class TrainingFlowScreen extends StatefulWidget {
  const TrainingFlowScreen({Key? key}) : super(key: key);

  @override
  State<TrainingFlowScreen> createState() => _TrainingFlowScreenState();
}

class _TrainingFlowScreenState extends State<TrainingFlowScreen> {
  String? _enteredText;
  bool _stepCompleted = false;

  void _onTextSubmitted(String text) {
    setState(() {
      _enteredText = text;
      _stepCompleted = text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("LLM Training Flow")),
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
