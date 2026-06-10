import 'package:flutter_test/flutter_test.dart';
import 'package:lg_device/features/measure/data/api/hair_analysis_service.dart';

void main() {
  group('HairAnalysisService.calculateContamination', () {
    test('returns the minimum score and level for clean scan values', () {
      final result = HairAnalysisService.calculateContamination(
        dustResidueLevel: 1,
        dustDistributionLevel: 1,
        odorResidueLevel: 1,
        oilLevel: 1,
      );

      expect(result.score, 1);
      expect(result.level, 1);
    });

    test('returns the maximum score and level for polluted scan values', () {
      final result = HairAnalysisService.calculateContamination(
        dustResidueLevel: 4,
        dustDistributionLevel: 4,
        odorResidueLevel: 4,
        oilLevel: 4,
      );

      expect(result.score, 10);
      expect(result.level, 5);
    });

    test('uses weighted scan values for the contamination score', () {
      final result = HairAnalysisService.calculateContamination(
        dustResidueLevel: 4,
        dustDistributionLevel: 3,
        odorResidueLevel: 2,
        oilLevel: 1,
      );

      expect(result.score, 6);
      expect(result.level, 3);
    });
  });
}
