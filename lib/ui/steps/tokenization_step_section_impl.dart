import 'package:flutter/material.dart';
import 'package:llmdemoapp/core/models/tokenizer.dart';
import 'package:llmdemoapp/ui/steps/training_step_section.dart';
import 'package:llmdemoapp/ui/widgets/collapsible_education_section.dart';

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
        // Educational content about tokenization
        CollapsibleEducationSection(
          title: 'What is Tokenization?',
          themeColor: Colors.green,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tokenization is the process of breaking text into smaller units called tokens. These tokens are the basic units that language models process.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text(
                'Types of tokenization:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('• Word-based: Splits text by spaces and punctuation'),
                    Text('• Character-based: Treats each character as a token'),
                    Text('• Subword-based: Uses algorithms like BPE, WordPiece, or SentencePiece'),
                    Text('• Byte-level: Works with raw bytes instead of Unicode characters'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Modern LLMs typically use subword tokenization, which balances vocabulary size and semantic meaning by breaking uncommon words into smaller subword units.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
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
