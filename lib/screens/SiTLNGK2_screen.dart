import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:sinhhoc/utils/dinhdang.dart';
import 'TLNresult_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TraLoiNganScreenGK2 extends StatefulWidget {
  const TraLoiNganScreenGK2({super.key});

  @override
  State<TraLoiNganScreenGK2> createState() => _TraLoiNganScreenGK2State();
}

class _TraLoiNganScreenGK2State extends State<TraLoiNganScreenGK2> {
  List<Map<String, dynamic>> questions = [];

  int currentQuestion = 0;

  List<String> selectedAnswers = [];

  int correctAnswers = 0;

  bool isLoading = true;

  String tenHocSinh = "Học sinh";

  final List<TextEditingController> boxControllers =
  List.generate(4, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    fetchQuestions(topicFilter: 'GK2');
    _loadTen();
  }

  Future<void> _loadTen() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      tenHocSinh = prefs.getString('student_name') ?? "Học sinh";
    });
  }

  Future<void> fetchQuestions({String topicFilter = 'GK2'}) async {
    final response = await http.get(
      Uri.parse(
        'https://sheets.googleapis.com/v4/spreadsheets/1Ekq-wK3bN7wCt9o39ad6iu02mQxXb5njt2cn4hEtUxI/values/traloingan!A1:E?key=AIzaSyDlgPD7RfwcpS3GnesNhK06dfQTPs0raCg',
      ),
    );

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

      final List<Map<String, dynamic>> data =
      values.skip(1).map((row) {
        final List<dynamic> cells = row.cast<dynamic>();

        final Map<String, dynamic> rowData = {};

        for (int i = 0; i < headers.length; i++) {
          rowData[headers[i]] =
          i < cells.length ? cells[i].toString().trim() : '';
        }

        return rowData;
      }).toList();

      final filtered =
      data.where((q) {
        final topicCell = (q['Topic'] ?? '').toUpperCase();

        return topicCell
            .split(',')
            .map((e) => e.trim())
            .contains(topicFilter.toUpperCase());
      }).toList();

      setState(() {
        questions = filtered;

        selectedAnswers = List.filled(filtered.length, '');

        isLoading = false;
      });
    } else {
      throw Exception('Không tải được dữ liệu');
    }
  }

  void clearBoxes() {
    for (var c in boxControllers) {
      c.clear();
    }
  }

  void loadCurrentAnswer() {
    clearBoxes();

    String ans = selectedAnswers[currentQuestion];

    for (int i = 0; i < ans.length && i < 4; i++) {
      boxControllers[i].text = ans[i];
    }
  }

  void nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;

        loadCurrentAnswer();
      });
    } else {
      int totalCorrect = 0;

      for (int i = 0; i < questions.length; i++) {
        final sel = selectedAnswers[i].trim();

        final correct = questions[i]['Answer'].toString().trim();

        if (sel == correct) {
          totalCorrect++;
        }
      }

      correctAnswers = totalCorrect;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => tlnResultScreen(
            totalQuestions: questions.length,
            correctAnswers: correctAnswers,
            theme: 'default',
            questions: questions,
            userAnswers: selectedAnswers,
            manhinh: 'GK2',
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

        loadCurrentAnswer();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Đang tải...'),
          backgroundColor: const Color(0xFF1E88E5),
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
          'Ôn tập: Kiểm tra giữa kì 2',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E88E5),
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
                    color: const Color(0xFFF8FBFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF1E88E5),
                      width: 1.5,
                    ),
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

                      if (current['Image'] != null &&
                          current['Image'].toString().isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),

                          child: Image.network(
                            current['Image'],

                            height:
                            MediaQuery.of(context).size.height * 0.4,

                            fit: BoxFit.contain,

                            loadingBuilder: (
                                context,
                                child,
                                progress,
                                ) {
                              if (progress == null) return child;

                              return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              );
                            },

                            errorBuilder:
                                (context, error, stackTrace) => const Text(
                              '⚠️ Không tải được hình ảnh',
                              style: TextStyle(
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "Nhập đáp án",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: List.generate(4, (index) {
                    return Container(
                      width: 58,
                      height: 70,

                      margin: const EdgeInsets.symmetric(horizontal: 6),

                      child: TextField(
                        controller: boxControllers[index],

                        keyboardType: TextInputType.number,

                        textAlign: TextAlign.center,

                        maxLength: 1,

                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),

                        decoration: InputDecoration(
                          counterText: "",

                          filled: true,

                          fillColor: const Color(0xFFE3F2FD),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),

                            borderSide: const BorderSide(
                              color: Color(0xFF90CAF9),
                              width: 2,
                            ),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),

                            borderSide: const BorderSide(
                              color: Color(0xFF1976D2),
                              width: 2.5,
                            ),
                          ),
                        ),

                        onChanged: (value) {

                          // ✅ Không cho nhập ô sau khi ô trước còn trống
                          if (index > 0 &&
                              boxControllers[index - 1].text.isEmpty) {

                            boxControllers[index].clear();

                            FocusScope.of(context).previousFocus();

                            return;
                          }

                          // ✅ Tự chuyển sang ô tiếp theo
                          if (value.isNotEmpty && index < 3) {
                            FocusScope.of(context).nextFocus();
                          }

                          String answer =
                          boxControllers.map((e) => e.text).join();

                          selectedAnswers[currentQuestion] = answer;

                          setState(() {});
                        },
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),

                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 18,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),

                        elevation: 2,
                      ),

                      onPressed:
                      currentQuestion > 0
                          ? previousQuestion
                          : null,

                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),

                      label: const Text(
                        'Câu trước',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),

                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 18,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),

                        elevation: 2,
                      ),

                      onPressed:
                      selectedAnswer.isEmpty
                          ? null
                          : nextQuestion,

                      icon: const Icon(
                        Icons.navigate_next,
                        color: Colors.white,
                      ),

                      label: Text(
                        currentQuestion == questions.length - 1
                            ? 'Hoàn thành'
                            : 'Câu tiếp',

                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,

                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 18,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),

                        elevation: 2,
                      ),

                      icon: const Icon(
                        Icons.upload,
                        color: Colors.white,
                      ),

                      label: const Text(
                        'Nộp bài',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),

                      onPressed: () {
                        showDialog(
                          context: context,

                          builder:
                              (context) => AlertDialog(
                            title: const Text(
                              "Xác nhận nộp bài",
                            ),

                            content: const Text(
                              "Bạn có muốn nộp bài bây giờ không?\nCác câu chưa trả lời sẽ không được tính",
                            ),

                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.pop(context),

                                child: const Text("Hủy"),
                              ),

                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);

                                  List<Map<String, dynamic>>
                                  filteredQuestions = [];

                                  List<String> filteredAnswers = [];

                                  for (
                                  int i = 0;
                                  i < questions.length;
                                  i++
                                  ) {
                                    if (selectedAnswers[i].isNotEmpty) {
                                      filteredQuestions.add(
                                        questions[i],
                                      );

                                      filteredAnswers.add(
                                        selectedAnswers[i],
                                      );
                                    }
                                  }

                                  int totalCorrect = 0;

                                  for (
                                  int i = 0;
                                  i < filteredQuestions.length;
                                  i++
                                  ) {
                                    if (filteredAnswers[i]
                                        .trim() ==
                                        filteredQuestions[i]['Answer']
                                            .toString()
                                            .trim()) {
                                      totalCorrect++;
                                    }
                                  }

                                  Navigator.pushReplacement(
                                    context,

                                    MaterialPageRoute(
                                      builder:
                                          (context) => tlnResultScreen(
                                        totalQuestions:
                                        filteredQuestions.length,

                                        correctAnswers:
                                        totalCorrect,

                                        theme: 'default',

                                        questions:
                                        filteredQuestions,

                                        userAnswers:
                                        filteredAnswers,

                                        tenHocSinh:
                                        tenHocSinh,

                                        manhinh: 'GK2',
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