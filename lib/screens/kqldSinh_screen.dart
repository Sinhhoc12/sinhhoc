import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:sinhhoc/utils/dinhdang.dart'; // Đảm bảo đường dẫn import đúng

class ResultScreen extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final List<dynamic> userAnswers;
  final String? theme;

  const ResultScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    double totalScore = _calculateTotalScore();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kết Quả Bài Thi Sinh Học",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- HÀNG TỔNG ĐIỂM (CỐ ĐỊNH GIỮA) VÀ NÚT TRANG CHỦ (LỆCH PHẢI) ---
            Row(
              children: [
                // 1. Khoảng trống bên trái làm đối trọng giúp ô điểm nằm chính giữa 100%
                const Expanded(
                  child: SizedBox(),
                ),

                // 2. Ô hiển thị điểm số (Chính giữa)
                Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade700, width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "ĐIỂM SỐ CỦA BẠN",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${totalScore.toStringAsFixed(2)} / 10",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade800,
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Nút Trang chủ (Lệch hẳn sang mép phải)
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      icon: const Icon(Icons.home, color: Colors.white, size: 18),
                      label: const Text(
                        "Trang chủ",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // --- Danh sách chi tiết câu hỏi ---
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final q = questions[index];

                  if (q['type'] == 'header') {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        q['text'] ?? '',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    );
                  } else if (q['type'] == 'mcq') {
                    return _buildMcqResult(q, index);
                  } else if (q['type'] == 'truefalse') {
                    return _buildTrueFalseResult(q, index);
                  } else if (q['type'] == 'shortanswer') {
                    return _buildShortAnswerResult(q, index);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= TÍNH ĐIỂM THEO CHUẨN GDPT 2018 =================
  double _calculateTotalScore() {
    double totalScore = 0.0;

    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final uAns = userAnswers.length > i ? userAnswers[i] : null;

      if (q['type'] == 'mcq') {
        if (_isMcqCorrect(q, uAns)) {
          totalScore += 0.25;
        }
      } else if (q['type'] == 'truefalse') {
        int correctCount = 0;
        for (int j = 0; j < 4; j++) {
          String keyJ = _getTfKeyForSubItem(q['data'], j);
          bool expected = (keyJ == 'TRUE' || keyJ == 'T' || keyJ == '1');
          bool? userChoice = _getUserChoiceForSubItem(uAns, j);

          if (userChoice != null && userChoice == expected) {
            correctCount++;
          }
        }

        if (correctCount == 1) totalScore += 0.10;
        if (correctCount == 2) totalScore += 0.25;
        if (correctCount == 3) totalScore += 0.50;
        if (correctCount == 4) totalScore += 1.00;
      } else if (q['type'] == 'shortanswer') {
        if (uAns != null) {
          String userText = uAns.toString().trim().toLowerCase();
          String correctAnswer = _getShortAnswerCorrect(q['data']).toLowerCase();

          if (userText.isNotEmpty && userText == correctAnswer) {
            totalScore += 0.25;
          }
        }
      }
    }

    return totalScore;
  }

  // --- HÀM LẤY CÂU HỎI ---
  String _getQuestionText(Map<String, dynamic> data) {
    return (data['Question'] ?? data['question'] ?? data['cauhoi'] ?? '').toString();
  }

  // --- HÀM LẤY ĐÁP ÁN ĐÚNG TRẢ LỜI NGẮN ---
  String _getShortAnswerCorrect(Map<String, dynamic> data) {
    List<String> possibleKeys = [
      'Answer',
      'answer',
      'dapan',
      'dapandung',
      'CorrectAnswer',
      'tl',
      'ketqua'
    ];

    for (String key in possibleKeys) {
      if (data[key] != null && data[key].toString().trim().isNotEmpty) {
        return data[key].toString().trim();
      }
    }
    return '';
  }

  // --- HÀM LẤY GIẢI THÍCH (CỘT NOTE) ---
  String _getNoteText(Map<String, dynamic> data) {
    return (data['Note'] ?? data['note'] ?? data['giaithich'] ?? '').toString().trim();
  }

  // --- HÀM HIỂN THỊ KHUNG GIẢI THÍCH (CỘT NOTE) NẾU SAI ---
  Widget _buildNoteWidget(String note) {
    if (note.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.yellow.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: MarkdownBody(
        data: sanitize("**Giải thích:** $note"),
        styleSheet: markdownStyle,
        inlineSyntaxes: markdownInlineSyntaxes,
        builders: markdownBuilders,
        softLineBreak: true,
      ),
    );
  }

  // --- HÀM LẤY ĐÁP ÁN ĐÚNG PHẦN ĐÚNG/SAI ---
  String _getTfKeyForSubItem(Map<String, dynamic> data, int subIndex) {
    int idx = subIndex + 1;
    if (data['tl$idx'] != null) {
      return data['tl$idx'].toString().trim().toUpperCase();
    }
    if (data['dapan$idx'] != null) {
      return data['dapan$idx'].toString().trim().toUpperCase();
    }
    String fullKey = (data['dapandung'] ?? data['Answer'] ?? '').toString().trim().toUpperCase();
    if (fullKey.length > subIndex) {
      return fullKey[subIndex];
    }
    return '';
  }

  // --- HÀM LẤY LỰA CHỌN CỦA HỌC SINH PHẦN ĐÚNG/SAI ---
  bool? _getUserChoiceForSubItem(dynamic uAns, int subIndex) {
    if (uAns == null) return null;

    if (uAns is List) {
      if (subIndex < uAns.length) {
        var val = uAns[subIndex];
        if (val is bool) return val;
        if (val != null) {
          String str = val.toString().trim().toUpperCase();
          return (str == 'TRUE' || str == 'T' || str == '1');
        }
      }
    } else if (uAns is Map) {
      var val = uAns[subIndex] ?? uAns[subIndex.toString()];
      if (val is bool) return val;
      if (val != null) {
        String str = val.toString().trim().toUpperCase();
        return (str == 'TRUE' || str == 'T' || str == '1');
      }
    }
    return null;
  }

  // Kiểm tra câu Trắc nghiệm (MCQ)
  bool _isMcqCorrect(Map<String, dynamic> q, dynamic uAns) {
    if (uAns == null) return false;

    int? selectedIndex = int.tryParse(uAns.toString());
    String selectedText = selectedIndex != null ? (q['data']['option$selectedIndex'] ?? '') : '';
    String correctAnswer = (q['data']['CorrectAnswer'] ?? q['data']['Answer'] ?? '').toString().trim();

    if (selectedText.trim().toLowerCase() == correctAnswer.toLowerCase()) return true;
    if (uAns.toString().trim().toLowerCase() == correctAnswer.toLowerCase()) return true;

    final optionLetters = ['A', 'B', 'C', 'D'];
    if (selectedIndex != null && selectedIndex >= 1 && selectedIndex <= 4) {
      if (optionLetters[selectedIndex - 1].toLowerCase() == correctAnswer.toLowerCase()) {
        return true;
      }
    }

    return false;
  }

  // ================= WIDGET DÙNG CHUNG =================

  /// Khung Card chuẩn cho 1 câu hỏi kết quả — dùng chung cho cả 3 loại
  Widget _resultCard({
    required bool isCorrect,
    required Map<String, dynamic> questionData,
    required int number,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: sanitize("**Câu $number:** ${_getQuestionText(questionData)}"),
              styleSheet: markdownStyle,
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Hàng "icon đúng/sai + Bạn chọn/nhập: ..." — dùng chung cho MCQ và
  Widget _buildAnswerStatusRow({
    required bool isCorrect,
    required String label,
  }) {
    return Row(
      children: [
        Icon(
          isCorrect ? Icons.check_circle : Icons.cancel,
          color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
          size: 18,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCorrect ? Colors.green.shade900 : Colors.red.shade900,
            ),
          ),
        ),
      ],
    );
  }

  // ================= WIDGET HIỂN THỊ KẾT QUẢ MỖI CÂU =================
  Widget _buildMcqResult(Map<String, dynamic> q, int index) {
    final uAns = userAnswers.length > index ? userAnswers[index] : null;
    int? selectedIndex = uAns != null ? int.tryParse(uAns.toString()) : null;
    String userChoiceText = selectedIndex != null ? (q['data']['option$selectedIndex'] ?? '') : 'Chưa trả lời';
    String correctAnswer = (q['data']['CorrectAnswer'] ?? q['data']['Answer'] ?? '').toString().trim();

    bool isCorrect = _isMcqCorrect(q, uAns);
    String note = _getNoteText(q['data']);

    return _resultCard(
      isCorrect: isCorrect,
      questionData: q['data'],
      number: q['number'],
      children: [
        _buildAnswerStatusRow(isCorrect: isCorrect, label: "Bạn chọn: $userChoiceText"),
        if (!isCorrect) ...[
          const SizedBox(height: 4),
          Text(
            "Đáp án đúng: $correctAnswer",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800),
          ),
          _buildNoteWidget(note),
        ],
      ],
    );
  }

  Widget _buildTrueFalseResult(Map<String, dynamic> q, int index) {
    final uAns = userAnswers.length > index ? userAnswers[index] : null;
    const letters = ['a)', 'b)', 'c)', 'd)'];

    int correctSubCount = 0;
    for (int j = 0; j < 4; j++) {
      String keyJ = _getTfKeyForSubItem(q['data'], j);
      bool expected = (keyJ == 'TRUE' || keyJ == 'T' || keyJ == '1');
      bool? userChoice = _getUserChoiceForSubItem(uAns, j);
      if (userChoice != null && userChoice == expected) {
        correctSubCount++;
      }
    }
    bool isAllCorrect = (correctSubCount == 4);
    String note = _getNoteText(q['data']);

    return _resultCard(
      isCorrect: isAllCorrect,
      questionData: q['data'],
      number: q['number'],
      children: [
        // Trước đây mỗi sub-item được bọc trong Builder(builder: (context) {...})
        // dù không dùng context bên trong — bỏ Builder thừa, gọi thẳng hàm.
        for (int i = 0; i < 4; i++) _buildTfSubItem(q['data'], uAns, letters, i),
        if (!isAllCorrect) _buildNoteWidget(note),
      ],
    );
  }

  Widget _buildTfSubItem(Map<String, dynamic> data, dynamic uAns, List<String> letters, int i) {
    String keyJ = _getTfKeyForSubItem(data, i);
    bool expected = (keyJ == 'TRUE' || keyJ == 'T' || keyJ == '1');
    bool? userChoice = _getUserChoiceForSubItem(uAns, i);
    bool isSubCorrect = (userChoice != null && userChoice == expected);

    String userStr = userChoice == null ? "Chưa chọn" : (userChoice ? "Đúng" : "Sai");
    String expectedStr = expected ? "Đúng" : "Sai";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: userChoice == null
            ? Colors.grey.shade100
            : (isSubCorrect ? Colors.green.shade100 : Colors.red.shade100),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              "${letters[i]} ${data['phuongan${i + 1}'] ?? data['option${i + 1}'] ?? ''}",
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "Bạn chọn: $userStr",
            style: TextStyle(
              color: userChoice == null
                  ? Colors.grey.shade600
                  : (isSubCorrect ? Colors.green.shade800 : Colors.red.shade800),
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!isSubCorrect) ...[
            const SizedBox(width: 8),
            Text(
              "(Đáp án: $expectedStr)",
              style: TextStyle(
                color: Colors.green.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShortAnswerResult(Map<String, dynamic> q, int index) {
    final uAns = userAnswers.length > index ? userAnswers[index] : null;
    String userText = (uAns ?? '').toString().trim();
    String correctAnswer = _getShortAnswerCorrect(q['data']);

    bool isCorrect = userText.isNotEmpty &&
        userText.toLowerCase() == correctAnswer.toLowerCase();
    String note = _getNoteText(q['data']);

    return _resultCard(
      isCorrect: isCorrect,
      questionData: q['data'],
      number: q['number'],
      children: [
        _buildAnswerStatusRow(
          isCorrect: isCorrect,
          label: "Bạn nhập: ${userText.isEmpty ? 'Chưa trả lời' : userText}",
        ),
        if (!isCorrect) ...[
          const SizedBox(height: 4),
          Text(
            "Đáp án đúng: ${correctAnswer.isEmpty ? 'Chưa cập nhật đáp án' : correctAnswer}",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800),
          ),
          _buildNoteWidget(note),
        ],
      ],
    );
  }
}