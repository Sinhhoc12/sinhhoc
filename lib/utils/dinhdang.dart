import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

/// 🔹 Danh sách InlineSyntax và Builders dùng chung
/// (Giữ nguyên tên `markdownInlineSyntaxes` — các file khác gọi tới tên này)
final List<md.InlineSyntax> markdownInlineSyntaxes = [
  GachChanSyntax(),
  ChiSoTrenSyntax(),
  ChiSoDuoiSyntax(),
  GachNgangSyntax(), // ✅ cú pháp gạch ngang
  ToNenSyntax(), // ✅ cú pháp tô nền (highlight)
];

/// (Giữ nguyên tên `markdownBuilders` — các file khác gọi tới tên này)
final Map<String, MarkdownElementBuilder> markdownBuilders = {
  'underline': GachChanBuilder(),
  'sup': ChiSoTrenBuilder(),
  'sub': ChiSoDuoiBuilder(),
  'del': GachNgangBuilder(), // ✅ builder cho gạch ngang
  'img': AnhTrongCauBuilder(), // ✅ ảnh nhúng giữa câu
  'highlight': ToNenBuilder(), // ✅ builder cho tô nền
};

/// 🔹 Gạch chân — cú pháp: __text__
class GachChanSyntax extends md.InlineSyntax {
  GachChanSyntax() : super(r'__(.+?)__');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final text = match.group(1)!;
    final element = md.Element.text('underline', text);
    parser.addNode(element);
    return true;
  }
}

class GachChanBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.tag != 'underline') return const SizedBox.shrink();

    final style = (preferredStyle ?? const TextStyle(fontSize: 18, color: Colors.black87))
        .copyWith(decoration: TextDecoration.underline);

    return MarkdownBody(
      data: element.textContent,
      styleSheet: MarkdownStyleSheet(
        p: style,
        strong: style.copyWith(fontWeight: FontWeight.bold),
        em: style.copyWith(fontStyle: FontStyle.italic),
      ),
      builders: markdownBuilders,
      inlineSyntaxes: markdownInlineSyntaxes,
    );
  }
}

/// 🔹 Chỉ số trên (^x^)
class ChiSoTrenSyntax extends md.InlineSyntax {
  ChiSoTrenSyntax() : super(r'\^(.+?)\^');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('sup', match.group(1)!));
    return true;
  }
}

class ChiSoTrenBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final baseFontSize = preferredStyle?.fontSize ?? 18;
    final style = (preferredStyle ?? const TextStyle(fontSize: 18, color: Colors.black87)).copyWith(
      fontSize: baseFontSize * 0.7,
      height: 1,
    );

    // Dùng MarkdownBody lồng bên trong (giống GachChanBuilder) thay vì
    // Text đơn thuần, để **đậm**/*nghiêng* bên trong ^^...^^ vẫn hiển
    // thị đúng thay vì bị mất định dạng (ví dụ "^**2**^").
    return Transform.translate(
      offset: const Offset(0, -4),
      child: MarkdownBody(
        data: element.textContent,
        styleSheet: MarkdownStyleSheet(
          p: style,
          strong: style.copyWith(fontWeight: FontWeight.bold),
          em: style.copyWith(fontStyle: FontStyle.italic),
        ),
        builders: markdownBuilders,
        inlineSyntaxes: markdownInlineSyntaxes,
      ),
    );
  }
}

/// 🔹 Chỉ số dưới (~x~)
class ChiSoDuoiSyntax extends md.InlineSyntax {
  ChiSoDuoiSyntax() : super(r'(?<!~)~(?!~)(.+?)(?<!~)~(?!~)'); // ✅ tránh nhầm với ~~gạch ngang~~

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('sub', match.group(1)!));
    return true;
  }
}

class ChiSoDuoiBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final baseFontSize = preferredStyle?.fontSize ?? 18;
    final style = (preferredStyle ?? const TextStyle(fontSize: 18, color: Colors.black87)).copyWith(
      fontSize: baseFontSize * 0.7,
      height: 1,
    );

    return Transform.translate(
      offset: const Offset(0, 3),
      child: MarkdownBody(
        data: element.textContent,
        styleSheet: MarkdownStyleSheet(
          p: style,
          strong: style.copyWith(fontWeight: FontWeight.bold),
          em: style.copyWith(fontStyle: FontStyle.italic),
        ),
        builders: markdownBuilders,
        inlineSyntaxes: markdownInlineSyntaxes,
      ),
    );
  }
}

/// 🔹 Gạch ngang chữ (~~x~~)
class GachNgangSyntax extends md.InlineSyntax {
  GachNgangSyntax() : super(r'~~(.*?)~~'); // ✅ pattern chính xác cho gạch ngang

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final text = match.group(1)!;
    parser.addNode(md.Element.text('del', text));
    return true;
  }
}

class GachNgangBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final style = (preferredStyle ?? const TextStyle(fontSize: 18))
        .copyWith(decoration: TextDecoration.lineThrough);
    return Text(element.textContent, style: style);
  }
}

/// 🔹 Tô nền (highlight) chữ — cú pháp: ==text==
class ToNenSyntax extends md.InlineSyntax {
  ToNenSyntax() : super(r'==(.+?)==');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final text = match.group(1)!;
    parser.addNode(md.Element.text('highlight', text));
    return true;
  }
}

class ToNenBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final style = preferredStyle ?? const TextStyle(fontSize: 18, color: Colors.black87);

    // Dùng MarkdownBody lồng bên trong để **đậm**/*nghiêng* bên trong
    // ==...== vẫn giữ được định dạng, giống cách GachChanBuilder làm.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      color: const Color(0xFFFFF59D), // vàng nhạt (Colors.yellow.shade200)
      child: MarkdownBody(
        data: element.textContent,
        styleSheet: MarkdownStyleSheet(
          p: style,
          strong: style.copyWith(fontWeight: FontWeight.bold),
          em: style.copyWith(fontStyle: FontStyle.italic),
        ),
        builders: markdownBuilders,
        inlineSyntaxes: markdownInlineSyntaxes,
      ),
    );
  }
}

/// 🔹 Ảnh nhúng giữa câu — cú pháp Markdown chuẩn: ![mô tả](link-ảnh)
/// Dùng LayoutBuilder để chiều cao ảnh co giãn theo chiều rộng khung
/// chứa thực tế, không cần BuildContext/MediaQuery truyền vào.
class AnhTrongCauBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final url = element.attributes['src'] ?? '';
    if (url.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Chiều cao tối đa = 60% chiều rộng khung chứa, nhưng không
          // vượt quá 320px (tránh ảnh quá to trên màn hình rất rộng)
          // và không nhỏ hơn 150px (tránh ảnh quá bé trên màn hình hẹp).
          final double maxH = (constraints.maxWidth * 0.6).clamp(150, 320);

          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: Image.network(
              url,
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Text(
                'Không tải được ảnh',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 🔹 Style Markdown chung (giữ nguyên tên `markdownStyle`)
final markdownStyle = MarkdownStyleSheet(
  p: const TextStyle(fontSize: 18, height: 1.4, color: Colors.black87),
  strong: const TextStyle(fontWeight: FontWeight.bold),
  em: const TextStyle(fontStyle: FontStyle.italic),
  del: const TextStyle(
    decoration: TextDecoration.lineThrough,
    color: Colors.black87,
    fontSize: 18,
  ),
);

/// (Giữ nguyên tên `sanitize` — các file khác gọi tới tên này)
String sanitize(String text) {
  return text
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
  // Chuẩn hóa xuống dòng: loại bỏ khoảng trắng dư
      .replaceAll(RegExp(r'\r\n|\r|\n'), '\n')
  // Xóa dòng trống liên tiếp thành 1 dòng
      .replaceAll(RegExp(r'\n{2,}'), '\n\n')
      .trim();
}