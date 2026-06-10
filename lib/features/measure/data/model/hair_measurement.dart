class HairMeasurement {
  const HairMeasurement({
    required this.id,
    required this.deviceId,
    required this.createdAt,
    required this.imagePath,
    required this.contaminationScore,
    required this.contaminationLevel,
    required this.hairThicknessLevel,
    required this.damageLevel,
    required this.dustResidueLevel,
    required this.dustDistributionLevel,
    required this.odorResidueLevel,
    required this.odorTypes,
    required this.oilLevel,
  });

  final String id;
  final String deviceId;
  final DateTime createdAt;
  final String imagePath;
  final int contaminationScore;
  final int contaminationLevel;
  final int hairThicknessLevel;
  final int damageLevel;
  final int dustResidueLevel;
  final int dustDistributionLevel;
  final int odorResidueLevel;
  final List<String> odorTypes;
  final int oilLevel;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'created_at': createdAt.toIso8601String(),
      'image_path': imagePath,
      'contamination_score': contaminationScore,
      'contamination_level': contaminationLevel,
      'hair_thickness_level': hairThicknessLevel,
      'damage_level': damageLevel,
      'dust_residue_level': dustResidueLevel,
      'dust_distribution_level': dustDistributionLevel,
      'odor_residue_level': odorResidueLevel,
      'odor_types': odorTypes,
      'oil_level': oilLevel,
    };
  }

  factory HairMeasurement.fromJson(Map<String, dynamic> json) {
    return HairMeasurement(
      id: json['id'] as String,
      deviceId: json['device_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      imagePath: json['image_path'] as String,
      contaminationScore: json['contamination_score'] as int,
      contaminationLevel: json['contamination_level'] as int,
      hairThicknessLevel: json['hair_thickness_level'] as int,
      damageLevel: json['damage_level'] as int,
      dustResidueLevel: json['dust_residue_level'] as int,
      dustDistributionLevel: json['dust_distribution_level'] as int,
      odorResidueLevel: json['odor_residue_level'] as int,
      odorTypes: List<String>.from(json['odor_types'] as List),
      oilLevel: json['oil_level'] as int,
    );
  }
}
