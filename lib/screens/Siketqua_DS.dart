import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:sinhhoc/utils/dinhdang.dart';
class siResultDungsai extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final List<List<bool?>> userAnswers;

  const siResultDungsai({
    super.key,
    required this.questions,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    int score = 0;

    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final ua = userAnswers[i];
      if (ua[0].toString().toUpperCase() == q['tl1'].toString().toUpperCase() &&
          ua[1].toString().toUpperCase() == q['tl2'].toString().toUpperCase() &&
          ua[2].toString().toUpperCase() == q['tl3'].toString().toUpperCase() &&
          ua[3].toString().toUpperCase() == q['tl4'].toString().toUpperCase()) {
        score++;
      }
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Kết quả Đúng/Sai'),
        backgroundColor: Colors.green.shade300,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Số câu trả lời đúng hoàn chỉnh $score / ${questions.length} câu',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Hiển thị từng câu và các ý người dùng chọn
          ...List.generate(questions.length, (index) {
            final q = questions[index];
            final ua = userAnswers[index];

            return Card(
              color: Colors.lightGreen.shade50,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hiển thị câu hỏi
                    // ✅ Hiển thị câu hỏi bằng Markdown
                    MarkdownBody(
                      data: '**Câu ${index + 1}:** ${sanitize(q['cauhoi'] ?? "")}',
                      styleSheet: markdownStyle,
                      inlineSyntaxes: markdownInlineSyntaxes,
                      builders: markdownBuilders,
                      softLineBreak: true,
                    ),
                    const SizedBox(height: 8),

                    // Nếu có hình ảnh
                    if (q['Image'] != null && q['Image'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Image.network(
                          q['Image'],
                          height: MediaQuery.of(context).size.height * 0.4,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                          const Text('⚠️ Không tải được hình ảnh', style: TextStyle(color: Colors.red)),
                        ),
                      ),

                    // Hiển thị từng ý
                    for (int i = 0; i < 4; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Số ý
                            Text(
                              '${String.fromCharCode(97 + i)})  ', // 97 là 'a' trong ASCII
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16,),
                            ),

                            // Nội dung phương án
                            Expanded(
                              child: MarkdownBody(
                                data: sanitize(q['phuongan${i + 1}'] ?? ''),
                                softLineBreak: true,
                                styleSheet: markdownStyle,
                                inlineSyntaxes: markdownInlineSyntaxes,
                                builders: markdownBuilders,
                              ),
                            ),

                            const SizedBox(width: 6),
                            // Icon đánh dấu đúng/sai
                            Icon(
                              ua[i].toString().toUpperCase() == q['tl${i + 1}'].toString().toUpperCase()
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: ua[i].toString().toUpperCase() == q['tl${i + 1}'].toString().toUpperCase()
                                  ? Colors.green
                                  : Colors.red,
                              size: 20,
                            ),

                            const SizedBox(width: 8),

                            // Lựa chọn của học sinh
                            Text(
                              'Bạn chọn: ${ua[i] == true ? "Đúng" : ua[i] == false ? "Sai" : "?"}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // Nút quay về trang chính
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios_new),
              label: const Text('QUAY LẠI TRANG'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
