# Crop Health Module

Mobile Crop Disease Detection using MobileNetV2 and TensorFlow Lite.

## Structure
- `screens/` - UI screens for crop disease detection
  - `home_screen.dart` - Main interface for image capture and disease classification
- `services/` - Business logic and ML services
  - `classifier.dart` - TFLite model wrapper for disease prediction
- `models/` - Data models for crop health data

## Features
- Image capture via camera or gallery
- Real-time disease classification
- Prediction confidence scores
- Disease information and recommendations
