import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class Classifier {
  Interpreter? _interpreter;
  List<String>? _labels;

  static const int _inputSize = 224;
  static const double _kConfidenceThreshold = 0.65;
  static const double _kBrightnessThreshold = 30.0;

  Future<void> loadModel() async {
    try {
      _interpreter ??= await Interpreter.fromAsset('assets/plant_disease_model.tflite');
      if (_labels == null) {
        final labelString = await rootBundle.loadString('assets/labels.txt');
        _labels = labelString.split('\n').where((s) => s.isNotEmpty).toList();
      }
    } catch (e) {
      debugPrint('Error loading model: $e');
    }
  }

  Future<DiagnosisResult> predict(String imagePath) async {
    // 1. Preprocess in isolate (EXIF, Crop, Resize, Brightness)
    final preprocessed = await compute(_processImageIsolate, imagePath);
    if (preprocessed == null) {
      // Replicating original "recognitions == null" case message
      return DiagnosisResult(
        plantName: 'Unknown Object',
        diseaseName: 'Not a leaf or unrecognized image',
        imagePath: imagePath,
        isUnknown: true,
      );
    }

    final double brightness = preprocessed['brightness'] as double;
    final String processedPath = preprocessed['path'] as String;

    if (brightness < _kBrightnessThreshold) {
      return DiagnosisResult(
        plantName: 'Unknown Object',
        diseaseName: 'Image too dark – try better lighting',
        imagePath: processedPath,
        isUnknown: true,
      );
    }

    // 2. Ensure model and labels are ready
    await loadModel();
    
    if (_labels == null || _labels!.isEmpty) {
      return DiagnosisResult(
        plantName: 'Error',
        diseaseName: 'Labels file not found',
        imagePath: processedPath,
        isUnknown: true,
      );
    }

    // 3. Prepare Input Tensor
    final bytes = File(processedPath).readAsBytesSync();
    final image = img.decodeImage(bytes)!;
    
    final input = Float32List(1 * _inputSize * _inputSize * 3);
    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = image.getPixel(x, y);
        final index = (y * _inputSize + x) * 3;
        // pixel.r/g/b for image 4.x
        input[index + 0] = (pixel.r - 127.5) / 127.5;
        input[index + 1] = (pixel.g - 127.5) / 127.5;
        input[index + 2] = (pixel.b - 127.5) / 127.5;
      }
    }

    // 4. Run Inference
    final output = List<double>.filled(38, 0.0).reshape([1, 38]);
    _interpreter!.run(input.buffer.asFloat32List().reshape([1, 224, 224, 3]), output);

    // 5. Post-process
    final results = (output[0] as List<double>);
    double maxScore = -1.0;
    int maxIndex = -1;
    for (int i = 0; i < results.length; i++) {
      if (results[i] > maxScore) {
        maxScore = results[i];
        maxIndex = i;
      }
    }

    // Threshold check matching original logic exactly
    if (maxIndex == -1 || maxScore < _kConfidenceThreshold) {
      return DiagnosisResult(
        plantName: 'Unknown Object',
        diseaseName: 'Not a leaf or uncertain (Confidence: ${(maxScore * 100).toStringAsFixed(0)}%)',
        imagePath: processedPath,
        confidence: maxScore,
        isUnknown: true,
      );
    }

    // 6. Parse Label (EXACT Original Logic)
    final String rawLabel = _labels![maxIndex];
    final List<String> parts = rawLabel.split('___');
    final String plant = parts[0]
        .replaceAll('_', ' ')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .trim();
    final String disease =
        parts.length > 1 ? parts[1].replaceAll('_', ' ') : 'Healthy';

    return DiagnosisResult(
      plantName: plant,
      diseaseName: disease,
      imagePath: processedPath,
      confidence: maxScore,
      isUnknown: false,
    );
  }

  void dispose() {
    _interpreter?.close();
  }
}

class DiagnosisResult {
  final String plantName;
  final String diseaseName;
  final String imagePath;
  final double confidence;
  final bool isUnknown;

  DiagnosisResult({
    required this.plantName,
    required this.diseaseName,
    required this.imagePath,
    this.confidence = 0.0,
    this.isUnknown = false,
  });
}

Map<String, dynamic>? _processImageIsolate(String path) {
  try {
    final bytes = File(path).readAsBytesSync();
    img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    decoded = img.bakeOrientation(decoded);

    double total = 0;
    int count = 0;
    for (final pixel in decoded) {
      total += 0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b;
      count++;
    }
    double brightness = count == 0 ? 255.0 : total / count;

    int size = decoded.width < decoded.height ? decoded.width : decoded.height;
    int xPos = (decoded.width - size) ~/ 2;
    int yPos = (decoded.height - size) ~/ 2;
    img.Image cropped = img.copyCrop(decoded, x: xPos, y: yPos, width: size, height: size);
    
    // Using linear interpolation for better match with standard resizing
    img.Image resized = img.copyResize(cropped, width: 224, height: 224, interpolation: img.Interpolation.linear);

    final ext = path.split('.').last;
    final outPath = path.replaceAll('.$ext', '_cropped.$ext');
    File(outPath).writeAsBytesSync(img.encodeJpg(resized, quality: 90));

    return {'path': outPath, 'brightness': brightness};
  } catch (e) {
    return null;
  }
}
