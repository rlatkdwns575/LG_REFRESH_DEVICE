import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../data/model/hair_measurement.dart';

class MeasurementResultView extends StatelessWidget {
  const MeasurementResultView({required this.measurement, super.key});

  final HairMeasurement measurement;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('스캔 결과', style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppSpacing.md),
          _MetricRow(label: '디바이스 ID', value: measurement.deviceId),
          _MetricRow(
            label: '오염도 점수',
            value: '${measurement.contaminationScore} / 10',
          ),
          _MetricRow(
            label: '오염도 단계',
            value: '${measurement.contaminationLevel}단계 / 5단계',
          ),
          _MetricRow(
            label: '모발 굵기',
            value: '${measurement.hairThicknessLevel}단계 / 3단계',
          ),
          _MetricRow(label: '손상도', value: '${measurement.damageLevel}단계 / 3단계'),
          _MetricRow(
            label: '먼지 잔여도',
            value: '${measurement.dustResidueLevel}단계 / 4단계',
          ),
          _MetricRow(
            label: '먼지 분포',
            value: '${measurement.dustDistributionLevel}단계 / 4단계',
          ),
          _MetricRow(
            label: '냄새 잔여도',
            value: '${measurement.odorResidueLevel}단계 / 4단계',
          ),
          _MetricRow(label: '냄새 유형', value: measurement.odorTypes.join(', ')),
          _MetricRow(label: '유분도', value: '${measurement.oilLevel}단계 / 4단계'),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }
}
