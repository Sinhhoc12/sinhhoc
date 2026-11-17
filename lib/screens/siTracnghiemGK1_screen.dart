import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:sinhhoc/utils/dinhdang.dart';
import 'dart:math'; // thêm để shuffle
import 'siresult_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class siTracnghiemGK1 extends StatefulWidget {
  const siTracnghiemGK1({super.key});

  @override
  State<siTracnghiemGK1> createState() => _siTracnghiemGK1State();
}

class _siTracnghiemGK1State extends State<siTracnghiemGK1> {
  List<Map<String, dynamic>> questions = [];
  List<String?> selectedAnswers = [];
  int correctAnswers = 0;
  bool isLoading = true;
  String tenHocSinh = "Học sinh";

  @override
  void initState() {
    super.initState();
    fetchQuestions(topicFilter: 'GK1'); // 🔹 gọi với chủ đề muốn lọc
    _loadTen();
  }
  Future<void> _loadTen() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      tenHocSinh = prefs.getString('student_name') ?? "Học sinh";
    });
  }
  Future<void> fetchQuestions({String topicFilter = 'GK1'}) async {
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
  void _xacNhanNopBai() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận nộp bài"),
        content: const Text(
            "Bạn có muốn hoàn thành bài?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Quay lại")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              List<Map<String, dynamic>> filteredQuestions = [];
              List<String?> filteredAnswers = [];
              for (int i = 0; i < questions.length; i++) {
                if (selectedAnswers[i] != null) {
                  final qWithNumber = Map<String, dynamic>.from(questions[i]);
                  qWithNumber['cau_so'] = i + 1;
                  filteredQuestions.add(qWithNumber);
                  filteredAnswers.add(selectedAnswers[i]);
                }
              }

              int totalCorrect = 0;
              for (int i = 0; i < filteredQuestions.length; i++) {
                if (filteredAnswers[i] == filteredQuestions[i]['Answer']) {
                  totalCorrect++;
                }
              }

              correctAnswers = totalCorrect;

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
                    manhinh: 'GK1',
                  ),
                ),
              );
            },
            child: const Text("Nộp bài"),
          ),
        ],
      ),
    );
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Ôn tập: Kiểm tra giữa kì 1',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF1E88E5),
          foregroundColor: Colors.white,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: questions.length,
          itemBuilder: (context, index) {
            return _buildQuestionCard(questions[index], index);
          },
        ),
        bottomNavigationBar: isLoading || questions.isEmpty
            ? null
            : SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _xacNhanNopBai,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                icon: const Icon(Icons.upload, color: Colors.white),
                label: const Text(
                  "NỘP BÀI",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      );
    }
  Widget _buildQuestionCard(Map<String, dynamic> data, int idx) {
    const optionLetters = ['A', 'B', 'C', 'D'];

    return StatefulBuilder(
      builder: (context, setLocalState) {
        final selectedAnswer = selectedAnswers[idx];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF1E88E5), width: 1.2),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFF8FBFF),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarkdownBody(
                data: sanitize("**Câu ${idx + 1}:** ${data['Question'] ?? ''}"),
                styleSheet: markdownStyle,
                inlineSyntaxes: markdownInlineSyntaxes,
                builders: markdownBuilders,
                softLineBreak: true,
              ),
              if (data['Image'] != null && data['Image'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        data['Image'],
                        height: MediaQuery.of(context).size.height * 0.35,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Text(
                          '⚠️ Không tải được hình ảnh',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 6),
              for (int i = 1; i <= 4; i++)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: selectedAnswer == data['option$i']
                        ? const Color(0xFFE3F2FD)
                        : Colors.white,
                    border: Border.all(
                      color: selectedAnswer == data['option$i']
                          ? const Color(0xFF1E88E5)
                          : Colors.grey.shade300,
                      width: selectedAnswer == data['option$i'] ? 1.8 : 1,
                    ),
                  ),
                  child: RadioListTile<String>(
                    title: MarkdownBody(
                      data: sanitize("**${optionLetters[i - 1]}.** ${data['option$i'] ?? ''}"),
                      styleSheet: markdownStyle,
                      inlineSyntaxes: markdownInlineSyntaxes,
                      builders: markdownBuilders,
                      softLineBreak: true,
                    ),
                    value: data['option$i'] ?? '',
                    groupValue: selectedAnswer,
                    activeColor: const Color(0xFF1E88E5),
                    onChanged: (value) {
                      setLocalState(() {
                        selectedAnswers[idx] = value;
                      });
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
