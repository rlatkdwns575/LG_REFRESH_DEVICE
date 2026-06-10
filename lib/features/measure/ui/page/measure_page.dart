import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../data/api/hair_analysis_service.dart';
import '../../data/api/hair_measurement_api.dart';
import '../../data/device/hair_refresher_device.dart';
import '../../data/device/hair_refresher_device_service.dart';
import '../../data/model/hair_measurement.dart';
import '../widgets/measurement_result_view.dart';

class MeasurePage extends StatefulWidget {
  const MeasurePage({super.key});

  @override
  State<MeasurePage> createState() => _MeasurePageState();
}

class _MeasurePageState extends State<MeasurePage> {
  final HairRefresherDeviceService _deviceService =
      const HairRefresherDeviceService();
  final HairAnalysisService _analysisService = HairAnalysisService();
  final HairMeasurementApi _measurementApi = const HairMeasurementApi();

  HairRefresherDevice? _device;
  HairMeasurement? _measurement;
  bool _isConnecting = true;
  bool _isProcessing = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _connectDemoDevice();
  }

  Future<void> _connectDemoDevice() async {
    final device = await _deviceService.connectDemoDevice();

    if (!mounted) {
      return;
    }
    setState(() {
      _device = device;
      _isConnecting = false;
      _statusMessage = '${device.name} 연결됨';
    });
  }

  Future<void> _runMockCaptureFlow() async {
    final device = _device;
    if (device == null || !device.isConnected) {
      setState(() {
        _statusMessage = '디바이스 연결 후 스캔할 수 있습니다.';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = null;
    });

    try {
      const imagePath = 'local/mock/hair_capture.jpg';
      final measurement = await _analysisService.analyzeImage(
        imagePath: imagePath,
        deviceId: device.id,
      );
      final saved = await _measurementApi.trySaveMeasurement(measurement);

      if (!mounted) {
        return;
      }
      setState(() {
        _measurement = measurement;
        _statusMessage = saved ? '스캔 결과를 저장했습니다.' : '저장 설정 없이 로컬 데모 결과를 표시합니다.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage = '스캔 분석에 실패했습니다.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final device = _device;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const Text('Hair Scan Demo', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              '고정 디바이스 ID characteristic을 사용하는 BLE 연동 시연 화면입니다.',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('디바이스', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _isConnecting
                        ? '연결 중'
                        : '${device?.name ?? '연결 없음'} / ${device?.id ?? '-'}',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AspectRatio(
                    aspectRatio: 4 / 3,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Color(0xFFE8EFEC)),
                      child: Center(
                        child: Icon(Icons.camera_alt_outlined, size: 56),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.icon(
                    onPressed: _isConnecting || _isProcessing
                        ? null
                        : _runMockCaptureFlow,
                    icon: _isProcessing
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.document_scanner_outlined),
                    label: Text(_isProcessing ? '스캔 분석 중' : '스캔 시작'),
                  ),
                ],
              ),
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(_statusMessage!, style: AppTextStyles.caption),
            ],
            if (_measurement != null) ...[
              const SizedBox(height: AppSpacing.md),
              MeasurementResultView(measurement: _measurement!),
            ],
          ],
        ),
      ),
    );
  }
}
