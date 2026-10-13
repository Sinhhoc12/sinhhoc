import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:sinhhoc/utils/dinhdang.dart';
class DetailScreen extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final List<String?> userAnswers;
  final String theme;

  const DetailScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.theme,
  });

  // 🔑 Hàm đổi nội dung đáp án thành chữ cái A/B/C/D
  String getOptionLetter(Map<String, dynamic> question, String? answer) {
    if (answer == null) return 'Không chọn';
    if (answer == question['option1']) return 'A';
    if (answer == question['option2']) return 'B';
    if (answer == question['option3']) return 'C';
    if (answer == question['option4']) return 'D';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme == 'cute' ? Colors.pink[50] : Colors.blue[50],
      appBar: AppBar(
        title: const Text('📋 Chi tiết bài làm'),
        backgroundColor: theme == 'cute' ? Colors.pink : Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final String questionText = question['Question'] ?? "Không có nội dung";
          final String correctAnswer = question['Answer'] ?? "Chưa có đáp án";
          final String? userAnswer = userAnswers.length > index ? userAnswers[index] : null;

          // Chuyển đáp án sang chữ cái
          final String userLetter = getOptionLetter(question, userAnswer);
          final String correctLetter = getOptionLetter(question, correctAnswer);

          final bool isCorrect = userLetter == correctLetter && userLetter != 'Không chọn';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: isCorrect ? Colors.green[50] : Colors.red[50],
            child: ListTile(
              // Câu hỏi (hiển thị Markdown)
              title:MarkdownBody(
                data: '**Câu ${index + 1}:** ${sanitize(questionText)}',
                styleSheet: markdownStyle,
                inlineSyntaxes: markdownInlineSyntaxes,
                builders: markdownBuilders,
                softLineBreak: true,
              ),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Hiển thị hình ảnh nếu có
                  if (question['Image'] != null && question['Image'].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft, // 👈 căn trái
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            question['Image'],
                            height: MediaQuery.of(context).size.height * 0.4,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Text(
                              '⚠️ Không tải được hình ảnh',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ),
                      ),

                    ),

                  for (var opt in ['option1', 'option2', 'option3', 'option4'])
                    MarkdownBody(
                      data: '${getOptionLetter(question, question[opt])}. ${sanitize(question[opt] ?? "")}',
                      styleSheet: markdownStyle.copyWith(
                        p: markdownStyle.p?.copyWith(
                          color: (question[opt] == correctAnswer)
                              ? Colors.red      // đáp án đúng
                              : (question[opt] == userAnswer)
                              ? Colors.green // đáp án người dùng chọn sai
                              : Colors.black, // các đáp án còn lại
                          fontSize: 15,
                        ),
                      ),
                      inlineSyntaxes: markdownInlineSyntaxes,
                      builders: markdownBuilders,
                      softLineBreak: true,
                    ),

                  const SizedBox(height: 5),
                  Text('Bạn chọn: $userLetter'),
                  Text('Đáp án đúng: $correctLetter', style: const TextStyle(color: Colors.red)),
                ],
              ),
              trailing: Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
              ),
            ),
          );
        },
      ),
    );
  }
}
