import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import '../features/measure/ui/page/measure_page.dart';

class LgHairRefresherApp extends StatelessWidget {
  const LgHairRefresherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LG Hair Scan Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MeasurePage(),
    );
  }
}
