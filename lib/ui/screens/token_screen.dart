import 'package:flutter/material.dart';
import 'package:llmdemoapp/core/models/tokenizer.dart';
import 'package:llmdemoapp/core/models/vocabulary.dart';

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
        title: const Text('Tokenizer'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tokenizer type selection
            Row(
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
            ),
            const SizedBox(height: 16),
            
            // Text input field
            TextField(
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
            ),
            const SizedBox(height: 16),
            
            // Token count
            Text(
              'Tokens: ${_tokens.length}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            // Tokens grid
            Expanded(
              child: _tokens.isEmpty
                ? const Center(child: Text('Enter text to see tokens'))
                : GridView.builder(
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

// Using TokenizerType from tokenizer.dart
