import 'package:flutter/material.dart';
import 'training_step_section.dart';

class EnterTextStepSectionImpl extends StatelessWidget
    implements TrainingStepSection {
  final String title;
  final String description;
  final bool isEditable;
  final bool isCompleted;
  final String initialValue;
  final ValueChanged<String> onTextSubmitted;

  const EnterTextStepSectionImpl({
    Key? key,
    required this.title,
    required this.description,
    required this.isEditable,
    required this.isCompleted,
    required this.initialValue,
    required this.onTextSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(description),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          enabled: isEditable,
          decoration: const InputDecoration(
            labelText: 'Enter your training text',
            border: OutlineInputBorder(),
          ),
          onSubmitted: isEditable ? onTextSubmitted : null,
        ),
        if (!isEditable && isCompleted)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              'Step completed',
              style: TextStyle(color: Colors.green),
            ),
          ),
      ],
    );
  }
}
