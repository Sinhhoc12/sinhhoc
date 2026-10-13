import 'package:flutter/material.dart';
import 'TLNchitietkq.dart';

// 🔹 Đổi sang màn hình trả lời ngắn
import 'SiTLNGK1_screen.dart';
import 'SiTLNCK1_screen.dart';
import 'SiTLNGK2_screen.dart';
import 'SiTLNCK2_screen.dart';
import 'ditruyenTLN_screen.dart';
import 'tienhoaTLN_screen.dart';
import 'sinhthaihocTLN_screen.dart';
class tlnResultScreen extends StatelessWidget {
  final int totalQuestions;
  final int correctAnswers;
  final String theme;
  final List<Map<String, dynamic>> questions;
  final List<String?> userAnswers;
  final String manhinh;
  final String tenHocSinh;

  const tlnResultScreen({
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

        backgroundColor:
        theme == 'cute'
            ? Colors.pinkAccent
            : Colors.blueAccent,

        elevation: 4,
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Text(
            '$tenHocSinh\n\n Bạn đã trả lời đúng:',

            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),

            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          Text(
            '$correctAnswers / $totalQuestions câu',

            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color:
              theme == 'cute'
                  ? Colors.pinkAccent
                  : Colors.indigo,
            ),
          ),

          const SizedBox(height: 40),

          // 🔹 Nút XEM CHI TIẾT & LÀM LẠI
          Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder:
                          (context) => DetailScreen(
                        questions: questions,
                        userAnswers: userAnswers,
                        theme: theme,
                      ),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.list,
                  color: Colors.white,
                ),

                label: const Text(
                  'XEM CHI TIẾT',

                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 18,
                  ),

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

                  // 🔹 Đổi sang màn hình trả lời ngắn
                  if (manhinh == 'GK1') {
                    screen = const TraLoiNganScreenGK1();
                  }else if (manhinh == 'CK1') {
                    screen = const TraLoiNganScreenCK1();
                  }else if (manhinh == 'GK2') {
                    screen = const TraLoiNganScreenGK2();
                  }else if (manhinh == 'CK2') {
                    screen = const TraLoiNganScreenCK2();
                  }
                  else if (manhinh == 'DT') {
                    screen = const ditruyenTLN();
                  } else if (manhinh == 'TH') {
                    screen = const tienhoaTLN();
                  }else if (manhinh == 'ST') {
                    screen = const sinhthaihocTLN();
                  }

                  Navigator.pushReplacement(
                    context,

                    MaterialPageRoute(
                      builder: (context) => screen,
                    ),
                  );
                },

                icon: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),

                label: const Text(
                  'LÀM LẠI',

                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 18,
                  ),

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