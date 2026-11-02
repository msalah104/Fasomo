import 'package:flutter/material.dart';

/// Arabic scripture text (a dua, a hadith), always laid out right-to-left
/// and right-aligned, even inside a left-to-right English screen.
///
/// The text is tagged as Arabic so a screen reader reads it with an Arabic
/// voice. When [selectable], it can be selected and copied.
class ArabicText extends StatelessWidget {
  const new(this.text, {this.style, this.selectable = false, super.key});

  static const Locale _arabic = Locale('ar');

  final String text;

  /// Merged over the theme's large title style.
  final TextStyle? style;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.titleLarge ?? const TextStyle();
    // Tashkeel needs extra line height so the marks never collide.
    final effective = base.copyWith(height: 1.9, locale: _arabic).merge(style);
    return Directionality(
      textDirection: TextDirection.rtl,
      // Full width so the block hugs the right edge in a left-to-right page.
      child: SizedBox(
        width: double.infinity,
        child: selectable
            ? SelectableText(text, style: effective)
            : Text(text, style: effective, locale: _arabic),
      ),
    );
  }
}
