import 'package:flutter_test/flutter_test.dart';
import 'package:llmdemoapp/core/models/tokenizer.dart';

/// Test implementation of ITokenizer for testing interface compliance
class MockTokenizer implements ITokenizer {
  final Map<String, int> _vocabulary = {'[UNK]': 0, 'test': 1, 'token': 2};
  final Map<int, String> _reverseVocabulary = {0: '[UNK]', 1: 'test', 2: 'token'};
  
  @override
  String preprocess(String text) {
    return text.toLowerCase();
  }
  
  @override
  List<String> encode(String text) {
    return text.toLowerCase().split(' ');
  }
  
  @override
  String decode(List<String> tokens) {
    return tokens.join(' ');
  }
  
  @override
  List<int> tokensToIds(List<String> tokens) {
    return tokens.map((token) => _vocabulary[token] ?? _vocabulary['[UNK]']!).toList();
  }
  
  @override
  List<String> idsToTokens(List<int> ids) {
    return ids.map((id) => _reverseVocabulary[id] ?? '[UNK]').toList();
  }
  
  @override
  int getMockTokenId(String token) {
    return token.hashCode % 1000;
  }
}

void main() {
  late ITokenizer tokenizer;

  setUp(() {
    tokenizer = MockTokenizer();
  });

  group('ITokenizer Interface', () {
    test('preprocess should handle text transformation', () {
      const input = 'Test String';
      const expected = 'test string';
      
      final result = tokenizer.preprocess(input);
      
      expect(result, expected);
    });

    test('encode should convert text to tokens', () {
      const input = 'test token';
      final expected = ['test', 'token'];
      
      final result = tokenizer.encode(input);
      
      expect(result, expected);
    });

    test('decode should convert tokens back to text', () {
      final input = ['test', 'token'];
      const expected = 'test token';
      
      final result = tokenizer.decode(input);
      
      expect(result, expected);
    });

    test('tokensToIds should convert tokens to their IDs', () {
      final input = ['test', 'token', 'unknown'];
      final expected = [1, 2, 0]; // Based on the mock implementation
      
      final result = tokenizer.tokensToIds(input);
      
      expect(result, expected);
    });

    test('idsToTokens should convert IDs back to tokens', () {
      final input = [1, 2, 999]; // 999 is an unknown ID
      final expected = ['test', 'token', '[UNK]'];
      
      final result = tokenizer.idsToTokens(input);
      
      expect(result, expected);
    });

    test('getMockTokenId should return consistent IDs for the same token', () {
      const token = 'consistent';
      
      final id1 = tokenizer.getMockTokenId(token);
      final id2 = tokenizer.getMockTokenId(token);
      
      expect(id1, id2);
    });
  });
}
