import 'package:flutter/material.dart';
import 'chitietkqtn.dart';
import 'siTracnghiemGK1_screen.dart';
import 'siTracnghiemCK1_screen.dart';
import 'siTracnghiemGK2_screen.dart';
import 'siTracnghiemCK2_screen.dart';
import 'SiTN10_screen.dart';
import 'SiTN11_screen.dart';
import 'ditruyenTN_screen.dart';
import 'tienhoaTN_screen.dart';
import 'sinhthaihocTN_screen.dart';
class ResultScreen extends StatelessWidget {
  final int totalQuestions;
  final int correctAnswers;
  final String theme;
  final List<Map<String, dynamic>> questions;
  final List<String?> userAnswers;
  final String manhinh;
  final String tenHocSinh;

  const ResultScreen({
    super.key,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.theme,
    required this.questions,
    required this.userAnswers,
    required this.manhinh,
    this.tenHocSinh = " ",
  });

  Color getBackgroundColor() {
    switch (theme) {
      case 'cute':
        return Colors.pink.shade50;
      case 'space':
        return Colors.blue.shade50;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBackgroundColor(),
      appBar: AppBar(
        title: const Text(
          '🎉 Kết quả ôn tập',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme == 'cute' ? Colors.pinkAccent : Colors.blueAccent,
        elevation: 4,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Bạn đã trả lời đúng:',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '$correctAnswers / $totalQuestions câu',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: theme == 'cute' ? Colors.pinkAccent : Colors.indigo,
            ),
          ),
          const SizedBox(height: 40),

          //  Nút XEM CHI TIẾT & LÀM LẠI
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(
                        questions: questions,
                        userAnswers: userAnswers,
                        theme: theme,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.list, color: Colors.white),
                label: const Text(
                  'XEM CHI TIẾT',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 3,
                ),
              ),
              const SizedBox(width: 70),
              ElevatedButton.icon(
                onPressed: () {
                  Widget screen = const Placeholder();
                  if (manhinh == 'GK1') {
                    screen = const siTracnghiemGK1();
                  }else if (manhinh == 'CK1') {
                    screen = const siTracnghiemCK1();
                  }else if (manhinh == 'GK2') {
                    screen = const siTracnghiemGK2();
                  }else if (manhinh == 'CK2') {
                    screen = const siTracnghiemCK2();
                  }else if (manhinh == 'TB') {
                    screen = const SiTN10();
                  }else if (manhinh == 'TV') {
                    screen = const SiTN11();
                  }else if (manhinh == 'DT') {
                    screen = const ditruyenTN();
                  }else if (manhinh == 'TH') {
                    screen = const tienhoaTN();
                  }else if (manhinh == 'ST') {
                    screen = const sinhthaihocTN();
                  }
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => screen),
                  );
                },

                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'LÀM LẠI',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 3,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
