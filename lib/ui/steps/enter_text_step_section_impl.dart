import 'package:flutter/material.dart';
import 'package:llmdemoapp/core/services/training_step_service.dart';
import 'training_step_section.dart';

class EnterTextStepSectionImpl extends StatefulWidget
    implements TrainingStepSection {
  @override
  final String title;
  @override
  final String description;
  @override
  final bool isEditable;
  @override
  final bool isCompleted;
  final String initialValue;


  const EnterTextStepSectionImpl({
    super.key,
    required this.title,
    required this.description,
    required this.isEditable,
    required this.isCompleted,
    required this.initialValue,

  });

  @override
  @override
  bool validate() {
    final service = TrainingStepService();
    // The step ID is assumed to be 0 for this specific widget.
    // A more robust solution would pass the stepId in.
    final text = service.getStepInput(0);
    return text != null && text.trim().isNotEmpty;
  }

  @override
  State<EnterTextStepSectionImpl> createState() =>
      _EnterTextStepSectionImplState();
}

class _EnterTextStepSectionImplState extends State<EnterTextStepSectionImpl> {
  late final TextEditingController _controller;
  final TrainingStepService _stepService = TrainingStepService();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(() {
      // Save directly to the service, no need to call back to parent
      // The step ID is assumed to be 0 for this specific widget.
      _stepService.setStepInput(0, _controller.text);
    });
  }

  @override
  void didUpdateWidget(covariant EnterTextStepSectionImpl oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update the controller's text if the initialValue has actually changed.
    // This prevents the cursor from jumping to the end on every keystroke.
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(widget.description),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          enabled: widget.isEditable,
          decoration: const InputDecoration(
            labelText: 'Enter your training text',
            border: OutlineInputBorder(),
          ),
          // The controller's listener handles saving the text to the service.
          onChanged: null,
        ),
        if (!widget.isEditable && widget.isCompleted)
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
