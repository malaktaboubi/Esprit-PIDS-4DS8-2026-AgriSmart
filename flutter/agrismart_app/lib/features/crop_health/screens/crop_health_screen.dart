import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/services/auth_service.dart';
import '../services/classifier.dart';
import '../services/api_service.dart';
import '../../../core/constants/app_colors.dart';

class CropHealthScreen extends StatefulWidget {
  const CropHealthScreen({super.key});

  @override
  State<CropHealthScreen> createState() => _CropHealthScreenState();
}

class _CropHealthScreenState extends State<CropHealthScreen> {
  CameraController? _controller;
  XFile? _capturedImage;
  bool _isProcessing = false;
  final Classifier _classifier = Classifier();
  late CropHealthApiService _apiService;

  // Diagnosis data
  String _plantName = '';
  String _diseaseName = '';
  double _confidence = 0.0;
  bool _isUnknown = false;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _apiService = CropHealthApiService(authService);
    _initApp();
  }

  Future<void> _initApp() async {
    await _classifier.loadModel();
    await _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      _controller = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Camera Error: $e');
    }
  }

  Future<void> _captureAndAnalyze() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() => _isProcessing = true);

    try {
      final XFile photo = await _controller!.takePicture();
      
      // Run inference
      final result = await _classifier.predict(photo.path);
      
      if (mounted) {
        setState(() {
          _capturedImage = XFile(result.imagePath);
          _plantName = result.plantName;
          _diseaseName = result.diseaseName;
          _confidence = result.confidence;
          _isUnknown = result.isUnknown;
          _isProcessing = false;
        });
      }
    } catch (e) {
      debugPrint('Analysis Error: $e');
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveDiagnosis() async {
    if (_capturedImage == null) return;
    
    setState(() => _isProcessing = true);
    
    try {
      final success = await _apiService.uploadDiagnosis(
        imageFile: File(_capturedImage!.path),
        plantName: _plantName,
        diseaseName: _diseaseName,
        confidence: _confidence,
      );

      if (!mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Diagnosis saved to cloud!'),
            backgroundColor: Colors.green,
          ),
        );
        _reset();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save diagnosis. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _reset() {
    setState(() {
      _capturedImage = null;
      _plantName = '';
      _diseaseName = '';
      _confidence = 0.0;
      _isUnknown = false;
    });
  }

  // UI helpers Matching Original
  Color get _resultCardColor {
    if (_isUnknown) return Colors.redAccent.withOpacity(0.15);
    if (_diseaseName.toLowerCase() == 'healthy') return AppColors.primary.withOpacity(0.15);
    return Colors.orangeAccent.withOpacity(0.15);
  }

  Color get _resultAccentColor {
    if (_isUnknown) return Colors.redAccent;
    if (_diseaseName.toLowerCase() == 'healthy') return AppColors.primary;
    return Colors.orangeAccent;
  }

  IconData get _resultIcon {
    if (_isUnknown) return Icons.help_outline_rounded;
    if (_diseaseName.toLowerCase() == 'healthy') return Icons.check_circle_outline_rounded;
    return Icons.warning_amber_rounded;
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Plant Doctor AI',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_capturedImage != null)
            IconButton(
              onPressed: _reset,
              icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
              tooltip: 'Retake',
            ),
        ],
      ),
      body: Column(
        children: [
          // Camera / photo viewport
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.green.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: _capturedImage == null
                  ? CameraPreview(_controller!)
                  : Image.file(
                      File(_capturedImage!.path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
            ),
          ),

          // Bottom control panel
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isProcessing) ...[
                  const LinearProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  const Text(
                    'AI is analyzing the image…',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                ] else if (_capturedImage == null) ...[
                  // Idle state
                  const Text(
                    'Position the leaf clearly inside the frame',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _captureAndAnalyze,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text(
                      'TAKE PHOTO',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ] else ...[
                  // Result card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: _resultCardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _resultAccentColor.withOpacity(0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(_resultIcon, color: _resultAccentColor, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _plantName.toUpperCase(),
                                style: TextStyle(
                                  color: _resultAccentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                                Text(
                                _diseaseName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (!_isUnknown) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Confidence: ${(_confidence * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _reset,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 50),
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('RETAKE'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveDiagnosis,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(0, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('SAVE HISTORY'),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _classifier.dispose();
    super.dispose();
  }
}
