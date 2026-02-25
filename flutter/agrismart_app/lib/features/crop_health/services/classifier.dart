import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:convert';
import 'dart:async';

class Classifier {
  Interpreter? _interpreter;
  List<String>? _labels;

  static const String modelFileName = 'assets/agrismart_model.tflite';
  static const String labelsFileName = 'assets/class_labels.json';
  static const int inputSize = 224;

  /// Completer to track when initialization is done.
  /// Await [ready] before calling [predict].
  final Completer<void> _initCompleter = Completer<void>();

  /// A future that completes when the model and labels are loaded.
  Future<void> get ready => _initCompleter.future;

  /// Whether the classifier is ready to make predictions.
  bool get isReady => _interpreter != null && _labels != null;

  Classifier() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await Future.wait([_loadModel(), _loadLabels()]);
      _initCompleter.complete();
    } catch (e) {
      _initCompleter.completeError(e);
      debugPrint('Error initializing classifier: $e');
    }
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(modelFileName);
      debugPrint('Model loaded successfully');
    } catch (e) {
      debugPrint('Error loading model: $e');
      rethrow;
    }
  }

  Future<void> _loadLabels() async {
    try {
      final jsonString = await rootBundle.loadString(labelsFileName);
      final Map<String, dynamic> labelsMap = json.decode(jsonString);
      // Keys are indices '0', '1', etc.
      _labels = List<String>.generate(
        labelsMap.length,
        (index) => labelsMap[index.toString()] ?? 'Unknown',
      );
      debugPrint('Labels loaded successfully: $_labels');
    } catch (e) {
      debugPrint('Error loading labels: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> predict(File imageFile) async {
    // Wait for model and labels to be loaded before predicting
    await ready;

    if (_interpreter == null) {
      debugPrint('Interpreter is null');
      return null;
    }
    if (_labels == null) {
      debugPrint('Labels are null');
      return null;
    }

    // 1. Preprocess the image
    var image = img.decodeImage(imageFile.readAsBytesSync());
    if (image == null) return null;

    // Center-crop to a square first to reduce aspect-ratio distortion.
    // This matches the standard MobileNetV2 preprocessing pipeline and
    // avoids stretching non-square photos (e.g. real field shots).
    final int cropSize = math.min(image.width, image.height);
    final int xOffset = (image.width - cropSize) ~/ 2;
    final int yOffset = (image.height - cropSize) ~/ 2;
    final croppedImage = img.copyCrop(
      image,
      x: xOffset,
      y: yOffset,
      width: cropSize,
      height: cropSize,
    );

    // Resize to 224x224 using BILINEAR interpolation
    // (matching TensorFlow's default resize used during training)
    var resizedImage = img.copyResize(
      croppedImage,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.linear,
    );

    // Convert to float32 List [1, 224, 224, 3]
    var input = _imageToFloat32List(resizedImage);

    // 2. Run inference
    // Output shape: [1, 38] (38 classes)
    var output = List.filled(1 * 38, 0.0).reshape([1, 38]);

    _interpreter!.run(input, output);

    // 3. Postprocess output
    var result = output[0] as List<double>;

    // Build a list of (index, score) and sort descending by score
    var indexed = <MapEntry<int, double>>[];
    for (var i = 0; i < result.length; i++) {
      indexed.add(MapEntry(i, result[i]));
    }
    indexed.sort((a, b) => b.value.compareTo(a.value));

    // ── Debug: print top-3 predictions ──
    debugPrint('─── Top-3 predictions ───');
    for (var k = 0; k < math.min(3, indexed.length); k++) {
      final idx = indexed[k].key;
      final score = indexed[k].value;
      debugPrint('  #${k + 1}  ${_labels![idx]}  →  ${(score * 100).toStringAsFixed(1)}%');
    }
    debugPrint('─────────────────────────');

    var maxScore = indexed[0].value;
    var maxIndex = indexed[0].key;

    // Reject predictions that fall below the confidence threshold.
    // With label_smoothing=0.1 + temperature scaling (T=1.2), valid
    // leaf images score ~50-80% while OOD images (non-leaves) score
    // below 0.30, so this threshold separates them reliably.
    const double confidenceThreshold = 0.30;
    if (maxScore < confidenceThreshold) {
      return {'label': 'Unrecognised', 'confidence': maxScore * 100};
    }

    var label = _labels![maxIndex];
    return {'label': label, 'confidence': maxScore * 100};
  }

  List<dynamic> _imageToFloat32List(img.Image image) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        // IMPORTANT: In dart image package v4+, pixel.r/g/b returns num.
        // We must convert to int first to ensure [0-255] integer range,
        // then to double for float32 input.
        // The TFLite model has a built-in Rescaling layer that converts
        // [0-255] -> [-1, 1] (MobileNetV2 preprocessing), so we pass
        // raw pixel values in [0, 255] range.
        buffer[pixelIndex++] = pixel.r.toInt().clamp(0, 255).toDouble();
        buffer[pixelIndex++] = pixel.g.toInt().clamp(0, 255).toDouble();
        buffer[pixelIndex++] = pixel.b.toInt().clamp(0, 255).toDouble();
      }
    }
    return convertedBytes.reshape([1, inputSize, inputSize, 3]);
  }
}
