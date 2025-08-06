import 'package:flutter_test/flutter_test.dart';
import 'package:llmdemoapp/core/models/neuron.dart';

void main() {
  group('Neuron', () {
    test('initialization with default parameters', () {
      final neuron = Neuron(inputSize: 3, seed: 42);
      
      expect(neuron.inputSize, equals(3));
      expect(neuron.weights.length, equals(3));
      expect(neuron.bias, equals(0.0));
      expect(neuron.activationType, equals(ActivationFunction.relu));
      expect(neuron.lastOutput, equals(0.0));
      expect(neuron.lastPreActivation, equals(0.0));
    });
    
    test('initialization with custom parameters', () {
      final customWeights = [0.1, 0.2, -0.3];
      final customBias = 0.5;
      
      final neuron = Neuron(
        inputSize: 3,
        initialWeights: customWeights,
        initialBias: customBias,
        activationType: ActivationFunction.sigmoid,
      );
      
      expect(neuron.weights, equals(customWeights));
      expect(neuron.bias, equals(customBias));
      expect(neuron.activationType, equals(ActivationFunction.sigmoid));
    });
    
    test('throws error when initial weights length does not match input size', () {
      expect(
        () => Neuron(
          inputSize: 3,
          initialWeights: [0.1, 0.2],
        ),
        throwsArgumentError,
      );
    });
    
    test('activation with ReLU', () {
      final neuron = Neuron(
        inputSize: 3,
        initialWeights: [0.5, -0.5, 0.2],
        initialBias: -0.1,
        activationType: ActivationFunction.relu,
      );
      
      // Weighted sum: 0.5*0.3 + (-0.5)*0.7 + 0.2*0.1 + (-0.1) = -0.15
      // ReLU(-0.15) = 0
      final output = neuron.activate([0.3, 0.7, 0.1]);
      
      expect(output, equals(0.0));
      expect(neuron.lastPreActivation, closeTo(-0.15, 0.0001));
      expect(neuron.lastOutput, equals(0.0));
      
      // Weighted sum: 0.5*1.0 + (-0.5)*0.0 + 0.2*0.5 + (-0.1) = 0.5
      // ReLU(0.5) = 0.5
      final output2 = neuron.activate([1.0, 0.0, 0.5]);
      
      expect(output2, closeTo(0.5, 0.0001));
      expect(neuron.lastPreActivation, closeTo(0.5, 0.0001));
      expect(neuron.lastOutput, closeTo(0.5, 0.0001));
    });
    
    test('activation with Sigmoid', () {
      final neuron = Neuron(
        inputSize: 2,
        initialWeights: [0.5, -0.5],
        initialBias: 0.0,
        activationType: ActivationFunction.sigmoid,
      );
      
      // Weighted sum: 0.5*1.0 + (-0.5)*1.0 + 0.0 = 0.0
      // Sigmoid(0.0) = 0.5
      final output = neuron.activate([1.0, 1.0]);
      
      expect(output, closeTo(0.5, 0.0001));
      expect(neuron.lastPreActivation, closeTo(0.0, 0.0001));
      expect(neuron.lastOutput, closeTo(0.5, 0.0001));
    });
    
    test('activation with Tanh', () {
      final neuron = Neuron(
        inputSize: 2,
        initialWeights: [1.0, 1.0],
        initialBias: 0.0,
        activationType: ActivationFunction.tanh,
      );
      
      // Weighted sum: 1.0*0.5 + 1.0*0.5 + 0.0 = 1.0
      // tanh(1.0) ≈ 0.7616
      final output = neuron.activate([0.5, 0.5]);
      
      expect(output, closeTo(0.7616, 0.0001));
      expect(neuron.lastPreActivation, closeTo(1.0, 0.0001));
      expect(neuron.lastOutput, closeTo(0.7616, 0.0001));
    });
    
    test('activation with Linear', () {
      final neuron = Neuron(
        inputSize: 2,
        initialWeights: [0.5, 0.5],
        initialBias: 0.1,
        activationType: ActivationFunction.linear,
      );
      
      // Weighted sum: 0.5*1.0 + 0.5*2.0 + 0.1 = 2.1
      // Linear(2.1) = 2.1
      final output = neuron.activate([1.0, 2.0]);
      
      expect(output, closeTo(2.1, 0.0001));
      expect(neuron.lastPreActivation, closeTo(2.1, 0.0001));
      expect(neuron.lastOutput, closeTo(2.1, 0.0001));
    });
    
    test('throws error when input size does not match weight size', () {
      final neuron = Neuron(inputSize: 3);
      
      expect(
        () => neuron.activate([0.1, 0.2]),
        throwsArgumentError,
      );
    });
    
    test('calculate gradient for ReLU', () {
      final neuron = Neuron(
        inputSize: 1,
        initialWeights: [1.0],
        initialBias: 0.0,
        activationType: ActivationFunction.relu,
      );
      
      // Set up lastPreActivation
      neuron.activate([2.0]); // lastPreActivation = 2.0 (positive)
      
      // ReLU derivative for positive input is 1.0
      final gradient = neuron.calculateGradient(1.0);
      expect(gradient, equals(1.0));
      
      // Set up lastPreActivation to be negative
      neuron.activate([-2.0]); // lastPreActivation = -2.0 (negative)
      
      // ReLU derivative for negative input is 0.0
      final gradient2 = neuron.calculateGradient(1.0);
      expect(gradient2, equals(0.0));
    });
    
    test('update weights and bias', () {
      final initialWeights = [0.5, -0.3];
      final initialBias = 0.1;
      final inputs = [1.0, 2.0];
      final learningRate = 0.1;
      final outputGradient = 1.0;
      
      final neuron = Neuron(
        inputSize: 2,
        initialWeights: initialWeights,
        initialBias: initialBias,
        activationType: ActivationFunction.relu,
      );
      
      // Activate to set lastPreActivation
      neuron.activate(inputs); // lastPreActivation = 0.5*1.0 + (-0.3)*2.0 + 0.1 = -0.0
      
      // Update weights
      neuron.updateWeights(inputs, learningRate, outputGradient);
      
      // For ReLU, gradient should be 1.0 since lastPreActivation is positive
      // New weights: [0.5 - 0.1*1.0*1.0, -0.3 - 0.1*1.0*2.0] = [0.4, -0.5]
      // New bias: 0.1 - 0.1*1.0 = 0.0
      
      expect(neuron.weights[0], closeTo(0.4, 0.0001));
      expect(neuron.weights[1], closeTo(-0.5, 0.0001));
      expect(neuron.bias, closeTo(0.0, 0.0001));
    });
  });
  
  group('NeuralLayer', () {
    test('initialization', () {
      final layer = NeuralLayer(
        neuronCount: 3,
        inputsPerNeuron: 2,
        activationType: ActivationFunction.relu,
        seed: 42,
      );
      
      expect(layer.size, equals(3));
      expect(layer.inputSize, equals(2));
      expect(layer.neurons.length, equals(3));
      
      for (final neuron in layer.neurons) {
        expect(neuron.inputSize, equals(2));
        expect(neuron.activationType, equals(ActivationFunction.relu));
      }
    });
    
    test('forward pass', () {
      final layer = NeuralLayer(
        neuronCount: 2,
        inputsPerNeuron: 2,
        seed: 42,
      );
      
      // Set known weights for testing
      for (int i = 0; i < layer.neurons.length; i++) {
        final neuron = layer.neurons[i] as Neuron;
        // Use reflection or create a test-specific constructor to set weights
        // For simplicity, we'll just test with the initialized weights
      }
      
      final outputs = layer.forward([1.0, 1.0]);
      
      expect(outputs.length, equals(2));
      // The exact values depend on the initialized weights
    });
    
    test('update weights', () {
      final layer = NeuralLayer(
        neuronCount: 2,
        inputsPerNeuron: 2,
        seed: 42,
      );
      
      final inputs = [1.0, 1.0];
      final learningRate = 0.1;
      final outputGradients = [1.0, 0.5];
      
      // Get initial weights
      final initialWeights = layer.neurons.map((n) => List<double>.from(n.weights)).toList();
      
      // Forward pass to set lastPreActivation
      layer.forward(inputs);
      
      // Update weights
      layer.updateWeights(inputs, learningRate, outputGradients);
      
      // Check that weights have changed
      for (int i = 0; i < layer.neurons.length; i++) {
        expect(layer.neurons[i].weights, isNot(equals(initialWeights[i])));
      }
    });
    
    test('throws error when output gradients length does not match neuron count', () {
      final layer = NeuralLayer(
        neuronCount: 2,
        inputsPerNeuron: 2,
      );
      
      expect(
        () => layer.updateWeights([1.0, 1.0], 0.1, [1.0]),
        throwsArgumentError,
      );
    });
  });
}
