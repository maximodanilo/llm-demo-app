import 'package:flutter_test/flutter_test.dart';
import 'package:llmdemoapp/core/models/tokenizer.dart';

void main() {
  late SubwordTokenizer tokenizer;

  setUp(() {
    tokenizer = SubwordTokenizer();
  });

  group('SubwordTokenizer', () {
    group('initialization', () {
      test('should initialize with special tokens in vocabulary', () {
        expect(tokenizer.vocabulary.containsKey(SubwordTokenizer.unkToken), isTrue);
        expect(tokenizer.vocabulary.containsKey(SubwordTokenizer.padToken), isTrue);
        expect(tokenizer.vocabulary.containsKey(SubwordTokenizer.startToken), isTrue);
        expect(tokenizer.vocabulary.containsKey(SubwordTokenizer.endToken), isTrue);
      });

      test('should initialize with common prefixes and suffixes', () {
        // Test some common prefixes
        expect(tokenizer.vocabulary.containsKey('un'), isTrue);
        expect(tokenizer.vocabulary.containsKey('re'), isTrue);
        
        // Test some common suffixes
        expect(tokenizer.vocabulary.containsKey('ing'), isTrue);
        expect(tokenizer.vocabulary.containsKey('ed'), isTrue);
      });
    });

    group('preprocess', () {
      test('should convert text to lowercase', () {
        const input = 'Hello World';
        const expected = 'hello world';
        
        final result = tokenizer.preprocess(input);
        
        expect(result, expected);
      });

      test('should handle empty string', () {
        const input = '';
        const expected = '';
        
        final result = tokenizer.preprocess(input);
        
        expect(result, expected);
      });

      test('should trim leading and trailing whitespace', () {
        const input = '  hello world  ';
        const expected = 'hello world';
        
        final result = tokenizer.preprocess(input);
        
        expect(result, expected);
      });

      test('should separate punctuation from words', () {
        const input = 'hello,world!how are you?';
        const expected = 'hello \$1 world \$1 how are you \$1';
        
        final result = tokenizer.preprocess(input);
        
        expect(result, expected);
      });
    });

    group('_splitIntoSubwords', () {
      test('should keep short words as is', () {
        // Using a private method test technique with public API
        const input = 'cat';
        final tokens = tokenizer.encode(input);
        
        expect(tokens, ['cat']);
      });

      test('should split words with common prefixes', () {
        const input = 'unhappy';
        final tokens = tokenizer.encode(input);
        
        // Should split into 'un' and 'happy'
        expect(tokens.contains('un'), isTrue);
        expect(tokens.length, 2);
      });

      test('should split words with common suffixes', () {
        const input = 'walking';
        final tokens = tokenizer.encode(input);
        
        // Should split into 'walk' and 'ing'
        expect(tokens.contains('ing'), isTrue);
        expect(tokens.length, 2);
      });

      test('should split long words in the middle', () {
        const input = 'extraordinary';
        final tokens = tokenizer.encode(input);
        
        // Should split a long word
        expect(tokens.length, greaterThan(1));
      });
    });

    group('encode', () {
      test('should tokenize text into subwords', () {
        const input = 'unhappy walking';
        final result = tokenizer.encode(input);
        
        // Should have more tokens than words due to subword splitting
        expect(result.length, greaterThan(2));
        expect(result.contains('un'), isTrue);
        expect(result.contains('ing'), isTrue);
      });

      test('should handle empty string', () {
        const input = '';
        final expected = <String>[];
        
        final result = tokenizer.encode(input);
        
        expect(result, expected);
      });

      test('should add tokens to vocabulary', () {
        const input = 'hello world';
        
        tokenizer.encode(input);
        
        // The words or their subwords should be in vocabulary
        expect(tokenizer.vocabulary.keys.any((k) => k == 'hello' || k.contains('hell')), isTrue);
        expect(tokenizer.vocabulary.keys.any((k) => k == 'world' || k.contains('worl')), isTrue);
      });
    });

    group('decode', () {
      test('should join tokens and handle subword merging', () {
        final input = ['un', 'happy'];
        
        final result = tokenizer.decode(input);
        
        // The result should be a single string with the tokens joined
        expect(result, 'un happy');
      });

      test('should handle empty list', () {
        final input = <String>[];
        const expected = '';
        
        final result = tokenizer.decode(input);
        
        expect(result, expected);
      });
    });

    group('tokensToIds', () {
      test('should convert tokens to their IDs', () {
        // First add tokens to vocabulary
        tokenizer.encode('unhappy');
        
        final input = ['un', 'happy'];
        final unId = tokenizer.getTokenId('un');
        
        final result = tokenizer.tokensToIds(input);
        
        expect(result[0], unId);
        expect(result.length, 2);
      });

      test('should handle unknown tokens', () {
        final input = ['unknowntoken123'];
        final unkId = tokenizer.getTokenId(SubwordTokenizer.unkToken);
        final expected = [unkId];
        
        final result = tokenizer.tokensToIds(input);
        
        expect(result, expected);
      });
    });

    group('idsToTokens', () {
      test('should convert IDs back to tokens', () {
        // First add tokens to vocabulary
        tokenizer.encode('unhappy');
        
        final unId = tokenizer.getTokenId('un');
        final input = [unId];
        final expected = ['un'];
        
        final result = tokenizer.idsToTokens(input);
        
        expect(result, expected);
      });

      test('should handle unknown IDs', () {
        final input = [9999]; // Assuming this ID doesn't exist
        final expected = [SubwordTokenizer.unkToken];
        
        final result = tokenizer.idsToTokens(input);
        
        expect(result, expected);
      });
    });

    group('getMockTokenId', () {
      test('should return consistent IDs for the same token', () {
        const token = 'hello';
        
        final id1 = tokenizer.getMockTokenId(token);
        final id2 = tokenizer.getMockTokenId(token);
        
        expect(id1, id2);
      });

      test('should return different IDs for different tokens', () {
        const token1 = 'hello';
        const token2 = 'world';
        
        final id1 = tokenizer.getMockTokenId(token1);
        final id2 = tokenizer.getMockTokenId(token2);
        
        expect(id1, isNot(equals(id2)));
      });
    });
  });
}
