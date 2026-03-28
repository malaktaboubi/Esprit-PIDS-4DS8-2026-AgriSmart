import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/classifier.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Classifier _classifier;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _classifier = Classifier();
  }

  File? _image;
  DiagnosisResult? _prediction;
  bool _isAnalyzing = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (file == null) return;

      setState(() {
        _image = File(file.path);
        _prediction = null;
        _isAnalyzing = true;
      });

      await _analyzeImage();
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;

    try {
      final result = await _classifier.predict(_image!.path);

      setState(() {
        _prediction = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() => _isAnalyzing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to analyze image. Check logs for details.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriSmart Disease Detection'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Display Area
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      )
                    : const Center(
                        child: Icon(
                          Icons.add_a_photo,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              // Prediction Result
              if (_isAnalyzing)
                const Center(child: CircularProgressIndicator())
              else if (_prediction != null)
                _buildResultCard(_prediction!)
              else
                const Center(
                  child: Text(
                    'Select an image to analyze',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(DiagnosisResult prediction) {
    final bool isUnrecognised = prediction.isUnknown;

    final String label = isUnrecognised
        ? 'Not a recognisable plant disease'
        : '${prediction.plantName} - ${prediction.diseaseName}';

    final double confidence = prediction.confidence * 100;
    final Color color = isUnrecognised
        ? Colors.grey
        : (confidence > 70 ? Colors.green : Colors.orange);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'P R E D I C T I O N',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (isUnrecognised)
              const Icon(Icons.help_outline, size: 40, color: Colors.grey),
            if (isUnrecognised) const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isUnrecognised ? 16 : 20,
                fontWeight: FontWeight.bold,
                color: isUnrecognised ? Colors.grey[700] : null,
              ),
            ),
            const SizedBox(height: 8),
            if (isUnrecognised)
              Text(
                'The image may not be a plant leaf, or the disease is not in the training set. Try a clearer close-up of the leaf.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              )
            else
              Text(
                'Confidence: ${confidence.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
