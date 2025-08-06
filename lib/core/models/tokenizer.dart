import 'dart:math';
import 'package:llmdemoapp/core/models/vocabulary.dart';

/// Interface defining the contract for tokenizers
abstract class ITokenizer {
  /// Preprocess the input text (cleaning, normalization)
  String preprocess(String text);
  
  /// Encode text into tokens
  List<String> encode(String text);
  
  /// Decode tokens back to text
  String decode(List<String> tokens);
  
  /// Convert tokens to token IDs
  List<int> tokensToIds(List<String> tokens);
  
  /// Convert token IDs back to tokens
  List<String> idsToTokens(List<int> ids);
  
  /// Get a consistent mock ID for a token (for demo purposes)
  int getMockTokenId(String token);
  
  /// Get the vocabulary associated with this tokenizer
  IVocabulary get vocabulary;
  
  /// Get a copy of the current vocabulary as a map
  Map<String, int> get vocabularyMap;
}

/// A simple word-level tokenizer implementation
class WordTokenizer implements ITokenizer {
  /// Vocabulary mapping tokens to IDs
  final Map<String, int> _vocabulary = {};
  
  /// Reverse mapping from IDs to tokens
  final Map<int, String> _reverseVocabulary = {};
  
  /// Special tokens
  static const String unkToken = '[UNK]';
  static const String padToken = '[PAD]';
  static const String startToken = '[CLS]';
  static const String endToken = '[SEP]';
  
  /// Random generator for consistent token IDs - used in advanced implementations
  static final Random random = Random(42);
  
  WordTokenizer() {
    // Initialize special tokens
    _addSpecialTokens();
  }
  
  /// Add special tokens to the vocabulary
  void _addSpecialTokens() {
    _addToVocabulary(unkToken);
    _addToVocabulary(padToken);
    _addToVocabulary(startToken);
    _addToVocabulary(endToken);
  }
  
  /// Add a token to the vocabulary with a unique ID
  void _addToVocabulary(String token) {
    if (!_vocabulary.containsKey(token)) {
      final id = _vocabulary.isEmpty ? 0 : _vocabulary.length;
      _vocabulary[token] = id;
      _reverseVocabulary[id] = token;
    }
  }
  
  @override
  String preprocess(String text) {
    if (text.isEmpty) return '';
    
    // Convert to lowercase
    String processed = text.toLowerCase();
    
    // Replace multiple spaces with a single space
    processed = processed.replaceAll(RegExp(r'\s+'), ' ');
    
    // Remove leading and trailing whitespace
    processed = processed.trim();
    
    // Handle basic punctuation (keep it but ensure it's separated from words)
    processed = processed.replaceAll(RegExp(r'([.,!?;:])'), ' \$1 ');
    
    // Remove any double spaces that may have been created
    processed = processed.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return processed;
  }
  
  @override
  List<String> encode(String text) {
    if (text.isEmpty) return [];
    
    // Preprocess the text first
    final processed = preprocess(text);
    
    // Split by spaces to get word tokens
    final tokens = processed.split(' ').where((token) => token.isNotEmpty).toList();
    
    // Add all tokens to vocabulary
    for (final token in tokens) {
      _addToVocabulary(token);
    }
    
    return tokens;
  }
  
  @override
  String decode(List<String> tokens) {
    if (tokens.isEmpty) return '';
    
    // Join tokens with spaces
    return tokens.join(' ');
  }
  
  @override
  List<int> tokensToIds(List<String> tokens) {
    return tokens.map((token) {
      // Return the ID if token exists in vocabulary, otherwise return UNK token ID
      return _vocabulary.containsKey(token) 
          ? _vocabulary[token]! 
          : _vocabulary[unkToken]!;
    }).toList();
  }
  
  @override
  List<String> idsToTokens(List<int> ids) {
    return ids.map((id) {
      // Return the token if ID exists in reverse vocabulary, otherwise return UNK token
      return _reverseVocabulary.containsKey(id) 
          ? _reverseVocabulary[id]! 
          : unkToken;
    }).toList();
  }
  
  /// Get the vocabulary size
  int get vocabularySize => _vocabulary.length;
  
  /// Get a copy of the current vocabulary as a map
  @override
  Map<String, int> get vocabularyMap => Map.from(_vocabulary);
  
  @override
  /// Get the vocabulary associated with this tokenizer
  IVocabulary get vocabulary {
    final vocab = Vocabulary();
    _vocabulary.forEach((token, _) {
      vocab.addToken(token);
    });
    return vocab;
  }
  
  /// Get token ID for a specific token
  int getTokenId(String token) {
    return _vocabulary.containsKey(token) 
        ? _vocabulary[token]! 
        : _vocabulary[unkToken]!;
  }
  
  @override
  /// Get a consistent mock ID for a token (for demo purposes)
  int getMockTokenId(String token) {
    // Use the hash code to generate a consistent ID for demo purposes
    return token.hashCode.abs() % 10000;
  }
}

/// A more advanced subword tokenizer (simplified BPE implementation for demo)
class SubwordTokenizer implements ITokenizer {
  /// Vocabulary mapping tokens to IDs
  final Map<String, int> _vocabulary = {};
  
  /// Reverse mapping from IDs to tokens
  final Map<int, String> _reverseVocabulary = {};
  
  /// Special tokens
  static const String unkToken = '[UNK]';
  static const String padToken = '[PAD]';
  static const String startToken = '[CLS]';
  static const String endToken = '[SEP]';
  
  /// Common prefixes for subword tokenization (simplified for demo)
  final List<String> _commonPrefixes = [
    'un', 're', 'in', 'im', 'dis', 'pre', 'post', 'non', 'anti', 'auto', 'bi', 'co', 'de', 'en', 'ex', 'inter', 'intra', 'micro', 'mid', 'mis', 'over', 'pro', 'semi', 'sub', 'super', 'trans', 'under'
  ];
  
  /// Common suffixes for subword tokenization (simplified for demo)
  final List<String> _commonSuffixes = [
    'ing', 'ed', 'er', 'est', 'ly', 'ity', 'ment', 'ness', 'tion', 'sion', 'ism', 'ist', 'ful', 'able', 'ible', 'al', 'ial', 'ical', 'ious', 'ous', 'ive', 'less', 'y'
  ];
  
  SubwordTokenizer() {
    _initializeVocabulary();
  }
  
  void _initializeVocabulary() {
    // Add special tokens
    _addToVocabulary(unkToken);
    _addToVocabulary(padToken);
    _addToVocabulary(startToken);
    _addToVocabulary(endToken);
    
    // Add common prefixes and suffixes to vocabulary
    for (final prefix in _commonPrefixes) {
      _addToVocabulary(prefix);
    }
    
    for (final suffix in _commonSuffixes) {
      _addToVocabulary(suffix);
    }
  }
  
  void _addToVocabulary(String token) {
    if (!_vocabulary.containsKey(token)) {
      final id = _vocabulary.isEmpty ? 0 : _vocabulary.length;
      _vocabulary[token] = id;
      _reverseVocabulary[id] = token;
    }
  }
  
  @override
  String preprocess(String text) {
    if (text.isEmpty) return '';
    
    // Convert to lowercase
    String processed = text.toLowerCase();
    
    // Replace multiple spaces with a single space
    processed = processed.replaceAll(RegExp(r'\s+'), ' ');
    
    // Remove leading and trailing whitespace
    processed = processed.trim();
    
    // Handle basic punctuation (keep it but ensure it's separated from words)
    processed = processed.replaceAll(RegExp(r'([.,!?;:])'), ' \$1 ');
    
    // Remove any double spaces that may have been created
    processed = processed.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return processed;
  }
  
  @override
  List<String> encode(String text) {
    if (text.isEmpty) return [];
    
    // Preprocess the text first
    final processed = preprocess(text);
    
    // First split by spaces to get words
    final words = processed.split(' ').where((word) => word.isNotEmpty).toList();
    
    // For each word, try to split into subwords (simplified for demo)
    final List<String> tokens = [];
    
    for (final word in words) {
      final subwords = _splitIntoSubwords(word);
      print('DEBUG: Word "$word" split into subwords: $subwords');
      tokens.addAll(subwords);
      
      // Add all subwords to vocabulary
      for (final subword in subwords) {
        _addToVocabulary(subword);
      }
    }
    
    return tokens;
  }
  
  List<String> _splitIntoSubwords(String word) {
    // This is a simplified implementation for demo purposes
    // A real BPE implementation would use merge operations based on frequency
    print('DEBUG: Splitting word: "$word"');
    
    // If word is short, keep it as is
    if (word.length <= 4) {
      print('DEBUG: Word "$word" is too short, keeping as is');
      return [word];
    }
    
    // Check if the word starts with a common prefix
    for (final prefix in _commonPrefixes) {
      if (word.startsWith(prefix) && word.length > prefix.length) {
        final remainder = word.substring(prefix.length);
        print('DEBUG: Found prefix "$prefix" in "$word", remainder: "$remainder"');
        final result = [prefix, ...remainder.length > 4 ? _splitIntoSubwords(remainder) : [remainder]];
        print('DEBUG: After prefix processing, result for "$word": $result');
        return result;
      }
    }
    
    // Check if the word ends with a common suffix
    for (final suffix in _commonSuffixes) {
      if (word.endsWith(suffix) && word.length > suffix.length) {
        final remainder = word.substring(0, word.length - suffix.length);
        print('DEBUG: Found suffix "$suffix" in "$word", remainder: "$remainder"');
        final result = [...remainder.length > 4 ? _splitIntoSubwords(remainder) : [remainder], suffix];
        print('DEBUG: After suffix processing, result for "$word": $result');
        return result;
      }
    }
    
    // If no common prefix or suffix, split in the middle for words longer than 6 chars
    if (word.length > 6) {
      final midPoint = word.length ~/ 2;
      final firstPart = word.substring(0, midPoint);
      final secondPart = word.substring(midPoint);
      print('DEBUG: Splitting "$word" in the middle: "$firstPart" + "$secondPart"');
      return [firstPart, secondPart];
    }
    
    // Default case: return the word as is
    return [word];
  }
  
  @override
  String decode(List<String> tokens) {
    if (tokens.isEmpty) return '';
    
    // Simple implementation: join all tokens and replace spaces between subwords
    // A more sophisticated implementation would handle merging subwords properly
    return tokens.join(' ').replaceAll(' ##', '');
  }
  
  @override
  List<int> tokensToIds(List<String> tokens) {
    return tokens.map((token) {
      return _vocabulary.containsKey(token) 
          ? _vocabulary[token]! 
          : _vocabulary[unkToken]!;
    }).toList();
  }
  
  @override
  List<String> idsToTokens(List<int> ids) {
    return ids.map((id) {
      return _reverseVocabulary.containsKey(id) 
          ? _reverseVocabulary[id]! 
          : unkToken;
    }).toList();
  }
  
  /// Get the vocabulary size
  int get vocabularySize => _vocabulary.length;
  
  /// Get a copy of the current vocabulary as a map
  @override
  Map<String, int> get vocabularyMap => Map.from(_vocabulary);
  
  @override
  /// Get the vocabulary associated with this tokenizer
  IVocabulary get vocabulary {
    final vocab = Vocabulary();
    _vocabulary.forEach((token, _) {
      vocab.addToken(token);
    });
    return vocab;
  }
  
  /// Get token ID for a specific token
  int getTokenId(String token) {
    return _vocabulary.containsKey(token) 
        ? _vocabulary[token]! 
        : _vocabulary[unkToken]!;
  }
  
  @override
  /// Get a consistent mock ID for a token (for demo purposes)
  int getMockTokenId(String token) {
    // Use the hash code to generate a consistent ID for demo purposes
    return token.hashCode.abs() % 10000;
  }
}

/// Factory for creating different types of tokenizers
class TokenizerFactory {
  /// Create a tokenizer based on the specified type
  static ITokenizer createTokenizer(TokenizerType type) {
    // Import the wrapper class to provide proper vocabulary implementation
    ITokenizer baseTokenizer;
    
    switch (type) {
      case TokenizerType.word:
        baseTokenizer = WordTokenizer();
        break;
      case TokenizerType.subword:
        baseTokenizer = SubwordTokenizer();
        break;
    }
    
    // Wrap the base tokenizer with TokenizerWithVocabulary to provide proper vocabulary support
    return baseTokenizer;
  }
}

/// Enum for tokenizer types
enum TokenizerType {
  word,
  subword,
}
