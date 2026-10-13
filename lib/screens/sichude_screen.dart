import 'package:flutter/material.dart';
import 'cd1_screen.dart';
import 'cd2_screen.dart';
import 'cd3_screen.dart';
import 'cd4_screen.dart';
import 'cd5_screen.dart';
import 'cd7_screen.dart';

class Chude12 extends StatelessWidget {
  const Chude12({super.key});

  void goToScreen(BuildContext context, String route) {
    Widget screen;

    switch (route) {
      case 'cd1':
        screen = chude1();
        break;
      case 'cd2':
        screen = chude2();
        break;
      case 'cd3':
        screen = chude3();
        break;
      case 'cd4':
        screen = chude4();
        break;
      case 'cd5':
        screen = chude5();
        break;
      case 'cd7':
        screen = chude7();
        break;
      default:
        screen = const Scaffold(body: Center(child: Text('Chủ đề đang cập nhật')));
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
        'label': 'PHẦN 4:\nDI TRUYỀN HỌC',
        'icon': Icons.computer,
        'color': Color(0xFF81D4FA),
        'route': 'cd1',
      },
      {
        'label': 'PHẦN 5:\nTIẾN HÓA',
        'icon': Icons.public,
        'color': Color(0xFF9FE2BF),
        'route': 'cd2',
      },
      {
        'label': 'CHỦ ĐỀ 6:\nSINH THÁI HỌC VÀ MÔI TRƯỜNG',
        'icon': Icons.balance,
        'color': Color(0xFFFFCDD2),
        'route': 'cd3',
      },
      {
        'label': 'CHỦ ĐỀ 4:\nGIẢI QUYẾT VĐ VỚI SỰ TRỢ GIÚP CỦA MT',
        'icon': Icons.save_alt_outlined,
        'color': Color(0xFFFFE0B2),
        'route': 'cd4',
      },
      {
        'label': 'CHỦ ĐỀ 5:\nHƯỚNG NGHIỆP VỚI TIN HỌC',
        'icon': Icons.work_outline,
        'color': Color(0xFFCCE5CC),
        'route': 'cd5',
      },
      {
        'label': 'CHỦ ĐỀ 7:\nỨNG DỤNG TIN HỌC\nĐÚNG / SAI ',
        'icon': Icons.language_outlined,
        'color': Color(0xFFE1BEE7),
        'route': 'cd7',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ôn tập theo chủ đề kiến thức',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFE2F3FB),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Ôn tập Tin học',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '🌟 Để học tốt, hãy ôn mỗi ngày một ít!🌟',
                  style: TextStyle(fontSize: 16, color: Colors.purple),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
