import 'package:flutter/material.dart';
import 'screen/system_dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Dashboard',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        fontFamily: 'Roboto', // Bạn có thể thêm font custom sau
      ),
      home: const SystemDashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
