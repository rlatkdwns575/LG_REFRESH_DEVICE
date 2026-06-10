import 'dart:math';

import '../model/hair_measurement.dart';

class HairAnalysisService {
  HairAnalysisService({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const odorTypeOptions = ['먼지', '연기', '음식', '화장품', '기타'];

  Future<HairMeasurement> analyzeImage({
    required String imagePath,
    required String deviceId,
  }) async {
    final dustResidueLevel = _randomLevel(4);
    final dustDistributionLevel = _randomLevel(4);
    final odorResidueLevel = _randomLevel(4);
    final oilLevel = _randomLevel(4);
    final contamination = calculateContamination(
      dustResidueLevel: dustResidueLevel,
      dustDistributionLevel: dustDistributionLevel,
      odorResidueLevel: odorResidueLevel,
      oilLevel: oilLevel,
    );

    return HairMeasurement(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      deviceId: deviceId,
      createdAt: DateTime.now(),
      imagePath: imagePath,
      contaminationScore: contamination.score,
      contaminationLevel: contamination.level,
      hairThicknessLevel: _randomLevel(3),
      damageLevel: _randomLevel(3),
      dustResidueLevel: dustResidueLevel,
      dustDistributionLevel: dustDistributionLevel,
      odorResidueLevel: odorResidueLevel,
      odorTypes: _randomOdorTypes(),
      oilLevel: oilLevel,
    );
  }

  static ({int score, int level}) calculateContamination({
    required int dustResidueLevel,
    required int dustDistributionLevel,
    required int odorResidueLevel,
    required int oilLevel,
  }) {
    final weightedRatio =
        (_normalizeLevel(dustResidueLevel, 4) * 0.35) +
        (_normalizeLevel(dustDistributionLevel, 4) * 0.25) +
        (_normalizeLevel(odorResidueLevel, 4) * 0.25) +
        (_normalizeLevel(oilLevel, 4) * 0.15);
    final score = (1 + (weightedRatio * 9)).round().clamp(1, 10);

    return (score: score, level: contaminationLevelFor(score));
  }

  static int contaminationLevelFor(int score) {
    if (score <= 2) {
      return 1;
    }
    if (score <= 4) {
      return 2;
    }
    if (score <= 6) {
      return 3;
    }
    if (score <= 8) {
      return 4;
    }
    return 5;
  }

  static double _normalizeLevel(int level, int max) {
    return ((level.clamp(1, max) - 1) / (max - 1));
  }

  int _randomLevel(int max) {
    return 1 + _random.nextInt(max);
  }

  List<String> _randomOdorTypes() {
    final shuffled = [...odorTypeOptions]..shuffle(_random);
    final count = 1 + _random.nextInt(3);
    return shuffled.take(count).toList();
  }
}
