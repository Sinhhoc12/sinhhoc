import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:sinhhoc/utils/dinhdang.dart';
import 'dart:math';
import 'result_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class chude5 extends StatefulWidget {
  const chude5({super.key});

  @override
  State<chude5> createState() => _chude5State();
}

class _chude5State extends State<chude5> {
  List<Map<String, dynamic>> questions = [];
  int currentQuestion = 0;
  List<String?> selectedAnswers = [];
  int correctAnswers = 0;
  bool isLoading = true;
  String tenHocSinh = "Học sinh";
  final String ChuDe = 'Chủ Đề 5';

  @override
  void initState() {
    super.initState();
    fetchQuestions(topicFilter: 'CD5'); //   gọi với chủ đề muốn lọc
    _loadTen();
  }

  Future<void> _loadTen() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        tenHocSinh = prefs.getString('student_name') ?? "Học sinh";
      });
    }
  }

  Future<void> fetchQuestions({String topicFilter = 'CD5'}) async {
    final prefs = await SharedPreferences.getInstance();
    final url =
        'https://sheets.googleapis.com/v4/spreadsheets/1wXBMcZjyQ_p9PRRjSbiKHYr4rmF7jlmqegVSktBQp8k/values/tracnghiem!A1:H?key=AIzaSyDeYVcR3tj4Vg_WSyLEXVZ17qzl4L9EG-A';

    String? allDataCache;

    // 1. Thử tải dữ liệu mới từ Mạng trước
    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        allDataCache = response.body;
        // Tải thành công -> Lưu/Cập nhật vào Cache cho lần sau
        await prefs.setString('TRACNGHIEM_QUESTIONS_CACHE', allDataCache);
      }
    } catch (e) {
      debugPrint('Không có kết nối mạng hoặc lỗi server: $e');
    }

    // 2. Nếu không tải được qua mạng (mất mạng/lỗi), lấy từ Cache ra dùng
    allDataCache ??= prefs.getString('TRACNGHIEM_QUESTIONS_CACHE');

    if (allDataCache == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Không có kết nối Internet và chưa có dữ liệu lưu sẵn trên thiết bị!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }

    try {
      final Map<String, dynamic> jsonData = json.decode(allDataCache);
      final List<dynamic>? values = jsonData['values'];

      if (values == null || values.isEmpty) {
        if (mounted) setState(() => isLoading = false);
        return;
      }

      final List<String> headers = values.first.cast<String>();

      // Chuyển đổi các dòng thành danh sách cấu trúc câu hỏi Map
      final List<Map<String, dynamic>> data = values.skip(1).map((row) {
        final List<dynamic> cells = row.cast<dynamic>();
        final Map<String, dynamic> rowData = {};

        for (int i = 0; i < headers.length; i++) {
          rowData[headers[i]] = i < cells.length ? cells[i].toString().trim() : '';
        }
        return rowData;
      }).toList();

      // Lọc chính xác theo nhãn chủ đề 'CD5'
      final filtered = data.where((q) {
        final topicCell = (q['Topic'] ?? '').toUpperCase();
        return topicCell
            .split(',')
            .map((e) => e.trim())
            .contains(topicFilter.toUpperCase());
      }).toList();

      // Trộn ngẫu nhiên câu hỏi câu hỏi
      filtered.shuffle(Random());

      // Trộn ngẫu nhiên vị trí 4 đáp án A, B, C, D
      for (var q in filtered) {
        List<String> options = [
          q['option1'] ?? '',
          q['option2'] ?? '',
          q['option3'] ?? '',
          q['option4'] ?? '',
        ];

        options.shuffle(Random());

        for (int i = 0; i < 4; i++) {
          q['option${i + 1}'] = options[i];
        }
      }

      if (mounted) {
        setState(() {
          questions = filtered;
          selectedAnswers = List.filled(filtered.length, null);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Lỗi xử lý dữ liệu: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  void nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
      });
    } else {
      int totalCorrect = 0;
      for (int i = 0; i < questions.length; i++) {
        final sel = selectedAnswers[i];
        final correct = questions[i]['Answer'];
        if (sel != null && sel == correct) {
          totalCorrect++;
        }
      }

      correctAnswers = totalCorrect;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            totalQuestions: questions.length,
            correctAnswers: correctAnswers,
            theme: 'default',
            questions: questions,
            userAnswers: selectedAnswers,
            manhinh: 'CD5',
            tenHocSinh: tenHocSinh,
            ChuDe: ChuDe,
          ),
        ),
      );
    }
  }

  void previousQuestion() {
    if (currentQuestion > 0) {
      setState(() {
        currentQuestion--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'CHỦ ĐỀ 5: HƯỚNG NGHIỆP VỚI TIN HỌC',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF8BC34A),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'CHỦ ĐỀ 5: HƯỚNG NGHIỆP VỚI TIN HỌC',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF8BC34A),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'Không có dữ liệu ôn tập thuộc chủ đề này.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color: Color(0xFF1565C0)),
          ),
        ),
      );
    }

    final current = questions[currentQuestion];
    final selectedAnswer = selectedAnswers[currentQuestion];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'CHỦ ĐỀ 5: HƯỚNG NGHIỆP VỚI TIN HỌC',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8BC34A),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Câu ${currentQuestion + 1}/${questions.length}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF689F38), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      MarkdownBody(
                        data: sanitize(current['Question'] ?? ''),
                        styleSheet: markdownStyle,
                        inlineSyntaxes: markdownInlineSyntaxes,
                        builders: markdownBuilders,
                        softLineBreak: true,
                      ),
                      const SizedBox(height: 10),
                      if (current['Image'] != null && current['Image'].toString().isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            current['Image'],
                            height: MediaQuery.of(context).size.height * 0.4,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => const Text(
                              '⚠️ Không tải được hình ảnh',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ...['option1', 'option2', 'option3', 'option4'].map((key) {
                  final isSelected = selectedAnswer == current[key];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected ? const Color(0xFFDCEDC8) : Colors.white,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF689F38) : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                        )
                      ],
                    ),
                    child: RadioListTile<String>(
                      title: MarkdownBody(
                        data: sanitize(current[key] ?? ''),
                        styleSheet: markdownStyle,
                        inlineSyntaxes: markdownInlineSyntaxes,
                        builders: markdownBuilders,
                        softLineBreak: true,
                      ),
                      value: current[key] ?? '',
                      groupValue: selectedAnswer,
                      activeColor: const Color(0xFF689F38),
                      onChanged: (value) {
                        setState(() {
                          selectedAnswers[currentQuestion] = value;
                        });
                      },
                    ),
                  );
                }),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 2,
                      ),
                      onPressed: currentQuestion > 0 ? previousQuestion : null,
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      label: const Text(
                        'Trước',
                        style: TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8BC34A),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 2,
                      ),
                      onPressed: selectedAnswer == null ? null : nextQuestion,
                      icon: const Icon(Icons.navigate_next, color: Colors.white),
                      label: Text(
                        currentQuestion == questions.length - 1 ? 'Hoàn thành' : 'Câu tiếp',
                        style: const TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.upload, color: Colors.white),
                      label: const Text('Nộp bài', style: TextStyle(fontSize: 15, color: Colors.white)),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Center(
                              child: Text(
                                "Xác nhận nộp bài",
                                style: TextStyle(
                                  color: Color(0xFF1565C0),// Đổi màu chữ của tiêu đề thành màu xanh
                                ),
                              ),
                            ),
                            content: const Text(
                              "Bạn có muốn nộp bài bây giờ không?\n\nCác câu chưa trả lời sẽ không được tính",
                              textAlign: TextAlign.center,),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);

                                  List<Map<String, dynamic>> filteredQuestions = [];
                                  List<String?> filteredAnswers = [];
                                  for (int i = 0; i < questions.length; i++) {
                                    if (selectedAnswers[i] != null) {
                                      filteredQuestions.add(questions[i]);
                                      filteredAnswers.add(selectedAnswers[i]);
                                    }
                                  }

                                  int totalCorrect = 0;
                                  for (int i = 0; i < filteredQuestions.length; i++) {
                                    if (filteredAnswers[i] == filteredQuestions[i]['Answer']) {
                                      totalCorrect++;
                                    }
                                  }

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ResultScreen(
                                        totalQuestions: filteredQuestions.length,
                                        correctAnswers: totalCorrect,
                                        theme: 'default',
                                        questions: filteredQuestions,
                                        userAnswers: filteredAnswers,
                                        tenHocSinh: tenHocSinh,
                                        manhinh: 'CD5',
                                        ChuDe: ChuDe,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text("Đồng ý"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}