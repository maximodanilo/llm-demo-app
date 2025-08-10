import 'dart:math';

/// A simple neuron model for educational purposes.
/// 
/// This class represents a single neuron in a neural network,
/// with weights, bias, and an activation function.
class Neuron {
  /// The weights for each input.
  final List<double> weights;
  
  /// The bias term.
  final double bias;
  
  /// The name of the activation function.
  final String activationFunction;
  
  /// Creates a new neuron with the specified weights, bias, and activation function.
  const Neuron({
    required this.weights,
    required this.bias,
    required this.activationFunction,
  });
  
  /// Creates a neuron with random weights and bias.
  /// 
  /// [inputSize] is the number of inputs this neuron accepts.
  /// [activationFunction] defaults to 'relu'.
  factory Neuron.random(int inputSize, {String activationFunction = 'relu'}) {
    final random = Random();
    
    // Initialize weights with small random values
    final weights = List<double>.generate(
      inputSize,
      (_) => random.nextDouble() * 2 - 1, // Values between -1 and 1
    );
    
    // Initialize bias with a small random value
    final bias = random.nextDouble() * 2 - 1; // Value between -1 and 1
    
    return Neuron(
      weights: weights,
      bias: bias,
      activationFunction: activationFunction,
    );
  }
  
  /// Computes the output of this neuron for the given inputs.
  /// 
  /// [inputs] must have the same length as [weights].
  double compute(List<double> inputs) {
    if (inputs.length != weights.length) {
      throw ArgumentError('Input size (${inputs.length}) must match weight size (${weights.length})');
    }
    
    // Compute weighted sum
    double sum = bias;
    for (int i = 0; i < inputs.length; i++) {
      sum += inputs[i] * weights[i];
    }
    
    // Apply activation function
    return _activate(sum);
  }
  
  /// Applies the activation function to the input.
  double _activate(double x) {
    switch (activationFunction.toLowerCase()) {
      case 'relu':
        return max(0, x);
      case 'sigmoid':
        return 1 / (1 + exp(-x));
      case 'tanh':
        return (exp(x) - exp(-x)) / (exp(x) + exp(-x)); // tanh implementation
      case 'linear':
        return x;
      default:
        return max(0, x); // Default to ReLU
    }
  }
  
  /// Creates a copy of this neuron with updated weights and/or bias.
  Neuron copyWith({
    List<double>? weights,
    double? bias,
    String? activationFunction,
  }) {
    return Neuron(
      weights: weights ?? this.weights,
      bias: bias ?? this.bias,
      activationFunction: activationFunction ?? this.activationFunction,
    );
  }
}
