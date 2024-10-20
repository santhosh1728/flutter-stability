import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stability_image_generation/stability_image_generation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.deepPurple, // Custom color for a vibrant look
      ),
      home: const Test(title: 'AI Image Generator'),
    );
  }
}

class Test extends StatefulWidget {
  final String title;

  const Test({super.key, required this.title});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> with SingleTickerProviderStateMixin {
  final TextEditingController _queryController = TextEditingController();
  final StabilityAI _ai = StabilityAI();

  // Your StabilityAI API key
  final String apiKey = 'sk-UV4sHTpJxJa8yqiNwiiG3zI8aKA93k8UtqwE6s3VZL8pCPEE';
  final ImageAIStyle imageAIStyle = ImageAIStyle.christmas;

  bool isLoading = false;
  Uint8List? generatedImage;

  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _buttonAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  Future<void> _generateImage(String query) async {
    if (query.isEmpty) {
      _showSnackbar('Please enter a prompt to generate an image!');
      return;
    }
    setState(() {
      isLoading = true;
      generatedImage = null;
    });

    try {
      Uint8List image = await _ai.generateImage(
        apiKey: apiKey,
        imageAIStyle: imageAIStyle,
        prompt: query,
      );
      setState(() {
        generatedImage = image;
      });
    } catch (error) {
      _showSnackbar('Error generating image: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _queryController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = kIsWeb
        ? MediaQuery.of(context).size.height / 2
        : MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 24)),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "AI Text to Image Generator",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextInput(),
              const SizedBox(height: 20),
              _buildGenerateButton(),
              const SizedBox(height: 20),
              _buildImageDisplay(size),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _queryController,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _generateImage(_queryController.text),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Enter image description...',
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return GestureDetector(
      onTapDown: (_) => _buttonController.forward(),
      onTapUp: (_) => _buttonController.reverse(),
      onTapCancel: () => _buttonController.reverse(),
      child: ScaleTransition(
        scale: _buttonAnimation,
        child: ElevatedButton.icon(
          onPressed:
              isLoading ? null : () => _generateImage(_queryController.text),
          icon: isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                )
              : const Icon(Icons.image, size: 24),
          label: const Text(
            'Generate Image',
            style: TextStyle(fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.deepPurple,
          ),
        ),
      ),
    );
  }

  Widget _buildImageDisplay(double size) {
    return generatedImage != null
        ? Column(
            children: [
              const Text(
                "Generated Image:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.memory(
                  generatedImage!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          )
        : Container(
            padding: const EdgeInsets.all(20),
            child: const Text(
              'Enter a description to generate an image.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
  }
}
