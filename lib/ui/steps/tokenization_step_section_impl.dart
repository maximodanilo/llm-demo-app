import 'package:flutter/material.dart';
import 'package:llmdemoapp/core/models/tokenizer.dart';
import 'package:llmdemoapp/ui/steps/training_step_section.dart';

class TokenizationStepSectionImpl extends StatelessWidget
    implements TrainingStepSection {
  @override
  final String title;
  @override
  final String description;
  @override
  final bool isEditable;
  @override
  final bool isCompleted;
  final String inputText;

  const TokenizationStepSectionImpl({
    super.key,
    required this.title,
    required this.description,
    required this.isEditable,
    required this.isCompleted,
    required this.inputText,
  });

  @override
  bool validate() {
    // This step is valid by default as it's a display of a process
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Use the WordTokenizer to process the input text
    final tokenizer = TokenizerFactory.createTokenizer(TokenizerType.word);
    final tokens = tokenizer.encode(inputText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Original Text:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            inputText,
            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Tokens:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: tokens.map((token) {
            return Chip(
              label: Text(token),
              backgroundColor: Colors.green.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.green.shade200),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
