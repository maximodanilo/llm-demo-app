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
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
  
  void _tokenizeText() {
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
            setState(() {
              _tokens = [];
              _tokenIds = [];
            });
          },
        ),
      ),
      maxLines: 3,
      onChanged: (_) => _tokenizeText(),
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

