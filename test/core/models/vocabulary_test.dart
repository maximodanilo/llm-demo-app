import 'package:flutter_test/flutter_test.dart';
import 'package:llmdemoapp/core/models/vocabulary.dart';

void main() {
  late IVocabulary vocabulary;

  setUp(() {
    vocabulary = Vocabulary();
  });

  group('Vocabulary Initialization', () {
    test('should initialize with special tokens', () {
      // Special tokens should be added during initialization
      expect(vocabulary.getSize(), 4);
      expect(vocabulary.containsToken('[UNK]'), isTrue);
      expect(vocabulary.containsToken('[PAD]'), isTrue);
      expect(vocabulary.containsToken('[CLS]'), isTrue);
      expect(vocabulary.containsToken('[SEP]'), isTrue);
    });

    test('should assign sequential indices to tokens', () {
      // Check that special tokens have sequential indices
      final vocabMap = vocabulary.getVocabularyMap();
      expect(vocabMap['[UNK]'], 0);
      expect(vocabMap['[PAD]'], 1);
      expect(vocabMap['[CLS]'], 2);
      expect(vocabMap['[SEP]'], 3);
    });
  });

  group('Token Management', () {
    test('should add new tokens with unique indices', () {
      final index1 = vocabulary.addToken('hello');
      final index2 = vocabulary.addToken('world');
      
      expect(index1, 4); // After the 4 special tokens
      expect(index2, 5);
      expect(vocabulary.getSize(), 6);
    });

    test('should return existing index when adding duplicate token', () {
      final index1 = vocabulary.addToken('duplicate');
      final index2 = vocabulary.addToken('duplicate');
      
      expect(index1, index2);
      expect(vocabulary.getSize(), 5); // 4 special tokens + 1 new token
    });

    test('should retrieve correct token index', () {
      vocabulary.addToken('test');
      
      expect(vocabulary.getTokenIndex('test'), 4);
      expect(vocabulary.getTokenIndex('[UNK]'), 0);
    });

    test('should return UNK token index for unknown tokens', () {
      expect(vocabulary.getTokenIndex('unknown'), 0); // UNK token index
    });

    test('should retrieve correct word from index', () {
      vocabulary.addToken('example');
      
      expect(vocabulary.getWordFromIndex(4), 'example');
      expect(vocabulary.getWordFromIndex(0), '[UNK]');
    });

    test('should return UNK token for unknown indices', () {
      expect(vocabulary.getWordFromIndex(999), '[UNK]');
    });
  });

  group('Vocabulary Maps', () {
    test('should provide immutable vocabulary map', () {
      final vocabMap = vocabulary.getVocabularyMap();
      
      expect(vocabMap.length, 4); // Special tokens
      
      // Verify that the returned map is immutable
      expect(() => vocabMap['test'] = 10, throwsUnsupportedError);
    });

    test('should provide immutable reverse vocabulary map', () {
      final reverseMap = vocabulary.getReverseVocabularyMap();
      
      expect(reverseMap.length, 4); // Special tokens
      
      // Verify that the returned map is immutable
      expect(() => reverseMap[10] = 'test', throwsUnsupportedError);
    });
  });

  group('Vocabulary Size', () {
    test('should report correct size after adding tokens', () {
      expect(vocabulary.getSize(), 4); // Initial special tokens
      
      vocabulary.addToken('one');
      expect(vocabulary.getSize(), 5);
      
      vocabulary.addToken('two');
      expect(vocabulary.getSize(), 6);
      
      // Adding a duplicate shouldn't increase size
      vocabulary.addToken('one');
      expect(vocabulary.getSize(), 6);
    });
  });

  group('Token Existence Check', () {
    test('should correctly report if token exists', () {
      expect(vocabulary.containsToken('[UNK]'), isTrue);
      expect(vocabulary.containsToken('nonexistent'), isFalse);
      
      vocabulary.addToken('exists');
      expect(vocabulary.containsToken('exists'), isTrue);
    });
  });

  group('Equality and Hash Code', () {
    test('identical vocabularies should be equal', () {
      final vocab1 = Vocabulary();
      final vocab2 = Vocabulary();
      
      // Add the same tokens to both
      vocab1.addToken('same');
      vocab2.addToken('same');
      
      expect(vocab1, equals(vocab2));
      expect(vocab1.hashCode, equals(vocab2.hashCode));
    });
    
    test('different vocabularies should not be equal', () {
      final vocab1 = Vocabulary();
      final vocab2 = Vocabulary();
      
      // Add different tokens
      vocab1.addToken('different1');
      vocab2.addToken('different2');
      
      expect(vocab1, isNot(equals(vocab2)));
    });
  });
  
  group('Special Token Getters', () {
    test('should provide correct special token indices', () {
      final vocabulary = Vocabulary();
      
      expect(vocabulary.unkTokenIndex, 0);
      expect(vocabulary.padTokenIndex, 1);
      expect(vocabulary.startTokenIndex, 2);
      expect(vocabulary.endTokenIndex, 3);
    });
  });
  
  group('Mock Implementation', () {
    test('should be able to create a mock vocabulary for testing', () {
      // Create a mock implementation for testing
      final mockVocab = _MockVocabulary();
      
      expect(mockVocab.getSize(), 1); // Only has UNK token
      expect(mockVocab.getTokenIndex('anything'), 0); // Always returns UNK index
      expect(mockVocab.getWordFromIndex(999), '[UNK]'); // Always returns UNK token
    });
  });
}

/// A simple mock implementation of IVocabulary for testing
class _MockVocabulary implements IVocabulary {
  final Map<String, int> _tokenMap = {'[UNK]': 0};
  final Map<int, String> _indexMap = {0: '[UNK]'};
  
  @override
  int addToken(String token) {
    if (_tokenMap.containsKey(token)) {
      return _tokenMap[token]!;
    }
    final index = _tokenMap.length;
    _tokenMap[token] = index;
    _indexMap[index] = token;
    return index;
  }
  
  @override
  bool containsToken(String token) => _tokenMap.containsKey(token);
  
  @override
  int getSize() => _tokenMap.length;
  
  @override
  int getTokenIndex(String token) => 0; // Always return UNK index for testing
  
  @override
  Map<String, int> getVocabularyMap() => Map.unmodifiable(_tokenMap);
  
  @override
  String getWordFromIndex(int index) => '[UNK]'; // Always return UNK token for testing
  
  @override
  Map<int, String> getReverseVocabularyMap() => Map.unmodifiable(_indexMap);
}
