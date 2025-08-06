import 'package:llmdemoapp/core/models/tokenizer.dart';
import 'package:llmdemoapp/core/models/vocabulary.dart';

/// Wrapper class that adds proper vocabulary support to any tokenizer
class TokenizerWithVocabulary implements ITokenizer {
  final ITokenizer _baseTokenizer;
  final IVocabulary _vocabulary;
  
  /// Create a new tokenizer wrapper with vocabulary support
  TokenizerWithVocabulary(this._baseTokenizer, this._vocabulary);
  
  /// Create a new tokenizer wrapper with a new vocabulary instance
  /// and populate it with tokens from the base tokenizer
  factory TokenizerWithVocabulary.fromTokenizer(ITokenizer tokenizer) {
    // Create a new vocabulary instance
    final vocabulary = Vocabulary();
    
    // Use the existing vocabulary getter to populate our new vocabulary
    if (tokenizer is WordTokenizer) {
      // Get the vocabulary map from the tokenizer
      final vocabMap = tokenizer.vocabularyMap;
      vocabMap.forEach((token, _) {
        vocabulary.addToken(token);
      });
    } else if (tokenizer is SubwordTokenizer) {
      // Get the vocabulary map from the tokenizer
      final vocabMap = tokenizer.vocabularyMap;
      vocabMap.forEach((token, _) {
        vocabulary.addToken(token);
      });
    }
    
    return TokenizerWithVocabulary(tokenizer, vocabulary);
  }
  
  @override
  String preprocess(String text) => _baseTokenizer.preprocess(text);
  
  @override
  List<String> encode(String text) => _baseTokenizer.encode(text);
  
  @override
  String decode(List<String> tokens) => _baseTokenizer.decode(tokens);
  
  @override
  List<int> tokensToIds(List<String> tokens) => _baseTokenizer.tokensToIds(tokens);
  
  @override
  List<String> idsToTokens(List<int> ids) => _baseTokenizer.idsToTokens(ids);
  
  @override
  int getMockTokenId(String token) => _baseTokenizer.getMockTokenId(token);
  
  @override
  IVocabulary get vocabulary => _vocabulary;
  
  @override
  Map<String, int> get vocabularyMap => _vocabulary.getVocabularyMap();
}

/// Enhanced factory for creating tokenizers with proper vocabulary support
class EnhancedTokenizerFactory {
  /// Create a tokenizer based on the specified type with vocabulary support
  static ITokenizer createTokenizer(TokenizerType type) {
    ITokenizer baseTokenizer;
    
    switch (type) {
      case TokenizerType.word:
        baseTokenizer = WordTokenizer();
        break;
      case TokenizerType.subword:
        baseTokenizer = SubwordTokenizer();
        break;
    }
    
    // Wrap the base tokenizer with vocabulary support
    return TokenizerWithVocabulary.fromTokenizer(baseTokenizer);
  }
}
