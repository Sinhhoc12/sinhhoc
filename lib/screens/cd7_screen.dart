import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'ketqua_DS.dart';
import 'package:sinhhoc/utils/dinhdang.dart';
import 'package:http/http.dart' as http;

class chude7 extends StatefulWidget {
  const chude7({super.key});

  @override
  State<chude7> createState() => _chude7State();
}

class _chude7State extends State<chude7> {
  List<Map<String, dynamic>> questions = [];
  int currentQuestion = 0;
  List<List<bool?>> userAnswers = [];
  bool isLoading = true;
  String studentName = "Học sinh";

  @override
  void initState() {
    super.initState();
    fetchQuestions();
    _loadStudentName();
  }

  Future<void> _loadStudentName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      studentName = prefs.getString('student_name') ?? 'Học sinh';
    });
  }

  Future<void> fetchQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    final url =
        'https://sheets.googleapis.com/v4/spreadsheets/1wXBMcZjyQ_p9PRRjSbiKHYr4rmF7jlmqegVSktBQp8k/values/dungsai!A1:K?key=AIzaSyDeYVcR3tj4Vg_WSyLEXVZ17qzl4L9EG-A';

    String? allDataCache;

    // 1. Thử tải dữ liệu mới từ Mạng trước
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        allDataCache = response.body;
        // Tải thành công -> Lưu/Cập nhật vào Cache cho lần sau
        await prefs.setString('DUNGSAI_QUESTIONS_CACHE', allDataCache);
      }
    } catch (e) {
      debugPrint('Không có kết nối mạng hoặc lỗi server: $e');
    }

    // 2. Nếu không tải được qua mạng (mất mạng/lỗi), lấy từ Cache ra dùng
    allDataCache ??= prefs.getString('DUNGSAI_QUESTIONS_CACHE');

    // 3. Nếu cả Mạng và Cache đều không có (lần đầu tải app mà không có mạng)
    if (allDataCache == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Không có kết nối Internet và chưa có dữ liệu lưu sẵn trên thiết bị!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
      return;
    }


    // 3. Đã sửa: Giải mã dữ liệu trực tiếp từ biến allDataCache
    final Map<String, dynamic> jsonData = json.decode(allDataCache);
    final List<dynamic> values = jsonData['values'] ?? [];

    if (values.isEmpty) {
      setState(() {
        questions = [];
        userAnswers = [];
        isLoading = false;
      });
      return;
    }

    final List<String> headers = values.first.cast<String>();
    final List<Map<String, dynamic>> data = values.skip(1).map((row) {
      final List<dynamic> cells = row;
      final Map<String, dynamic> rowData = {};
      for (int i = 0; i < headers.length; i++) {
        rowData[headers[i]] = i < cells.length ? cells[i].toString().trim() : '';
      }
      return rowData;
    }).toList();

    final filtered = data.where((q) {
      final topicCell = (q['loaichude'] ?? '').toUpperCase();
      return topicCell
          .split(',')
          .map((e) => e.trim())
          .contains('CD7');
    }).toList();

    filtered.shuffle(Random());
    setState(() {
      questions = filtered;
      userAnswers = List.generate(filtered.length, (_) => [null, null, null, null]);
      isLoading = false;
    });
  } // Dấu đóng hàm chuẩn ở đây

  void nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
      });
    }
  }

  void previousQuestion() {
    if (currentQuestion > 0) {
      setState(() {
        currentQuestion--;
      });
    }
  }

  void finishQuiz({bool submitPartial = false}) {
    List<Map<String, dynamic>> filteredQuestions = questions;
    List<List<bool?>> filteredAnswers = userAnswers;

    if (submitPartial) {
      filteredQuestions = [];
      filteredAnswers = [];
      for (int i = 0; i < questions.length; i++) {
        if (!userAnswers[i].contains(null)) {
          filteredQuestions.add(questions[i]);
          filteredAnswers.add(userAnswers[i]);
        }
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultDungsai(
          questions: filteredQuestions,
          userAnswers: filteredAnswers,
          previousScreen: widget,
          chuDe: 'Chủ đề Ứng Dụng Tin Học - Đúng/Sai',
        ),
      ),
    ).then((_) {
      setState(() {
        currentQuestion = 0;
        userAnswers = List.generate(questions.length, (_) => [null, null, null, null]);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Trường hợp không có dữ liệu để hiển thị
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('CHỦ ĐỀ : ỨNG DỤNG TIN HỌC',
            style: TextStyle(fontWeight: FontWeight.bold,),
          ),
          backgroundColor: Colors.green.shade500,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Không có dữ liệu ôn tập thuộc chủ đề này.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1565C0)),
            ),
          ),
        ),
      );
    }

    final q = questions[currentQuestion];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('CHỦ ĐỀ : ỨNG DỤNG TIN HỌC',
          style: TextStyle(fontWeight: FontWeight.bold,),
        ),
        backgroundColor: Colors.green.shade500,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MarkdownBody(
                      data: '**Câu ${currentQuestion + 1}/${questions.length}:**\n${sanitize(q['cauhoi'] ?? "")}',
                      styleSheet: markdownStyle,
                      inlineSyntaxes: markdownInlineSyntaxes,
                      builders: markdownBuilders,
                    ),
                    if (q['Image'] != null && q['Image'].toString().isNotEmpty)
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            q['Image'],
                            height: MediaQuery.of(context).size.height * 0.4,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Padding(
                                padding: EdgeInsets.all(3.0),
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => const Text(
                              '⚠️ Không tải được hình ảnh',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              for (int i = 0; i < 4; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${String.fromCharCode(97 + i)}) ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          Expanded(
                            child: MarkdownBody(
                              data: sanitize(q['phuongan${i + 1}'] ?? ''),
                              softLineBreak: true,
                              styleSheet: markdownStyle,
                              inlineSyntaxes: markdownInlineSyntaxes,
                              builders: markdownBuilders,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ToggleButtons(
                        isSelected: [
                          userAnswers[currentQuestion][i] == true,
                          userAnswers[currentQuestion][i] == false
                        ],
                        onPressed: (index) {
                          setState(() {
                            userAnswers[currentQuestion][i] = index == 0;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        borderColor: Colors.teal,
                        selectedBorderColor: Colors.teal,
                        fillColor: userAnswers[currentQuestion][i] == true
                            ? Colors.green
                            : userAnswers[currentQuestion][i] == false
                            ? Colors.red
                            : Colors.transparent,
                        color: Colors.black,
                        selectedColor: Colors.white,
                        children: const [Text('Đúng'), Text('Sai')],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: currentQuestion > 0 ? previousQuestion : null,
                    child: const Text('← Trước'),
                  ),
                  ElevatedButton(
                    onPressed: userAnswers[currentQuestion].contains(null)
                        ? null
                        : (currentQuestion == questions.length - 1
                        ? finishQuiz
                        : nextQuestion),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: userAnswers[currentQuestion].contains(null)
                          ? Colors.grey
                          : Colors.greenAccent,
                    ),
                    child: Text(
                      currentQuestion == questions.length - 1 ? 'Kết Thúc' : 'Câu Tiếp →',
                    ),
                  ),
                  ElevatedButton.icon(
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
                              "Bạn có chắc muốn nộp bài ngay bây giờ không?\n\nCác câu chưa trả lời hoàn chỉnh sẽ không được tính"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Hủy"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                finishQuiz(submitPartial: true);
                              },
                              child: const Text("Đồng ý"),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                    icon: const Icon(Icons.upload, color: Colors.white),
                    label: const Text(
                      'Nộp bài',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}