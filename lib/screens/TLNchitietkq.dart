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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      theme == 'cute' ? Colors.pink[50] : Colors.blue[50],

      appBar: AppBar(
        title: const Text('📋 Chi tiết bài làm'),
        backgroundColor:
        theme == 'cute'
            ? Colors.pink
            : Colors.blueAccent,
      ),

      body: ListView.builder(
        itemCount: questions.length,

        itemBuilder: (context, index) {
          final question = questions[index];

          final String questionText =
              question['Question'] ?? "Không có nội dung";

          final String correctAnswer =
              question['Answer'] ?? "Chưa có đáp án";

          final String? userAnswer =
          userAnswers.length > index
              ? userAnswers[index]
              : null;

          // ✅ Lấy phần giải thích
          final String note =
              question['Note'] ?? "";

          final bool isCorrect =
              userAnswer != null &&
                  userAnswer.trim() ==
                      correctAnswer.trim();

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),

            color:
            isCorrect
                ? Colors.green[50]
                : Colors.red[50],

            child: ListTile(
              title: MarkdownBody(
                data:
                '**Câu ${index + 1}:** ${sanitize(questionText)}',

                styleSheet: markdownStyle,

                inlineSyntaxes: markdownInlineSyntaxes,

                builders: markdownBuilders,

                softLineBreak: true,
              ),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // ✅ Hiển thị hình ảnh nếu có
                  if (question['Image'] != null &&
                      question['Image']
                          .toString()
                          .isNotEmpty)
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 8.0,
                      ),

                      child: Align(
                        alignment: Alignment.centerLeft,

                        child: ClipRRect(
                          borderRadius:
                          BorderRadius.circular(8),

                          child: Image.network(
                            question['Image'],

                            height:
                            MediaQuery.of(context)
                                .size
                                .height *
                                0.4,

                            fit: BoxFit.contain,

                            errorBuilder:
                                (
                                context,
                                error,
                                stackTrace,
                                ) =>
                            const Text(
                              '⚠️ Không tải được hình ảnh',

                              style: TextStyle(
                                color:
                                Colors.redAccent,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  Text(
                    'Bạn trả lời: ${userAnswer ?? "Chưa trả lời"}',

                    style: TextStyle(
                      fontSize: 15,
                      color:
                      isCorrect
                          ? Colors.green
                          : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Đáp án đúng: $correctAnswer',

                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // ✅ Chỉ hiển thị giải thích khi trả lời sai
                  if (!isCorrect &&
                      note.trim().isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.yellow[50],
                        borderRadius:
                        BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.orange.shade200,
                        ),
                      ),

                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [
                         const SizedBox(width: 8),

                          Expanded(
                            child: MarkdownBody(
                              data:
                              '**Giải thích:** ${sanitize(note)}',

                              styleSheet:
                              markdownStyle,

                              inlineSyntaxes:
                              markdownInlineSyntaxes,

                              builders:
                              markdownBuilders,

                              softLineBreak: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              trailing: Icon(
                isCorrect
                    ? Icons.check_circle
                    : Icons.cancel,

                color:
                isCorrect
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          );
        },
      ),
    );
  }
}