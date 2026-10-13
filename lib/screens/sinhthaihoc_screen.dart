import 'package:flutter/material.dart';
import 'sinhthaihocTN_screen.dart';
import 'sinhthaihocDS_screen.dart';
import 'sinhthaihocTLN_screen.dart';

class sthoc extends StatelessWidget {
  const sthoc({super.key});
  void goToScreen(BuildContext context, String route) {
    Widget screen;

    switch (route) {
      case '4luachon':
        screen = sinhthaihocTN();
        break;
      case 'dungsai':
        screen = sinhthaihocDS();
        break;
      case 'traloingan':
        screen = sinhthaihocTLN();
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
        'label': 'Trắc nghiệm\n4 lựa chọn',
        'icon': Icons.list_alt,
        'color': Color(0xFF66BB6A),
        'route': '4luachon',
      },
      {
        'label': 'Trắc nghiệm\nĐúng / Sai',
        'icon': Icons.task_alt,
        'color': Color(0xFFFFCC80),
        'route': 'dungsai',
      },
      {
        'label': 'Trả lời ngắn',
        'icon': Icons.edit_note,
        'color': Color(0xFF64B5F6),
        'route': 'traloingan',
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
                    topic.containsKey('image')
                        ? Image.asset(
                      topic['image'],
                      height: 110,
                      fit: BoxFit.contain,
                    )
                        : Icon(
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
