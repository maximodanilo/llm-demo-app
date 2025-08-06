import 'package:flutter_test/flutter_test.dart';
import 'package:llmdemoapp/core/models/tokenizer.dart';

void main() {
  group('TokenizerFactory', () {
    test('should create a WordTokenizer when TokenizerType.word is specified', () {
      final tokenizer = TokenizerFactory.createTokenizer(TokenizerType.word);
      
      expect(tokenizer, isA<WordTokenizer>());
    });

    test('should create a SubwordTokenizer when TokenizerType.subword is specified', () {
      final tokenizer = TokenizerFactory.createTokenizer(TokenizerType.subword);
      
      expect(tokenizer, isA<SubwordTokenizer>());
    });

    test('created tokenizers should implement ITokenizer interface', () {
      final wordTokenizer = TokenizerFactory.createTokenizer(TokenizerType.word);
      final subwordTokenizer = TokenizerFactory.createTokenizer(TokenizerType.subword);
      
      expect(wordTokenizer, isA<ITokenizer>());
      expect(subwordTokenizer, isA<ITokenizer>());
    });
  });
}
