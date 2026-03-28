class Diagnosis {
  final int? id; // Nullable for new records, set for DB records
  final String plantName;
  final String diseaseName;
  final String date;
  final String imagePath; // Local path or URL
  final double confidence;
  final bool isUnknown;

  Diagnosis({
    this.id,
    required this.plantName,
    required this.diseaseName,
    required this.date,
    required this.imagePath,
    this.confidence = 0.0,
    this.isUnknown = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'plant_name': plantName,
        'disease_name': diseaseName,
        'created_at': date,
        'image_url': imagePath,
        'confidence': confidence,
        'is_unknown': isUnknown,
      };

  factory Diagnosis.fromMap(Map<String, dynamic> map) => Diagnosis(
        id: map['id'],
        plantName: map['plant_name'] ?? 'Unknown',
        diseaseName: map['disease_name'] ?? 'Unknown',
        date: map['created_at'] ?? '',
        imagePath: map['image_url'] ?? '',
        confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
        isUnknown: map['is_unknown'] ?? false,
      );
}
