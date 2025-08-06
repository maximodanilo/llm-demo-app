
/// Interface defining the contract for vocabulary management
abstract class IVocabulary {
  /// Add a token to the vocabulary
  /// Returns the index assigned to the token
  int addToken(String token);
  
  /// Get the index for a given token
  /// Returns the index if found, or the unknown token index if not found
  int getTokenIndex(String token);
  
  /// Get the token for a given index
  /// Returns the token if found, or the unknown token if not found
  String getWordFromIndex(int index);
  
  /// Get the current size of the vocabulary
  int getSize();
  
  /// Check if a token exists in the vocabulary
  bool containsToken(String token);
  
  /// Get a copy of the current vocabulary mapping
  Map<String, int> getVocabularyMap();
  
  /// Get a copy of the current reverse vocabulary mapping
  Map<int, String> getReverseVocabularyMap();
}

/// Implementation of the vocabulary management interface
class Vocabulary implements IVocabulary {
  /// Mapping from tokens to indices
  final Map<String, int> _tokenToIndex = {};
  
  /// Mapping from indices to tokens
  final Map<int, String> _indexToToken = {};
  
  /// Special tokens
  static const String unkToken = '[UNK]';
  static const String padToken = '[PAD]';
  static const String startToken = '[CLS]';
  static const String endToken = '[SEP]';
  
  /// Constructor initializes with special tokens
  Vocabulary() {
    // Initialize special tokens
    _initializeSpecialTokens();
  }
  
  /// Initialize special tokens in the vocabulary
  void _initializeSpecialTokens() {
    addToken(unkToken);
    addToken(padToken);
    addToken(startToken);
    addToken(endToken);
  }
  
  @override
  int addToken(String token) {
    if (_tokenToIndex.containsKey(token)) {
      return _tokenToIndex[token]!;
    }
    
    final index = _tokenToIndex.isEmpty ? 0 : _tokenToIndex.length;
    _tokenToIndex[token] = index;
    _indexToToken[index] = token;
    
    return index;
  }
  
  @override
  int getTokenIndex(String token) {
    return _tokenToIndex[token] ?? _tokenToIndex[unkToken]!;
  }
  
  @override
  String getWordFromIndex(int index) {
    return _indexToToken[index] ?? unkToken;
  }
  
  @override
  int getSize() {
    return _tokenToIndex.length;
  }
  
  @override
  bool containsToken(String token) {
    return _tokenToIndex.containsKey(token);
  }
  
  @override
  Map<String, int> getVocabularyMap() {
    return Map.unmodifiable(_tokenToIndex);
  }
  
  @override
  Map<int, String> getReverseVocabularyMap() {
    return Map.unmodifiable(_indexToToken);
  }
  
  /// Get the index of the unknown token
  int get unkTokenIndex => _tokenToIndex[unkToken]!;
  
  /// Get the index of the padding token
  int get padTokenIndex => _tokenToIndex[padToken]!;
  
  /// Get the index of the start token
  int get startTokenIndex => _tokenToIndex[startToken]!;
  
  /// Get the index of the end token
  int get endTokenIndex => _tokenToIndex[endToken]!;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    if (other is! Vocabulary) return false;
    
    // Check if maps have the same keys and values
    if (_tokenToIndex.length != other._tokenToIndex.length) return false;
    if (_indexToToken.length != other._indexToToken.length) return false;
    
    // Check each key-value pair in tokenToIndex
    for (final entry in _tokenToIndex.entries) {
      if (!other._tokenToIndex.containsKey(entry.key) || 
          other._tokenToIndex[entry.key] != entry.value) {
        return false;
      }
    }
    
    // Check each key-value pair in indexToToken
    for (final entry in _indexToToken.entries) {
      if (!other._indexToToken.containsKey(entry.key) || 
          other._indexToToken[entry.key] != entry.value) {
        return false;
      }
    }
    
    return true;
  }
  
  @override
  int get hashCode {
    // Create a consistent hash code based on the map contents
    int hash = 0;
    
    // Add hash for each token-index pair
    for (final entry in _tokenToIndex.entries) {
      hash = hash * 31 + entry.key.hashCode;
      hash = hash * 31 + entry.value.hashCode;
    }
    
    return hash;
  }
}
