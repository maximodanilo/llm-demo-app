/// Model class representing tokenized text with metadata
class TokenizedText {
  /// Original raw input text
  final String originalText;
  
  /// Preprocessed text after cleaning
  final String preprocessedText;
  
  /// List of tokens
  final List<String> tokens;
  
  /// List of token IDs
  final List<int> tokenIds;
  
  /// Tokenizer type used
  final String tokenizerType;
  
  /// Timestamp when tokenization occurred
  final DateTime timestamp;
  
  /// Constructor
  TokenizedText({
    required this.originalText,
    required this.preprocessedText,
    required this.tokens,
    required this.tokenIds,
    required this.tokenizerType,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  /// Get the token count
  int get tokenCount => tokens.length;
  
  /// Check if tokenization is empty
  bool get isEmpty => tokens.isEmpty;
  
  /// Check if tokenization is not empty
  bool get isNotEmpty => tokens.isNotEmpty;
  
  /// Get a specific token by index
  String getToken(int index) {
    if (index < 0 || index >= tokens.length) {
      throw RangeError('Index out of range');
    }
    return tokens[index];
  }
  
  /// Get a specific token ID by index
  int getTokenId(int index) {
    if (index < 0 || index >= tokenIds.length) {
      throw RangeError('Index out of range');
    }
    return tokenIds[index];
  }
  
  /// Create a copy with modified properties
  TokenizedText copyWith({
    String? originalText,
    String? preprocessedText,
    List<String>? tokens,
    List<int>? tokenIds,
    String? tokenizerType,
    DateTime? timestamp,
  }) {
    return TokenizedText(
      originalText: originalText ?? this.originalText,
      preprocessedText: preprocessedText ?? this.preprocessedText,
      tokens: tokens ?? this.tokens,
      tokenIds: tokenIds ?? this.tokenIds,
      tokenizerType: tokenizerType ?? this.tokenizerType,
      timestamp: timestamp ?? this.timestamp,
    );
  }
  
  /// Convert to a map representation
  Map<String, dynamic> toMap() {
    return {
      'originalText': originalText,
      'preprocessedText': preprocessedText,
      'tokens': tokens,
      'tokenIds': tokenIds,
      'tokenizerType': tokenizerType,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  /// Create from a map representation
  factory TokenizedText.fromMap(Map<String, dynamic> map) {
    return TokenizedText(
      originalText: map['originalText'] as String,
      preprocessedText: map['preprocessedText'] as String,
      tokens: List<String>.from(map['tokens']),
      tokenIds: List<int>.from(map['tokenIds']),
      tokenizerType: map['tokenizerType'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
  
  /// Create an empty instance
  factory TokenizedText.empty() {
    return TokenizedText(
      originalText: '',
      preprocessedText: '',
      tokens: [],
      tokenIds: [],
      tokenizerType: 'none',
    );
  }
}
