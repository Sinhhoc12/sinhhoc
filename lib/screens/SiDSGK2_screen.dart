import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'dart:convert';
import 'Siketqua_DS.dart';
import 'package:sinhhoc/utils/dinhdang.dart';

class dungsaiGK2 extends StatefulWidget {
  const dungsaiGK2({super.key});

  @override
  State<dungsaiGK2> createState() => _dungsaiGK2State();
}
class _dungsaiGK2State extends State<dungsaiGK2> {
  List<Map<String, dynamic>> questions = [];
  int currentQuestion = 0;
  List<List<bool?>> userAnswers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final url =
        'https://sheets.googleapis.com/v4/spreadsheets/1Ekq-wK3bN7wCt9o39ad6iu02mQxXb5njt2cn4hEtUxI/values/dungsai!A1:K?key=AIzaSyDlgPD7RfwcpS3GnesNhK06dfQTPs0raCg';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> values = jsonData['values'];

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
            .contains('GK2');
      }).toList();

      filtered.shuffle(Random());
      setState(() {
        questions = filtered;
        userAnswers = List.generate(filtered.length, (_) => [null, null, null, null]);
        isLoading = false;
      });
    } else {
      throw Exception('Không tải được dữ liệu từ Google Sheets API');
    }
  }

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

  // Bổ sung: submitPartial = true để nộp các câu đã trả lời
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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => siResultDungsai(
          questions: filteredQuestions,
          userAnswers: filteredAnswers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final q = questions[currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ôn tập: Kiểm tra giữa kì 2',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E88E5),
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
                      MarkdownBody(
                        data: sanitize(q['phuongan${i + 1}'] ?? ''),
                        styleSheet: markdownStyle,
                        inlineSyntaxes: markdownInlineSyntaxes,
                        builders: markdownBuilders,
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
                    onPressed: previousQuestion,
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
                      currentQuestion == questions.length - 1 ? 'Kết thúc' : 'Câu Tiếp →',
                    ),
                  ),
                  // 🔹 Nút nộp bài tùy ý
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Xác nhận nộp bài"),
                          content: const Text(
                              "Bạn có chắc muốn nộp bài ngay bây giờ không?\nCác câu chưa trả lời hoàn chỉnh sẽ không được tính"),
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
