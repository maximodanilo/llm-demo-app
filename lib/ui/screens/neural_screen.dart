import 'package:flutter/material.dart';
import 'package:llmdemoapp/core/models/neuron.dart';
import 'package:llmdemoapp/core/models/tokenizer.dart';
import 'package:llmdemoapp/ui/widgets/neuron_visualization_widget.dart';
import 'package:llmdemoapp/ui/widgets/activation_function_widget.dart';
import 'package:llmdemoapp/ui/widgets/weight_adjustment_widget.dart';
import 'package:llmdemoapp/ui/widgets/learning_process_widget.dart';

/// Screen to demonstrate how neurons process data in a neural network
class NeuralScreen extends StatefulWidget {
  final ITokenizer tokenizer;
  final List<String> tokens;
  final List<int> tokenIds;
  final Map<int, List<double>> embeddings;

  const NeuralScreen({
    Key? key,
    required this.tokenizer,
    required this.tokens,
    required this.tokenIds,
    required this.embeddings,
  }) : super(key: key);

  @override
  State<NeuralScreen> createState() => _NeuralScreenState();
}

class _NeuralScreenState extends State<NeuralScreen> {
  // Selected activation function
  ActivationFunction _activationType = ActivationFunction.relu;
  
  // Sample neuron for demonstration
  late INeuron _neuron;
  
  // Input values for the neuron
  List<double> _inputValues = [];
  
  // Current output of the neuron
  double _output = 0.0;
  
  // Learning rate for weight updates
  double _learningRate = 0.1;
  
  // Selected tab index
  int _selectedTabIndex = 0;
  
  // Controller for the tab view
  late PageController _pageController;
  
  // Keys for each section to enable scrolling
  final _neuronKey = GlobalKey();
  final _activationKey = GlobalKey();
  final _weightsKey = GlobalKey();
  final _learningKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();
    
    // Initialize page controller
    _pageController = PageController(initialPage: 0);
    
    // Initialize with a simple neuron (3 inputs)
    _neuron = Neuron(
      inputSize: 3,
      initialWeights: [0.5, -0.3, 0.8],
      initialBias: 0.1,
      activationType: _activationType,
    );
    
    // Initialize input values
    _inputValues = [0.5, 0.3, 0.7];
    
    // Calculate initial output
    _calculateOutput();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  // Calculate neuron output based on current inputs
  void _calculateOutput() {
    _output = _neuron.activate(_inputValues);
    setState(() {}); // Update UI
  }
  
  // Handle activation function change
  void _onActivationChanged(ActivationFunction type) {
    setState(() {
      _activationType = type;
      
      // Create a new neuron with the same weights but different activation
      _neuron = Neuron(
        inputSize: _neuron.weights.length,
        initialWeights: _neuron.weights,
        initialBias: _neuron.bias,
        activationType: type,
      );
      
      // Recalculate output
      _calculateOutput();
    });
  }
  
  // Handle input value changes
  void _onInputChanged(List<double> inputs) {
    setState(() {
      _inputValues = inputs;
    });
  }
  
  // Handle neuron activation
  void _onNeuronActivated(double output) {
    setState(() {
      _output = output;
    });
  }
  
  // Handle weight and bias updates
  void _onWeightsUpdated(List<double> weights, double bias) {
    setState(() {
      // Create a new neuron with updated weights
      _neuron = Neuron(
        inputSize: weights.length,
        initialWeights: weights,
        initialBias: bias,
        activationType: _activationType,
      );
      
      // Recalculate output
      _calculateOutput();
    });
  }
  
  // Handle learning rate changes
  void _onLearningRateChanged(double rate) {
    setState(() {
      _learningRate = rate;
    });
  }
  
  // Handle training process
  void _onTrainingPerformed(double targetOutput) {
    // Calculate current output and error
    final output = _neuron.activate(_inputValues);
    final error = targetOutput - output;
    
    // Update weights through backpropagation
    _neuron.updateWeights(_inputValues, error, _learningRate);
    
    // Recalculate output
    _calculateOutput();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neural Network'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
        bottom: TabBar(
          onTap: (index) {
            setState(() {
              _selectedTabIndex = index;
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            });
          },
          tabs: const [
            Tab(text: 'Neuron'),
            Tab(text: 'Activation'),
            Tab(text: 'Weights'),
            Tab(text: 'Learning'),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        children: [
          _buildNeuronTab(),
          _buildActivationTab(),
          _buildWeightsTab(),
          _buildLearningTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
  
  Widget _buildNeuronTab() {
    return SingleChildScrollView(
      key: _neuronKey,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Neuron Visualization',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This visualization shows how a neuron processes inputs through weighted connections '
            'and produces an output using an activation function.',
          ),
          const SizedBox(height: 16),
          _buildEducationalNote(
            title: "How Neurons Work",
            content: [
              "A neuron is the basic computational unit of a neural network.",
              "It performs three key operations:",
              "1. Weighted Sum: Each input is multiplied by a weight, and all are summed together with a bias term.",
              "2. Activation: The sum is passed through a non-linear activation function.",
              "3. Output: The result is passed to the next layer or as the final output.",
              "",
              "In language models, neurons help transform word embeddings into more abstract representations that capture semantic meaning.",
              "",
              "The formula for a neuron's computation is: output = activation(∑(inputs * weights) + bias)",
            ],
          ),
          const SizedBox(height: 24),
          NeuronVisualizationWidget(
            neuron: _neuron,
            inputValues: _inputValues,
            onInputChanged: _onInputChanged,
            onActivated: _onNeuronActivated,
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Neuron State',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Activation Function: ${_activationType.toString().split('.').last}'),
                  Text('Number of Inputs: ${_neuron.weights.length}'),
                  Text('Current Output: ${_output.toStringAsFixed(4)}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildNextStepButton(),
        ],
      ),
    );
  }
  
  Widget _buildActivationTab() {
    return SingleChildScrollView(
      key: _activationKey,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activation Functions',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Activation functions introduce non-linearity into neural networks, '
            'allowing them to learn complex patterns. Explore different functions below.',
          ),
          const SizedBox(height: 16),
          _buildEducationalNote(
            title: "Why Activation Functions Matter",
            content: [
              "Activation functions are crucial for neural networks for several reasons:",
              "1. Non-linearity: They introduce non-linear properties to the network, allowing it to learn complex patterns.",
              "2. Output Bounding: Functions like Sigmoid and Tanh constrain outputs to specific ranges.",
              "3. Gradient Properties: Their derivatives are used in backpropagation for learning.",
              "",
              "Common Activation Functions:",
              "• ReLU (Rectified Linear Unit): f(x) = max(0, x) - Fast to compute, helps with vanishing gradient problem.",
              "• Sigmoid: f(x) = 1/(1+e^(-x)) - Outputs between 0 and 1, useful for probability.",
              "• Tanh: f(x) = (e^x - e^(-x))/(e^x + e^(-x)) - Similar to sigmoid but outputs between -1 and 1.",
              "• Linear: f(x) = x - No transformation, used in regression problems or final layers.",
              "",
              "In language models, ReLU and its variants are commonly used in hidden layers, while Softmax (a type of activation) is used in output layers for word prediction probabilities.",
            ],
          ),
          const SizedBox(height: 24),
          ActivationFunctionWidget(
            activationType: _activationType,
            onActivationChanged: _onActivationChanged,
          ),
          const SizedBox(height: 24),
          _buildNextStepButton(),
        ],
      ),
    );
  }
  
  Widget _buildWeightsTab() {
    return SingleChildScrollView(
      key: _weightsKey,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weight Adjustment',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Weights determine how much influence each input has on the neuron\'s output. '
            'Adjust the weights and bias to see how they affect the output.',
          ),
          const SizedBox(height: 16),
          _buildEducationalNote(
            title: "The Role of Weights and Bias",
            content: [
              "Weights and bias are the learnable parameters of a neural network:",
              "",
              "Weights:",
              "• Determine the strength of connection between inputs and neurons",
              "• Positive weights amplify signals, negative weights inhibit them",
              "• The magnitude indicates how important that input is to the neuron",
              "• In language models, weights help capture relationships between words and concepts",
              "",
              "Bias:",
              "• Acts as a threshold for neuron activation",
              "• Allows the neuron to fire even when all inputs are zero",
              "• Shifts the activation function left or right",
              "",
              "During training, both weights and bias are adjusted to minimize prediction error.",
              "The initial values of weights can significantly impact training speed and effectiveness."
            ],
          ),
          const SizedBox(height: 24),
          WeightAdjustmentWidget(
            neuron: _neuron,
            onWeightsUpdated: _onWeightsUpdated,
          ),
          const SizedBox(height: 24),
          _buildNextStepButton(),
        ],
      ),
    );
  }
  
  Widget _buildLearningTab() {
    return SingleChildScrollView(
      key: _learningKey,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Learning Process',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Neurons learn by adjusting their weights based on the error between '
            'the expected and actual outputs. This process is called backpropagation.',
          ),
          const SizedBox(height: 16),
          _buildEducationalNote(
            title: "How Neural Networks Learn",
            content: [
              "Neural networks learn through a process called backpropagation and gradient descent:",
              "",
              "1. Forward Pass:",
              "   • Inputs are processed through the network to produce an output",
              "   • This is the network's prediction based on current weights",
              "",
              "2. Error Calculation:",
              "   • The difference between predicted and expected output is calculated",
              "   • This error measures how far off the prediction was",
              "",
              "3. Backpropagation:",
              "   • The error is propagated backward through the network",
              "   • Gradients are calculated to determine how each weight contributed to the error",
              "",
              "4. Weight Updates:",
              "   • Weights are adjusted in the direction that reduces error",
              "   • Learning rate controls how big these adjustments are",
              "   • Formula: weight = weight - (learning_rate * gradient)",
              "",
              "5. Iteration:",
              "   • This process repeats with many examples until the network performs well",
              "",
              "In language models, this learning process allows the model to gradually improve its ability to predict words and understand language patterns."
            ],
          ),
          const SizedBox(height: 24),
          LearningProcessWidget(
            neuron: _neuron,
            inputValues: _inputValues,
            learningRate: _learningRate,
            onLearningRateChanged: _onLearningRateChanged,
            onTrainingPerformed: _onTrainingPerformed,
          ),
          const SizedBox(height: 24),
          _buildNextStepButton(),
        ],
      ),
    );
  }
  
  Widget _buildBottomNavigation() {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Embeddings'),
          ),
          Text(
            'Step ${_selectedTabIndex + 1} of 4',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          TextButton.icon(
            onPressed: () {
              if (_selectedTabIndex < 3) {
                setState(() {
                  _selectedTabIndex++;
                  _pageController.animateToPage(
                    _selectedTabIndex,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                });
              }
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNextStepButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Navigate to the next screen in the LLM demo flow
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => NextScreen(
          //       tokenizer: widget.tokenizer,
          //       tokens: widget.tokens,
          //       tokenIds: widget.tokenIds,
          //       embeddings: widget.embeddings,
          //     ),
          //   ),
          // );
          
          // For now, just show a message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Next step will be implemented soon!'),
            ),
          );
        },
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Next Step: Neural Layer'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
  
  // Educational note widget with collapsible content
  Widget _buildEducationalNote({
    required String title,
    required List<String> content,
    bool initiallyExpanded = false,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        title: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.amber),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: content.map((text) {
              if (text.isEmpty) {
                return const SizedBox(height: 8);
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(text),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Neural Networks'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Neural Networks in Language Models',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Neurons process embedding vectors through weighted connections',
              ),
              const Text(
                '• Activation functions introduce non-linearity',
              ),
              const Text(
                '• Learning happens through backpropagation and gradient descent',
              ),
              const SizedBox(height: 12),
              _buildEducationalNote(
                title: "From Neurons to Language Understanding",
                content: [
                  "In language models, neural networks transform word embeddings into meaningful representations:",
                  "",
                  "1. Word Embeddings → Single Neurons:",
                  "   • Each dimension of a word embedding connects to neurons",
                  "   • Neurons extract specific linguistic features from these dimensions",
                  "",
                  "2. Single Neurons → Neural Layers:",
                  "   • Multiple neurons form a layer that recognizes patterns",
                  "   • Each neuron specializes in detecting different language features",
                  "",
                  "3. Neural Layers → Attention Mechanisms:",
                  "   • Layers of neurons feed into attention mechanisms",
                  "   • Attention helps focus on relevant words and context",
                  "",
                  "4. Complete Model → Language Understanding:",
                  "   • The full network learns to predict words based on context",
                  "   • This prediction ability enables tasks like text generation and translation",
                ],
                initiallyExpanded: true,
              ),
              const SizedBox(height: 16),
              const Text(
                'This screen demonstrates how a single neuron processes inputs, '
                'applies activation functions, and learns through weight updates.',
              ),
              const SizedBox(height: 16),
              const Text(
                'Educational Flow:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('1. Neuron Visualization - See how inputs flow through a neuron'),
              const Text('2. Activation Functions - Explore different non-linear transformations'),
              const Text('3. Weight Adjustment - Understand how weights affect the output'),
              const Text('4. Learning Process - Watch how neurons learn through backpropagation'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
