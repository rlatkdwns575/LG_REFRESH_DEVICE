import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'tflite_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mojito TFLite',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TfliteService _tfliteService = TfliteService();
  final ImagePicker _picker = ImagePicker();

  XFile? _image;
  String _analysisResult = "사진을 선택하면 인공지능 분석이 시작됩니다.";
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    print("▶ [Log] initState 호출 - TFLite 모델 로딩 시작");
    _tfliteService.initModel();
  }

  Future<void> _pickAndAnalyzeImage(ImageSource source) async {
    print("▶ [Log] 버튼 클릭됨 - 소스: $source");
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) {
        print("❌ [Log] 사진 선택이 취소되었습니다.");
        return;
      }

      print("📸 [Log] 사진 선택 완료: ${pickedFile.path}");
      setState(() {
        _image = pickedFile;
        _isProcessing = true;
        _analysisResult = "딥러닝 모델 분석 중...";
      });

      print("🤖 [Log] TFLite 추론 연산 시작...");
      final result = await _tfliteService.runInference(io.File(_image!.path));
      print("🎯 [Log] 추론 완료 결과: $result");

      setState(() {
        _analysisResult = result;
        _isProcessing = false;
      });
    } catch (e) {
      print("💥 [Log] 에러 발생: $e");
      setState(() {
        _analysisResult = "오류 발생: $e";
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _tfliteService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mojito AI Inference'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Container(
                  height: 350,
                  width: double.infinity,
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: kIsWeb
                              ? Image.network(_image!.path, fit: BoxFit.cover)
                              : Image.file(
                                  io.File(_image!.path),
                                  fit: BoxFit.cover,
                                ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image_search,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 24),

                // 🔍 [수정 부분] 멀티라인 결과 리포트를 깔끔하게 담기 위한 텍스트 레이아웃 최적화
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    _analysisResult,
                    style: TextStyle(
                      fontSize: 16, // ◀ 장문 리포트 가독성을 위한 폰트 다운사이징
                      fontWeight: FontWeight.w600, // ◀ 가독성을 위한 적절한 굵기 감도 세팅
                      color: Colors.green[900], // ◀ 배경 색상과의 명도 대비 최적화
                      height: 1.5, // ◀ 리포트 줄간격 최적화 확보
                    ),
                    textAlign:
                        TextAlign.left, // ◀ [핵심 고정] 줄마다 시작점을 맞추기 위해 왼쪽 정렬로 변경!
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing
                            ? null
                            : () => _pickAndAnalyzeImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('갤러리 열기'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing
                            ? null
                            : () => _pickAndAnalyzeImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('카메라 촬영'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
