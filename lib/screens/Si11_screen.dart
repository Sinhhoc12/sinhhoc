import 'package:flutter/material.dart';
import 'SiDS11_screen.dart';
import 'SiTN11_screen.dart';

class Si11 extends StatelessWidget {
  const Si11({super.key});
  void goToScreen(BuildContext context, String route) {
    Widget screen;

    switch (route) {
      case '4luachon':
        screen = SiTN11();
        break;
      case 'dungsai':
        screen = dungsai11();
        break;
      default:
        screen = const Scaffold(
          body: Center(child: Text('Chủ đề đang cập nhật')),
        );
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
  @override
  Widget build(BuildContext context) {

    final List<Map<String, dynamic>> topics = const [
      {
        'label': 'Sinh Học\n Cơ Thể Thực Vật',
        'icon': Icons.list_alt,
        'desc': 'Trắc nghiệm',
        'color': Color(0xFF66BB6A),
        'route': '4luachon',
      },
      {
        'label': 'Sinh Học\n Cơ Thể Động Vật',
        'icon': Icons.check_circle_outline,
        'desc': 'Đúng/ Sai',
        'color': Color(0xFFFFCC80),
        'route': 'dungsai',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        title: const Text(
          'Chọn kiểu trắc nghiệm',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: topics.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final topic = topics[index];
            return GestureDetector(
              onTap: () => goToScreen(context, topic['route']),
              child: Container(
                decoration: BoxDecoration(
                  color: topic['color'],
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      topic['icon'],
                      size: 40,
                      color: Colors.indigo[700],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      topic['label'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
