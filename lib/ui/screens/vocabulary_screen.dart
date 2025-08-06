import 'package:flutter/material.dart';
import 'package:llmdemoapp/core/models/tokenizer.dart';
import 'package:llmdemoapp/core/models/vocabulary.dart';

class VocabularyScreen extends StatefulWidget {
  final ITokenizer tokenizer;
  final List<String> tokens;
  final List<int> tokenIds;

  const VocabularyScreen({
    Key? key,
    required this.tokenizer,
    required this.tokens,
    required this.tokenIds,
  }) : super(key: key);

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  late IVocabulary _vocabulary;
  late Map<String, int> _vocabularyMap;
  late Map<int, String> _reverseVocabularyMap; // Used for token ID lookup
  
  @override
  void initState() {
    super.initState();
    _vocabulary = widget.tokenizer.vocabulary;
    _vocabularyMap = _vocabulary.getVocabularyMap();
    _reverseVocabularyMap = _vocabulary.getReverseVocabularyMap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTokensSection(),
          const Divider(thickness: 2),
          _buildVocabularySection(),
        ],
      ),
    );
  }

  Widget _buildTokensSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tokens from Previous Step',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Input text was tokenized into ${widget.tokens.length} tokens',
            style: const TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.tokens.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(right: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.tokens[index],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${widget.tokenIds[index]}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVocabularySection() {
    final vocabEntries = _vocabularyMap.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Complete Vocabulary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_vocabularyMap.length} entries',
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: vocabEntries.length,
                itemBuilder: (context, index) {
                  final entry = vocabEntries[index];
                  final isSpecialToken = entry.key.startsWith('[') && 
                                        entry.key.endsWith(']');
                  final isInTokens = widget.tokens.contains(entry.key);
                  
                  return Card(
                    elevation: 2,
                    color: isInTokens 
                        ? Theme.of(context).colorScheme.primaryContainer 
                        : isSpecialToken 
                            ? Theme.of(context).colorScheme.secondaryContainer
                            : null,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontWeight: isSpecialToken || isInTokens 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                              fontSize: 14,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${entry.value} ${_reverseVocabularyMap[entry.value] == entry.key ? "✓" : ""}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Vocabulary'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'The vocabulary maps tokens to unique IDs.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Special tokens are highlighted in blue',
              ),
              Text(
                '• Tokens from your input are highlighted in purple',
              ),
              SizedBox(height: 8),
              Text(
                'In a language model, each token is represented by its ID, '
                'which is used to look up the corresponding embedding vector.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
