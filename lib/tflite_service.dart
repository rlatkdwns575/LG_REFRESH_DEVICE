import 'dart:io';
import 'dart:math' as math; // ◀ Softmax 지수 연산을 위해 필수 임포트
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class TfliteService {
  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> initModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      final labelString = await rootBundle.loadString('assets/labels.txt');
      _labels = labelString.split('\n').where((e) => e.isNotEmpty).toList();
      print("🎯 모바일 환경: TFLite 모델 로드 성공");
    } catch (e) {
      print("❌ 모델 로드 중 에러: $e");
      _interpreter = null;
      _labels = null;
    }
  }

  // 💡 [Softmax 구현] 모델의 raw 출력값(Logits)을 0~1 사이의 확률 분포로 변환합니다.
  List<double> _softmax(List<double> logits) {
    double maxVal = logits.reduce(math.max);
    List<double> exps = logits.map((x) => math.exp(x - maxVal)).toList();
    double sumExps = exps.reduce((a, b) => a + b);
    return exps.map((x) => x / sumExps).toList();
  }

  Future<List<List<List<List<double>>>>> _preprocessImage(
    File imageFile,
  ) async {
    final imageBytes = await imageFile.readAsBytes();
    final originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) throw Exception("이미지 디코딩 실패");

    const int inputSize = 224;
    final resizedImage = img.copyResize(
      originalImage,
      width: inputSize,
      height: inputSize,
    );

    var input = List.generate(
      1,
      (_) => List.generate(
        3,
        (_) => List.generate(
          inputSize,
          (_) => List<double>.filled(inputSize, 0.0),
        ),
      ),
    );

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resizedImage.getPixel(x, y);
        input[0][0][y][x] = ((pixel.r / 255.0) - 0.485) / 0.229;
        input[0][1][y][x] = ((pixel.g / 255.0) - 0.456) / 0.224;
        input[0][2][y][x] = ((pixel.b / 255.0) - 0.406) / 0.225;
      }
    }
    return input;
  }

  Future<String> runInference(File imageFile) async {
    if (_interpreter == null) return "모델이 로드되지 않았습니다.";

    try {
      final inputImageMatrix = await _preprocessImage(imageFile);
      var inputTabMatrix = [List<double>.filled(3, 0.0)];
      var inputs = [inputImageMatrix, inputTabMatrix];

      // 아웃풋 버퍼 매핑
      var outputDamage = List.generate(1, (_) => List<double>.filled(4, 0.0));
      var outputWidth = List.generate(1, (_) => List<double>.filled(3, 0.0));
      var outputs = {0: outputDamage, 1: outputWidth};

      // 추론 실행
      _interpreter!.runForMultipleInputs(inputs, outputs);

      // =====================================================================
      // 📊 🔍 [정밀 매칭 레이어] 코랩 데이터 가공 엔진 완벽 이식
      // =====================================================================

      // 1. Raw 실숫값을 Softmax 함수를 통해 0~100% 확률 매트릭스로 래핑
      final List<double> pDmg = _softmax(List<double>.from(outputDamage[0]));
      final List<double> pWd = _softmax(List<double>.from(outputWidth[0]));

      // 2. 코랩 노트북 가이드라인 수식 그대로 적용
      // 인덱스 기준 -> 0: 건강모, 1: 극손상모, 2: 버진, 3: 손상모
      double hdiScore =
          (pDmg[3] * 50) + (pDmg[1] * 100) + (pDmg[0] * 20) + (pDmg[2] * 5); //
      double chemicalAlteration = (1.0 - pDmg[2]) * 100; //

      // 3. 최댓값 확률 인덱스(Argmax) 추출
      int maxDmgIdx = 0;
      double maxDmgVal = pDmg[0];
      for (int i = 1; i < pDmg.length; i++) {
        if (pDmg[i] > maxDmgVal) {
          maxDmgVal = pDmg[i];
          maxDmgIdx = i;
        }
      }

      int maxWdIdx = 0;
      double maxWdVal = pWd[0];
      for (int i = 1; i < pWd.length; i++) {
        if (pWd[i] > maxWdVal) {
          maxWdVal = pWd[i];
          maxWdIdx = i;
        }
      }

      // 4. 고유 매핑 데이터 바인딩
      final idxToDamage = {0: '건강모', 1: '극손상모', 2: '버진', 3: '손상모'}; //
      final idxToWidth = {0: '얇음', 1: '보통', 2: '굵음'}; //

      String hairBaseState = idxToDamage[maxDmgIdx] ?? "분석 불가";
      String hairWidthState = idxToWidth[maxWdIdx] ?? "분석 불가";

      // 5. 유저가 요청한 모든 지표를 멀티라인 스트링으로 가공하여 반환
      return "🎯 [AI 실시간 모발 진단서]\n\n"
          "• 모발 상태 기본형: $hairBaseState\n"
          "• 모발 두께 측정군: $hairWidthState\n"
          "• 모발 손상 지수(HDI): ${hdiScore.toStringAsFixed(1)}점\n"
          "• 화학적 변성 비율: ${chemicalAlteration.toStringAsFixed(1)}%";
    } catch (e) {
      return "추론 중 에러 발생: $e";
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}
