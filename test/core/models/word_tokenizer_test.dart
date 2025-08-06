import 'package:flutter_test/flutter_test.dart';
import 'package:llmdemoapp/core/models/tokenizer.dart';

void main() {
  late WordTokenizer tokenizer;

  setUp(() {
    tokenizer = WordTokenizer();
  });

  group('WordTokenizer', () {
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

      test('should replace multiple spaces with a single space', () {
        const input = 'hello    world';
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

      test('should handle complex text with multiple preprocessing needs', () {
        const input = '  Hello,World!   How are   you?  ';
        const expected = 'hello \$1 world \$1 how are you \$1';

        final result = tokenizer.preprocess(input);

        expect(result, expected);
      });
    });

    group('encode', () {
      test('should tokenize text into words', () {
        const input = 'hello world';
        final expected = ['hello', 'world'];

        final result = tokenizer.encode(input);

        expect(result, expected);
      });

      test('should handle empty string', () {
        const input = '';
        final expected = <String>[];

        final result = tokenizer.encode(input);

        expect(result, expected);
      });

      test('should handle text with punctuation', () {
        const input = 'hello, world!';
        final expected = ['hello', '\$1', 'world', '\$1'];

        final result = tokenizer.encode(input);

        expect(result, expected);
      });

      test('should add tokens to vocabulary', () {
        const input = 'hello world';

        tokenizer.encode(input);

        expect(tokenizer.vocabularyMap.containsKey('hello'), isTrue);
        expect(tokenizer.vocabularyMap.containsKey('world'), isTrue);
      });
    });

    group('decode', () {
      test('should join tokens with spaces', () {
        final input = ['hello', 'world'];
        const expected = 'hello world';

        final result = tokenizer.decode(input);

        expect(result, expected);
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
        tokenizer.encode('hello world');

        final input = ['hello', 'world'];
        final helloId = tokenizer.getTokenId('hello');
        final worldId = tokenizer.getTokenId('world');
        final expected = [helloId, worldId];

        final result = tokenizer.tokensToIds(input);

        expect(result, expected);
      });

      test('should handle unknown tokens', () {
        final input = ['unknown'];
        final unkId = tokenizer.getTokenId(WordTokenizer.unkToken);
        final expected = [unkId];

        final result = tokenizer.tokensToIds(input);

        expect(result, expected);
      });
    });

    group('idsToTokens', () {
      test('should convert IDs back to tokens', () {
        // First add tokens to vocabulary
        tokenizer.encode('hello world');

        final helloId = tokenizer.getTokenId('hello');
        final worldId = tokenizer.getTokenId('world');
        final input = [helloId, worldId];
        final expected = ['hello', 'world'];

        final result = tokenizer.idsToTokens(input);

        expect(result, expected);
      });

      test('should handle unknown IDs', () {
        final input = [9999]; // Assuming this ID doesn't exist
        final expected = [WordTokenizer.unkToken];

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

    group('special tokens', () {
      test('should initialize with special tokens in vocabulary', () {
        expect(
          tokenizer.vocabularyMap.containsKey(WordTokenizer.unkToken),
          isTrue,
        );
        expect(
          tokenizer.vocabularyMap.containsKey(WordTokenizer.padToken),
          isTrue,
        );
        expect(
          tokenizer.vocabularyMap.containsKey(WordTokenizer.startToken),
          isTrue,
        );
        expect(
          tokenizer.vocabularyMap.containsKey(WordTokenizer.endToken),
          isTrue,
        );
      });
    });
  });
}
