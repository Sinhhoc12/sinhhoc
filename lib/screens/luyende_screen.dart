import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:http/http.dart' as http;
import 'kqldSinh_screen.dart'; // Màn hình hiển thị kết quả
import 'package:sinhhoc/utils/dinhdang.dart'; // Import tiện ích định dạng của dự án

class LuyendeSinh extends StatefulWidget {
  const LuyendeSinh({super.key});

  @override
  State<LuyendeSinh> createState() => _LuyendeSinhState();
}

class _LuyendeSinhState extends State<LuyendeSinh> {
  List<Map<String, dynamic>> allQuestions = [];
  bool isLoading = true;
  String? errorMessage;

  // Lưu trữ câu trả lời của người dùng
  List<dynamic> userAnswers = [];

  // Quản lý 4 ô controller và FocusNode cho từng câu hỏi Trả lời ngắn theo index
  final Map<int, List<TextEditingController>> _shortAnswerControllers = {};
  final Map<int, List<FocusNode>> _shortAnswerFocusNodes = {};

  // Dùng chung 1 instance Random thay vì tạo mới ở mỗi lần shuffle
  // (Random() mới mỗi lần gọi không sai, nhưng tạo object thừa không cần thiết).
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ cho các controller và FocusNode
    for (var listControllers in _shortAnswerControllers.values) {
      for (var controller in listControllers) {
        controller.dispose();
      }
    }
    for (var listNodes in _shortAnswerFocusNodes.values) {
      for (var node in listNodes) {
        node.dispose();
      }
    }
    super.dispose();
  }

  // Hàm lọc và rút ngẫu nhiên câu hỏi theo chủ đề (Xử lý chữ hoa/thường và khoảng trắng)
  List<Map<String, dynamic>> getRandomByTopic(
      List<Map<String, dynamic>> sourceList, List<String> possibleKeys, String topicValue, int count) {
    var filtered = sourceList.where((e) {
      String? foundKey;
      for (var k in possibleKeys) {
        if (e.containsKey(k)) {
          foundKey = k;
          break;
        }
      }
      if (foundKey == null) return false;

      String rawVal = (e[foundKey] ?? '').toString().trim().toLowerCase();
      String targetVal = topicValue.trim().toLowerCase();
      return rawVal == targetVal;
    }).toList();

    filtered.shuffle(_rng);
    return filtered.take(count).toList();
  }

  /// Chuyển 1 sheet Google Sheets (dạng {"values": [[header...], [row...], ...]})
  /// thành List<Map<String, dynamic>> với key là tên cột.
  /// Trước đây đoạn này được lặp lại y hệt 3 lần cho MCQ/TF/SA — gộp lại đây
  /// để giảm trùng lặp, kết quả trả về giống hệt logic gốc.
  List<Map<String, dynamic>> _parseSheetValues(String responseBody) {
    final data = json.decode(responseBody);
    final values = data['values'] as List;
    final headers = values.first.cast<String>();
    return values.skip(1).map((row) {
      final cells = row as List;
      final Map<String, dynamic> item = {};
      for (int i = 0; i < headers.length; i++) {
        item[headers[i]] = i < cells.length ? cells[i].toString().trim() : '';
      }
      return item;
    }).toList();
  }

  Future<void> fetchAllData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final urlMCQ =
          'https://sheets.googleapis.com/v4/spreadsheets/1Ekq-wK3bN7wCt9o39ad6iu02mQxXb5njt2cn4hEtUxI/values/tracnghiem!A1:H?key=AIzaSyDlgPD7RfwcpS3GnesNhK06dfQTPs0raCg';

      final urlTF =
          'https://sheets.googleapis.com/v4/spreadsheets/1Ekq-wK3bN7wCt9o39ad6iu02mQxXb5njt2cn4hEtUxI/values/dungsai!A1:K?key=AIzaSyDlgPD7RfwcpS3GnesNhK06dfQTPs0raCg';

      final urlSA =
          'https://sheets.googleapis.com/v4/spreadsheets/1Ekq-wK3bN7wCt9o39ad6iu02mQxXb5njt2cn4hEtUxI/values/traloingan!A1:E?key=AIzaSyDlgPD7RfwcpS3GnesNhK06dfQTPs0raCg';

      final responses = await Future.wait([
        http.get(Uri.parse(urlMCQ)),
        http.get(Uri.parse(urlTF)),
        http.get(Uri.parse(urlSA)),
      ]);

      if (responses[0].statusCode == 200 &&
          responses[1].statusCode == 200 &&
          responses[2].statusCode == 200) {

        // 1. Trắc nghiệm
        final mcqData = _parseSheetValues(responses[0].body).map((item) {
          List<String> options = [
            item['option1'] ?? '',
            item['option2'] ?? '',
            item['option3'] ?? '',
            item['option4'] ?? '',
          ];
          options.shuffle(_rng);
          for (int j = 0; j < 4; j++) {
            item['option${j + 1}'] = options[j];
          }
          return item;
        }).toList();

        // 2. Đúng/Sai
        final tfData = _parseSheetValues(responses[1].body);

        // 3. Trả lời ngắn
        final saData = _parseSheetValues(responses[2].body);

        List<Map<String, dynamic>> result = [];
        List<String> topicKeys = ['Topic', 'topic', 'loaichude', 'chude'];

        // --- PHẦN I: TRẮC NGHIỆM (18 câu) ---
        result.add({
          'type': 'header',
          'text': 'PHẦN I. Thí sinh trả lời từ Câu 1 đến Câu 18. Mỗi câu hỏi thí sinh chỉ chọn một phương án. (4.5 điểm)'
        });

        List<Map<String, dynamic>> mcqSelected = [];
        mcqSelected.addAll(getRandomByTopic(mcqData, topicKeys, 'TB', 2));
        mcqSelected.addAll(getRandomByTopic(mcqData, topicKeys, 'TV', 2));
        mcqSelected.addAll(getRandomByTopic(mcqData, topicKeys, 'TH', 5));
        mcqSelected.addAll(getRandomByTopic(mcqData, topicKeys, 'ST', 4));
        mcqSelected.addAll(getRandomByTopic(mcqData, topicKeys, 'DT', 5));
        mcqSelected.shuffle(_rng);

        int questionNumber = 0;
        for (var q in mcqSelected) {
          questionNumber++;
          result.add({'type': 'mcq', 'data': q, 'number': questionNumber});
        }

        // --- PHẦN II: ĐÚNG / SAI (4 câu) ---
        result.add({
          'type': 'header',
          'text': 'PHẦN II. Thí sinh trả lời từ Câu 1 đến Câu 4. Trong mỗi ý a), b), c), d) ở mỗi câu, thí sinh chọn đúng hoặc sai. (4.0 điểm)'
        });

        List<Map<String, dynamic>> tfSelected = [];
        tfSelected.addAll(getRandomByTopic(tfData, topicKeys, 'DV', 1));
        tfSelected.addAll(getRandomByTopic(tfData, topicKeys, 'ST', 1));
        tfSelected.addAll(getRandomByTopic(tfData, topicKeys, 'DT', 2));
        tfSelected.shuffle(_rng);

        int tfNumber = 0;
        for (var q in tfSelected) {
          tfNumber++;
          result.add({'type': 'truefalse', 'data': q, 'number': tfNumber});
        }

        // --- PHẦN III: TRẢ LỜI NGẮN (6 câu) ---
        result.add({
          'type': 'header',
          'text': 'PHẦN III. Thí sinh trả lời từ Câu 1 đến Câu 6. Nhập câu trả lời/kết quả vào ô trống. (1.5 điểm)'
        });

        List<Map<String, dynamic>> saSelected = [];
        saSelected.addAll(getRandomByTopic(saData, topicKeys, 'TH', 1));
        saSelected.addAll(getRandomByTopic(saData, topicKeys, 'ST', 2));
        saSelected.addAll(getRandomByTopic(saData, topicKeys, 'DT', 3));
        saSelected.shuffle(_rng);

        int saNumber = 0;
        for (var q in saSelected) {
          saNumber++;
          result.add({'type': 'shortanswer', 'data': q, 'number': saNumber});
        }

        setState(() {
          allQuestions = result;
          userAnswers = List.generate(
            result.length,
                (i) => result[i]['type'] == 'truefalse'
                ? List<bool?>.filled(4, null)
                : (result[i]['type'] == 'shortanswer' ? '' : null),
          );
        });
      } else {
        setState(() {
          errorMessage = 'Không thể tải dữ liệu từ máy chủ. Vui lòng thử lại!';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Có lỗi xảy ra: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void submitExam() {
    bool hasUnanswered = false;

    for (int i = 0; i < allQuestions.length; i++) {
      String type = allQuestions[i]['type'];
      if (type == 'mcq' && userAnswers[i] == null) {
        hasUnanswered = true;
        break;
      } else if (type == 'truefalse') {
        if ((userAnswers[i] as List).contains(null)) {
          hasUnanswered = true;
          break;
        }
      } else if (type == 'shortanswer') {
        if ((userAnswers[i] as String).trim().isEmpty) {
          hasUnanswered = true;
          break;
        }
      }
    }

    if (hasUnanswered) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text("Bạn chưa làm hết các câu hỏi! Vui lòng hoàn thành trước khi nộp bài.",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),),
          backgroundColor: Colors.white,
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            questions: allQuestions,
            userAnswers: userAnswers,
            theme: "sinh_hoc",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LUYỆN ĐỀ THI TỐT NGHIỆP THPT - SINH HỌC ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: buildBody(),
      bottomNavigationBar: isLoading || errorMessage != null
          ? null
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: submitExam,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text("NỘP BÀI", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: fetchAllData, child: const Text('Thử lại')),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allQuestions.length,
      itemBuilder: (context, index) {
        final q = allQuestions[index];
        if (q['type'] == 'header') {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.shade700, width: 1.5),
            ),
            child: Text(
              q['text'],
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade900),
            ),
          );
        } else if (q['type'] == 'mcq') {
          return buildMcq(q['data'], index, q['number']);
        } else if (q['type'] == 'truefalse') {
          return buildTrueFalse(q['data'], index, q['number']);
        } else if (q['type'] == 'shortanswer') {
          return buildShortAnswer(q['data'], index, q['number']);
        }
        return const SizedBox();
      },
    );
  }

  /// Widget ảnh minh hoạ dùng chung cho cả 3 loại câu hỏi (mcq/truefalse/shortanswer).
  /// Trước đây khối `Image.network(...)` này được copy y hệt 3 lần.
  Widget _buildQuestionImage(BuildContext context, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Image.network(
        imageUrl,
        height: MediaQuery.of(context).size.height * 0.35,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
        const Text('Không tải được ảnh', style: TextStyle(color: Colors.red)),
      ),
    );
  }

  // --- WIDGET TRẮC NGHIỆM ---
  Widget buildMcq(Map<String, dynamic> data, int idx, int number) {
    const optionLetters = ['A', 'B', 'C', 'D'];
    return StatefulBuilder(
      builder: (context, setLocalState) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green.shade400),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarkdownBody(
                data: sanitize("**Câu $number:** ${data['Question'] ?? data['cauhoi'] ?? ''}"),
                styleSheet: markdownStyle,
                inlineSyntaxes: markdownInlineSyntaxes,
                builders: markdownBuilders,
                softLineBreak: true,
              ),
              if ((data['Image'] ?? '').isNotEmpty) _buildQuestionImage(context, data['Image']),
              for (int i = 1; i <= 4; i++)
                RadioListTile<String>(
                  title: MarkdownBody(
                    data: sanitize("**${optionLetters[i - 1]}.** ${data['option$i'] ?? ''}"),
                    styleSheet: markdownStyle,
                    inlineSyntaxes: markdownInlineSyntaxes,
                    builders: markdownBuilders,
                    softLineBreak: true,
                  ),
                  value: '$i',
                  groupValue: userAnswers[idx],
                  onChanged: (val) {
                    setLocalState(() {
                      userAnswers[idx] = val;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGET ĐÚNG / SAI ---
  Widget buildTrueFalse(Map<String, dynamic> data, int questionIdx, int number) {
    const optionLetters = ['a)', 'b)', 'c)', 'd)'];
    if (userAnswers[questionIdx] == null) {
      userAnswers[questionIdx] = List<bool?>.filled(4, null);
    }

    return StatefulBuilder(
      builder: (context, setLocalState) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.orange.shade500),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarkdownBody(
                data: sanitize("**Câu $number:** ${data['cauhoi'] ?? data['Question'] ?? ''}"),
                styleSheet: markdownStyle,
                inlineSyntaxes: markdownInlineSyntaxes,
                builders: markdownBuilders,
                softLineBreak: true,
              ),
              if ((data['Image'] ?? '').isNotEmpty) _buildQuestionImage(context, data['Image']),
              const SizedBox(height: 8),
              for (int i = 0; i < 4; i++)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MarkdownBody(
                      data: sanitize("**${optionLetters[i]}** ${data['phuongan${i + 1}'] ?? ''}"),
                      styleSheet: markdownStyle.copyWith(p: const TextStyle(fontSize: 15)),
                      inlineSyntaxes: markdownInlineSyntaxes,
                      builders: markdownBuilders,
                      softLineBreak: true,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        SizedBox(
                          height: 36,
                          width: 90,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: userAnswers[questionIdx][i] == true ? Colors.green : Colors.grey.shade200,
                              foregroundColor: userAnswers[questionIdx][i] == true ? Colors.white : Colors.black,
                            ),
                            onPressed: () {
                              setLocalState(() {
                                userAnswers[questionIdx][i] = true;
                              });
                            },
                            child: const Text("Đúng"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 36,
                          width: 90,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: userAnswers[questionIdx][i] == false ? Colors.red : Colors.grey.shade200,
                              foregroundColor: userAnswers[questionIdx][i] == false ? Colors.white : Colors.black,
                            ),
                            onPressed: () {
                              setLocalState(() {
                                userAnswers[questionIdx][i] = false;
                              });
                            },
                            child: const Text("Sai"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGET TRẢ LỜI NGẮN (ĐÃ NÂNG CẤP BẮT LỖI BỎ Ô VÀ TỰ DỜI CON TRỎ) ---
  Widget buildShortAnswer(Map<String, dynamic> data, int idx, int number) {
    // Khởi tạo 4 TextEditingController và 4 FocusNode cho riêng từng câu hỏi
    if (!_shortAnswerControllers.containsKey(idx)) {
      String existingAns = userAnswers[idx] ?? '';
      _shortAnswerControllers[idx] = List.generate(4, (i) {
        String char = (i < existingAns.length) ? existingAns[i] : '';
        return TextEditingController(text: char);
      });
      _shortAnswerFocusNodes[idx] = List.generate(4, (_) => FocusNode());
    }

    List<TextEditingController> controllers = _shortAnswerControllers[idx]!;
    List<FocusNode> focusNodes = _shortAnswerFocusNodes[idx]!;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade500),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MarkdownBody(
            data: sanitize("**Câu $number:** ${data['cauhoi'] ?? data['Question'] ?? ''}"),
            styleSheet: markdownStyle,
            inlineSyntaxes: markdownInlineSyntaxes,
            builders: markdownBuilders,
            softLineBreak: true,
          ),
          if ((data['Image'] ?? '').isNotEmpty) _buildQuestionImage(context, data['Image']),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              "Nhập đáp án (Dùng dấu , trong số thập phân):",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
            ),
          ),
          const SizedBox(height: 8),

          // Row chứa 4 ô nhập số
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (boxIndex) {
              return Container(
                width: 50,
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: TextField(
                  controller: controllers[boxIndex],
                  focusNode: focusNodes[boxIndex],
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                  decoration: InputDecoration(
                    counterText: "",
                    filled: true,
                    fillColor: const Color(0xFFE3F2FD),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF90CAF9), width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    // ✅ 1. Không cho phép nhập ô sau nếu ô trước còn trống
                    if (value.isNotEmpty && boxIndex > 0 && controllers[boxIndex - 1].text.isEmpty) {
                      controllers[boxIndex].clear();
                      FocusScope.of(context).requestFocus(focusNodes[boxIndex - 1]);
                      return;
                    }

                    // ✅ 2. Tự động chuyển sang ô kế tiếp khi gõ xong
                    if (value.isNotEmpty && boxIndex < 3) {
                      FocusScope.of(context).requestFocus(focusNodes[boxIndex + 1]);
                    }

                    // ✅ 3. Cập nhật lại đáp án ghép từ 4 ô vào mảng userAnswers
                    String currentFullAns = controllers.map((e) => e.text).join();
                    userAnswers[idx] = currentFullAns;
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}