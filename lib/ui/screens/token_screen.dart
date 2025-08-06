import 'package:flutter/material.dart';
import 'package:llmdemoapp/core/models/tokenizer.dart';
import 'package:llmdemoapp/core/models/tokenizer_wrapper.dart';
import 'package:llmdemoapp/core/models/vocabulary.dart';
import 'package:llmdemoapp/ui/screens/vocabulary_screen.dart';

// Using TokenizerWithVocabulary from core/models/tokenizer_wrapper.dart

/// Screen for tokenizing text and displaying tokens and their IDs
class TokenScreen extends StatefulWidget {
  const TokenScreen({super.key});

  @override
  State<TokenScreen> createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  final TextEditingController _textController = TextEditingController();
  final ITokenizer _wordTokenizer = TokenizerFactory.createTokenizer(TokenizerType.word);
  final ITokenizer _subwordTokenizer = TokenizerFactory.createTokenizer(TokenizerType.subword);
  
  TokenizerType _selectedTokenizerType = TokenizerType.word;
  List<String> _tokens = [];
  List<int> _tokenIds = [];
  List<String> _sentenceHistory = [];
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
  
  void _tokenizeText() {
    // If we have sentences in history, process all of them together with current text
    if (_sentenceHistory.isNotEmpty) {
      _processAllSentences();
      return;
    }
    
    final text = _textController.text;
    if (text.isEmpty) {
      setState(() {
        _tokens = [];
        _tokenIds = [];
      });
      return;
    }
    
    final tokenizer = _selectedTokenizerType == TokenizerType.word 
        ? _wordTokenizer 
        : _subwordTokenizer;
    
    final tokens = tokenizer.encode(text);
    final tokenIds = tokenizer.tokensToIds(tokens);
    
    setState(() {
      _tokens = tokens;
      _tokenIds = tokenIds;
    });
  }
  
  void _addCurrentTextToHistory() {
    final text = _textController.text;
    if (text.isEmpty) return;
    
    // Add the current text to the sentence history
    setState(() {
      if (!_sentenceHistory.contains(text)) {
        _sentenceHistory.add(text);
      }
    });
    
    // Clear the text field for the next sentence
    _textController.clear();
    
    // Process all sentences automatically
    _processAllSentences();
    
    // Show a confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sentence added to history'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _sentenceHistory.removeLast();
              _processAllSentences(); // Process again after removing
            });
          },
        ),
      ),
    );
  }
  
  void _processAllSentences() {
    if (_sentenceHistory.isEmpty) {
      // If no sentences in history, just process the current text
      _tokenizeText();
      return;
    }
    
    final tokenizer = _selectedTokenizerType == TokenizerType.word 
        ? _wordTokenizer 
        : _subwordTokenizer;
    
    // Process all sentences in history plus current text if not empty
    final allSentences = List<String>.from(_sentenceHistory);
    if (_textController.text.isNotEmpty && !allSentences.contains(_textController.text)) {
      allSentences.add(_textController.text);
    }
    
    // Combine all tokens from all sentences
    final List<String> allTokens = [];
    
    for (final sentence in allSentences) {
      final tokens = tokenizer.encode(sentence);
      allTokens.addAll(tokens);
    }
    
    // Get unique tokens (vocabulary building)
    final uniqueTokens = allTokens.toSet().toList();
    final tokenIds = tokenizer.tokensToIds(uniqueTokens);
    
    setState(() {
      _tokens = uniqueTokens;
      _tokenIds = tokenIds;
    });
  }
  
  void _clearHistory() {
    setState(() {
      _sentenceHistory = [];
      _tokens = [];
      _tokenIds = [];
      _textController.clear();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Token'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTokenizerTypeSelector(),
            const SizedBox(height: 16),
            _buildTextInput(),
            const SizedBox(height: 8),
            _buildTextInputActions(),
            if (_sentenceHistory.isNotEmpty) ...[  
              const SizedBox(height: 16),
              _buildSentenceHistory(),
            ],
            const SizedBox(height: 16),
            _buildTokensDisplay(),
            const SizedBox(height: 16),
            _buildNextStepButton(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTokenizerTypeSelector() {
    return Row(
      children: [
        const Text('Tokenizer Type:'),
        const SizedBox(width: 16),
        SegmentedButton<TokenizerType>(
          segments: const [
            ButtonSegment(
              value: TokenizerType.word,
              label: Text('Word'),
              icon: Icon(Icons.text_fields),
            ),
            ButtonSegment(
              value: TokenizerType.subword,
              label: Text('Subword'),
              icon: Icon(Icons.text_format),
            ),
          ],
          selected: {_selectedTokenizerType},
          onSelectionChanged: (Set<TokenizerType> selection) {
            setState(() {
              _selectedTokenizerType = selection.first;
              if (_textController.text.isNotEmpty) {
                _tokenizeText();
              } else if (_sentenceHistory.isNotEmpty) {
                _processAllSentences();
              }
            });
          },
        ),
      ],
    );
  }
  
  Widget _buildTextInput() {
    return TextField(
      controller: _textController,
      decoration: InputDecoration(
        labelText: 'Enter text to tokenize',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _textController.clear();
            if (_sentenceHistory.isEmpty) {
              setState(() {
                _tokens = [];
                _tokenIds = [];
              });
            }
          },
        ),
      ),
      maxLines: 3,
      onChanged: (_) => _tokenizeText(),
    );
  }
  
  Widget _buildTextInputActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: _addCurrentTextToHistory,
          icon: const Icon(Icons.add),
          label: const Text('Add to History'),
        ),
      ],
    );
  }
  
  Widget _buildSentenceHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sentence History (${_sentenceHistory.length}):',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _clearHistory,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Clear'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            itemCount: _sentenceHistory.length,
            itemBuilder: (context, index) {
              return ListTile(
                dense: true,
                title: Text(
                  _sentenceHistory[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  onPressed: () {
                    setState(() {
                      _sentenceHistory.removeAt(index);
                      if (_sentenceHistory.isEmpty && _textController.text.isEmpty) {
                        _tokens = [];
                        _tokenIds = [];
                      } else {
                        _processAllSentences();
                      }
                    });
                  },
                ),
                onTap: () {
                  _textController.text = _sentenceHistory[index];
                  _tokenizeText();
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildTokensDisplay() {
    if (_tokens.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            'Enter text above to see tokens',
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tokens (${_tokens.length}):',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _tokens.length,
              itemBuilder: (context, index) {
                return TokenCard(
                  token: _tokens[index],
                  tokenId: _tokenIds[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNextStepButton() {
    if (_tokens.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          // Create a vocabulary instance from the current tokens
          final vocabulary = Vocabulary();
          for (final token in _tokens) {
            vocabulary.addToken(token);
          }
          
          // Create a tokenizer wrapper that provides the vocabulary getter
          final tokenizer = _selectedTokenizerType == TokenizerType.word
              ? _createTokenizerWithVocabulary(_wordTokenizer, vocabulary)
              : _createTokenizerWithVocabulary(_subwordTokenizer, vocabulary);
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VocabularyScreen(
                tokenizer: tokenizer,
                tokens: _tokens,
                tokenIds: _tokenIds,
              ),
            ),
          );
        },
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Next Step: Vocabulary'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
  
  // Helper method to create a tokenizer wrapper with vocabulary support
  ITokenizer _createTokenizerWithVocabulary(ITokenizer baseTokenizer, IVocabulary vocab) {
    // Use the TokenizerWithVocabulary class from the core models
    return TokenizerWithVocabulary(baseTokenizer, vocab);
  }
  
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Tokenization'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tokenization is the process of breaking text into smaller units called tokens.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Word Tokenizer:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '• Splits text by spaces and punctuation',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                '• Each word becomes a separate token',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                'Subword Tokenizer:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '• Breaks words into meaningful subword units',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                '• More efficient for representing large vocabularies',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                '• Better handles rare words and morphology',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                'Multiple Sentences:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '• Add sentences to build a more comprehensive vocabulary',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                '• Automatically combines tokens from all sentences in history',
                style: TextStyle(fontSize: 14),
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

/// Card widget to display a token and its ID
class TokenCard extends StatelessWidget {
  final String token;
  final int tokenId;
  
  const TokenCard({
    super.key,
    required this.token,
    required this.tokenId,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              token,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'ID: $tokenId',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

