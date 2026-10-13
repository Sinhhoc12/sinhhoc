import 'package:flutter/material.dart';
import 'screens/trangsinhhoc.dart';
void main() {
  runApp(const sinhhocApp());
}

class sinhhocApp extends StatelessWidget {
  const sinhhocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Ẩn nhãn DEBUG ở góc màn hình
      title: 'Ôn Tập Sinh Học',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
        useMaterial3: true,
      ),
      // Đặt màn hình chính chạy thẳng vào class SinhHoc
      home: sinhhoc(),
    );
  }
}