import 'package:flutter/material.dart';
import 'ditruyen_screen.dart';
import 'tienhoa_screen.dart';
import 'sinhthaihoc_screen.dart';

class Si12 extends StatelessWidget {
  const Si12({super.key});

  void goToScreen(BuildContext context, String route) {
    Widget screen;

    switch (route) {
      case 'dtruyen':
        screen = dtruyen();
        break;
      case 'thoa':
        screen = thoa();
        break;
      case 'sthoc':
        screen = sthoc();
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
    final List<Map<String, dynamic>> topics = [
      {
        'tag': 'DI TRUYỀN',
        'icon': Icons.biotech,
        'color': const Color(0xFFFFAB91),
        'route': 'dtruyen',
      },
      {
        'tag': 'TIẾN HÓA',
        'icon': Icons.book_outlined,
        'color': const Color(0xFFF48FB1),
        'route': 'thoa',
      },
      {
        'tag': 'SINH THÁI HỌC',
        'icon': Icons.eco,
        'color': const Color(0xFF80CBC4),
        'route': 'sthoc',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ôn tập: Chủ đề Sinh Học 12',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFE2F3FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
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
                        topic['tag'], // Đã đổi 'label' thành 'tag'
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
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
      ),
    );
  }
}