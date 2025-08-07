import 'package:flutter/material.dart';
import 'package:llmdemoapp/core/models/tokenizer.dart';
import 'package:llmdemoapp/ui/steps/training_step_section.dart';

/// Widget that demonstrates how tokens are converted to numerical IDs
class TokenToIdStepSectionImpl extends StatelessWidget
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

  const TokenToIdStepSectionImpl({
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
    final tokenIds = tokenizer.tokensToIds(tokens);
    
    // Create a list of token-ID pairs for display
    final tokenIdPairs = List.generate(
      tokens.length,
      (index) => MapEntry(tokens[index], tokenIds[index]),
    );

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
          'Token to ID Mapping:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Each token is assigned a unique numerical ID in the vocabulary:',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        // Display token-ID pairs in a grid
        Wrap(
          spacing: 8.0,
          runSpacing: 12.0,
          children: tokenIdPairs.map((pair) {
            return _buildTokenIdCard(pair.key, pair.value);
          }).toList(),
        ),
        const SizedBox(height: 24),
        // Display vocabulary information
        _buildVocabularyInfoSection(tokenizer),
      ],
    );
  }

  Widget _buildTokenIdCard(String token, int id) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              token,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Icon(Icons.arrow_downward, size: 16),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'ID: $id',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVocabularyInfoSection(ITokenizer tokenizer) {
    final vocabularySize = tokenizer.vocabularyMap.length;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vocabulary Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Total vocabulary size: $vocabularySize tokens',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Special predefined tokens:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            _buildSpecialTokensInfo(),
            const SizedBox(height: 12),
            const Text(
              'In real LLMs, vocabularies can contain tens of thousands of tokens.',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSpecialTokensInfo() {
    return Wrap(
      spacing: 8.0,
      children: [
        _buildSpecialTokenChip('[PAD]', 'Used for padding sequences to same length'),
        _buildSpecialTokenChip('[UNK]', 'Used for unknown tokens'),
        _buildSpecialTokenChip('[CLS]', 'Marks start of sequence'),
        _buildSpecialTokenChip('[SEP]', 'Marks end of sequence'),
      ],
    );
  }
  
  Widget _buildSpecialTokenChip(String token, String description) {
    return Tooltip(
      message: description,
      child: Chip(
        label: Text(token, style: const TextStyle(fontSize: 12)),
        backgroundColor: Colors.blue.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.blue.shade200),
        ),
      ),
    );
  }
}
