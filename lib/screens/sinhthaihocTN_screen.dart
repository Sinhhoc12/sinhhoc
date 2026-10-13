import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:sinhhoc/utils/dinhdang.dart';
import 'dart:math'; // thêm để shuffle
import 'siresult_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class sinhthaihocTN extends StatefulWidget {
  const sinhthaihocTN({super.key});

  @override
  State<sinhthaihocTN> createState() => _sinhthaihocTNState();
}

class _sinhthaihocTNState extends State<sinhthaihocTN> {
  List<Map<String, dynamic>> questions = [];
  int currentQuestion = 0;
  List<String?> selectedAnswers = [];
  int correctAnswers = 0;
  bool isLoading = true;
  String tenHocSinh = "Học sinh";

  @override
  void initState() {
    super.initState();
    fetchQuestions(topicFilter: 'ST'); // 🔹 gọi với chủ đề muốn lọc
    _loadTen();
  }
  Future<void> _loadTen() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      tenHocSinh = prefs.getString('student_name') ?? "Học sinh";
    });
  }
  Future<void> fetchQuestions({String topicFilter = 'ST'}) async {
    final response = await http.get(Uri.parse(
        'https://sheets.googleapis.com/v4/spreadsheets/1Ekq-wK3bN7wCt9o39ad6iu02mQxXb5njt2cn4hEtUxI/values/tracnghiem!A1:H?key=AIzaSyDlgPD7RfwcpS3GnesNhK06dfQTPs0raCg'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> values = jsonData['values'];

      if (values.isEmpty) {
        setState(() {
          questions = [];
          selectedAnswers = [];
          isLoading = false;
        });
        return;
      }

      final List<String> headers = values.first.cast<String>();

      final List<Map<String, dynamic>> data = values.skip(1).map((row) {
        final List<dynamic> cells = row.cast<dynamic>();
        final Map<String, dynamic> rowData = {};
        for (int i = 0; i < headers.length; i++) {
          rowData[headers[i]] = i < cells.length ? cells[i].toString().trim() : '';
        }
        return rowData;
      }).toList();

      // 🔹 Lọc theo Topic, trim & ignore case
      final filtered = data.where((q) {
        final topicCell = (q['Topic'] ?? '').toUpperCase();
        // tách theo dấu phẩy, trim khoảng trắng, kiểm tra có chứa topicFilter
        return topicCell
            .split(',')
            .map((e) => e.trim())
            .contains(topicFilter.toUpperCase());
      }).toList();

      // 🔹 Xáo trộn danh sách câu hỏi
      filtered.shuffle(Random());

      // 🔹 Xáo trộn 4 đáp án cho từng câu
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

      setState(() {
        questions = filtered;
        selectedAnswers = List.filled(filtered.length, null);
        isLoading = false;
      });
    } else {
      throw Exception('Không tải được dữ liệu');
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
            questions: questions,           // ✅ truyền toàn bộ câu hỏi
            userAnswers: selectedAnswers, // ✅ truyền đáp án học sinh chọn
            manhinh: 'ST',
            tenHocSinh: tenHocSinh,
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
            'Ôn tập: Chủ đề SINH THÁI HỌC',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color(0xFF1E88E5),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final current = questions[currentQuestion];
    final selectedAnswer = selectedAnswers[currentQuestion];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Ôn tập: Chủ đề SINH THÁI HỌC',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF1E88E5),
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
                    color: Color(0xFF0D47A1),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8FBFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF1E88E5), width: 1.5),
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
                      // ✅ Thêm phần kiểm tra & hiển thị ảnh
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
                      color: isSelected ? Color(0xFFF8FBFF) : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? Color(0xFF1E88E5)
                            : Colors.grey.shade300,
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
                      activeColor: Color(0xFF1E88E5),
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
                    // Nút quay lại
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1976D2),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 2,
                      ),
                      onPressed: currentQuestion > 0 ? previousQuestion : null,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      label: const Text(
                        'Câu trước',
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
                    // Nút tiếp / hoàn thành
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1976D2),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 2,
                      ),
                      onPressed: selectedAnswer == null ? null : nextQuestion,
                      icon: const Icon(Icons.navigate_next, color: Colors.white),
                      label: Text(
                        currentQuestion == questions.length - 1 ? 'Hoàn thành' : 'Câu tiếp',
                        style: const TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
                    // Nút Nộp bài 🔹 đây là phần bổ sung
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
                            title: const Text("Xác nhận nộp bài"),
                            content: const Text(
                                "Bạn có muốn nộp bài bây giờ không?\nCác câu chưa trả lời sẽ không được tính"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);

                                  // 🔹 Lọc các câu đã trả lời
                                  List<Map<String, dynamic>> filteredQuestions = [];
                                  List<String?> filteredAnswers = [];
                                  for (int i = 0; i < questions.length; i++) {
                                    if (selectedAnswers[i] != null) {
                                      filteredQuestions.add(questions[i]);
                                      filteredAnswers.add(selectedAnswers[i]);
                                    }
                                  }

                                  // 🔹 Tính số câu đúng
                                  int totalCorrect = 0;
                                  for (int i = 0; i < filteredQuestions.length; i++) {
                                    if (filteredAnswers[i] == filteredQuestions[i]['Answer']) {
                                      totalCorrect++;
                                    }
                                  }

                                  // 🔹 Chuyển sang ResultScreen
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
                                        manhinh: 'ST',
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
