import 'package:flutter/material.dart';
import 'package:llmdemoapp/ui/steps/training_step_section.dart';
import 'package:llmdemoapp/ui/widgets/collapsible_education_section.dart';

/// Widget that demonstrates how positional encoding is added to embeddings
class PositionalEncodingStepSectionImpl extends StatelessWidget
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

  const PositionalEncodingStepSectionImpl({
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Educational content about positional encoding
        CollapsibleEducationSection(
          title: 'What is Positional Encoding?',
          themeColor: Colors.teal,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Positional encoding adds information about token position in the sequence to the embedding vectors. This is crucial because transformer models process all tokens in parallel and would otherwise lose sequence order information.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text(
                'Key concepts:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('• Sine/Cosine Functions: Most models use sinusoidal functions at different frequencies'),
                    Text('• Unique Position Signatures: Each position gets a unique encoding pattern'),
                    Text('• Learned vs. Fixed: Some models learn position embeddings, others use fixed formulas'),
                    Text('• Vector Addition: Position vectors are added directly to token embeddings'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Without positional encoding, the model would treat "The cat chased the mouse" and "The mouse chased the cat" as identical sequences since they contain the same tokens.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Placeholder for positional encoding visualization
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Positional Encoding Visualization',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'This step would show a visualization of how positional encoding vectors are added to token embeddings.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                // Placeholder for visualization
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: const Center(
                    child: Text(
                      'Positional Encoding Visualization\n(To be implemented)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Formula explanation
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Positional Encoding Formula',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'For position pos and dimension i:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PE(pos, 2i) = sin(pos / 10000^(2i/d))\nPE(pos, 2i+1) = cos(pos / 10000^(2i/d))',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Where d is the embedding dimension. This formula creates a unique pattern for each position that the model can learn to interpret.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
