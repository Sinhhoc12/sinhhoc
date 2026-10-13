import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'sigk1_screen.dart';
import 'sick1_screen.dart';
import 'sigk2_screen.dart';
import 'sick2_screen.dart';
import 'SiTN10_screen.dart';
import 'Si11_screen.dart';
import 'Si12_screen.dart';
import 'luyende_screen.dart';

class sinhhoc extends StatefulWidget {
  const sinhhoc({super.key});

  @override
  State<sinhhoc> createState() => _sinhhocState();
}

class _sinhhocState extends State<sinhhoc> {
  int _selectedIndex = 0;

  // Giữ nguyên y hệt danh sách gốc, kể cả 2 mục cùng route 'Si11'.
  final List<Map<String, dynamic>> topics = const [
    {
      'title': '',
      'tag': 'GIỮA KỲ 1',
      'tagColor': Color(0xFFC2185B),
      'image': 'assets/images/ktgk1.png',
      'route': 'Sigk1',
    },
    {
      'title': '',
      'tag': 'CUỐI KỲ 1',
      'tagColor': Color(0xFF1976D2),
      'image': 'assets/images/ktck1.png',
      'route': 'Sick1',
    },
    {
      'title': '',
      'tag': 'GIỮA KỲ 2',
      'tagColor': Color(0xFF9C71D2),
      'image': 'assets/images/ktgk2.png',
      'route': 'Sigk2',
    },
    {
      'title': '',
      'tag': 'CUỐI KỲ 2',
      'tagColor': Color(0xFFF06A58),
      'image': 'assets/images/ktck2.png',
      'route': 'Sick2',
    },
    {
      'title': '',
      'tag': 'SINH HỌC 10',
      'tagColor': Color(0xFF388E3C),
      'image': 'assets/images/si10.png',
      'route': 'Si10',
    },
    {
      'title': '',
      'tag': 'SINH HỌC 11',
      'tagColor': Color(0xFF388E3C),
      'image': 'assets/images/si11.png',
      'route': 'Si11',
    },
    {
      'title': '',
      'tag': 'SINH HỌC 12',
      'tagColor': Color(0xFF388E3C),
      'image': 'assets/images/si12.png',
      'route': 'Si12',
    },
    {
      'title': '',
      'tag': 'LUYỆN ĐỀ TNTHPT',
      'tagColor': Color(0xFF388E3C),
      'desc': 'Bộ đề luyện thi tốt nghiệp THPT',
      'image': 'assets/images/ld.png',
      'route': 'luyende',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dataGoogleSheet();
    });
  }

  /// Gọi 1 API Sheets bất kỳ và cache kết quả nếu thành công.
  /// Được dùng chung cho cả 2 sheet (tracnghiem, dungsai) để tránh lặp code.
  Future<void> _fetchAndCache(
      SharedPreferences prefs,
      String url,
      String cacheKey,
      String label,
      ) async {
    try {
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        await prefs.setString(cacheKey, res.body);
      }
    } catch (e) {
      debugPrint("⚠️ Lỗi tải $label: $e");
    }
  }

  Future<void> _dataGoogleSheet() async {
    final prefs = await SharedPreferences.getInstance();
    const spreadsheetId = '1Ekq-wK3bN7wCt9o39ad6iu02mQxXb5njt2cn4hEtUxI';
    const apiKey = 'AIzaSyDlgPD7RfwcpS3GnesNhK06dfQTPs0raCg';

    // 2 request độc lập nhau -> chạy song song thay vì tuần tự để giảm
    // tổng thời gian chờ (đặc biệt khi mạng chậm, gần chạm timeout 10s).
    await Future.wait([
      _fetchAndCache(
        prefs,
        'https://sheets.googleapis.com/v4/spreadsheets/$spreadsheetId/values/tracnghiem!A1:H?key=$apiKey',
        'TRACNGHIEM_QUESTIONS_CACHE',
        'Trắc nghiệm',
      ),
      _fetchAndCache(
        prefs,
        'https://sheets.googleapis.com/v4/spreadsheets/$spreadsheetId/values/dungsai!A1:K?key=$apiKey',
        'DUNGSAI_QUESTIONS_CACHE',
        'Đúng Sai',
      ),
    ]);
  }

  Future<void> goToScreen(BuildContext context, String route, [int? menuIndex]) async {
    if (menuIndex != null) {
      setState(() {
        _selectedIndex = menuIndex;
      });
    }

    Widget screen;
    switch (route) {
      case 'Sigk1':
        screen = const Sigk1();
        break;
      case 'Sick1':
        screen = const Sick1();
        break;
      case 'Sigk2':
        screen = const Sigk2();
        break;
      case 'Sick2':
        screen = const Sick2();
        break;
      case 'Si10':
        screen = const SiTN10();
        break;
      case 'Si11':
        screen = const Si11();
        break;
      case 'Si12':
        screen = const Si12();
        break;
      case 'luyende':
        screen = const LuyendeSinh();
        break;
      default:
        screen = const Scaffold(
          body: Center(child: Text('Chủ đề đang cập nhật')),
        );
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBF6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Giữ nguyên như code gốc (không xoá, dù hiện không có nội dung).
                ],
              ),
              const SizedBox(height: 8),
              const Column(
                children: [
                  Text(
                    'Chào mừng bạn đến với',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.eco, color: Color(0xFF4CAF50), size: 26),
                      SizedBox(width: 8),
                      Text(
                        'Ôn Tập Sinh Học',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.eco, color: Color(0xFF4CAF50), size: 26),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Chọn nội dung bạn muốn ôn tập',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final int crossAxisCount;
                      final double itemHeight;

                      if (constraints.maxWidth < 600) {
                        crossAxisCount = 2;
                        itemHeight = 180;
                      } else if (constraints.maxWidth < 900) {
                        crossAxisCount = 3;
                        itemHeight = 200;
                      } else {
                        crossAxisCount = 4;
                        itemHeight = 210;
                      }

                      final bool isMobile = constraints.maxWidth < 600;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: topics.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          mainAxisExtent: itemHeight,
                        ),
                        itemBuilder: (context, index) {
                          final item = topics[index];
                          return _TopicCard(
                            key: ValueKey(item['route']),
                            item: item,
                            isMobile: isMobile,
                            onTap: () => goToScreen(context, item['route'], item['menuIndex']),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tách thẻ chủ đề ra StatelessWidget riêng
class _TopicCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isMobile;
  final VoidCallback onTap;

  const _TopicCard({
    super.key,
    required this.item,
    required this.isMobile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        hoverColor: const Color(0xFFE8F5E9),
        splashColor: const Color(0xFFC8E6C9),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0EAD7), width: 1.2),
          ),
          padding: EdgeInsets.all(isMobile ? 10 : 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(
                  item['image'],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.eco,
                    size: 40,
                    color: Color(0xFF81C784),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (item['tag'] != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: item['tagColor'],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item['tag'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 10 : 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Text(
                item['title'].replaceAll('\n', ' '),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isMobile ? 12.5 : 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}