import 'package:flutter/material.dart';

enum TajweedType {
  ghunna,
  ikhfaa,
  qalqala,
  madd,
  idgham,
  idghamWithGhunnah,
  idghamWithoutGhunnah,
  iqlab,
  none,
}

class TajweedRule {
  final TajweedType type;
  final String name;
  final Color color;
  final String pattern;

  const TajweedRule({
    required this.type,
    required this.name,
    required this.color,
    required this.pattern,
  });

  RegExp get regex => RegExp(pattern);

  static final ghunna = TajweedRule(
    type: TajweedType.ghunna,
    name: 'Ghunna',
    color: const Color(0xFF4CAF50),
    pattern: r'[نم]ّ|[نم]ْ|ن[ّْ]?|م[ّْ]?',
  );

  static final ikhfaa = TajweedRule(
    type: TajweedType.ikhfaa,
    name: 'Ikhfaa',
    color: const Color(0xFF9C27B0),
    pattern: r'نْ?[صذثكجشقسدطزفتضظ]|ن[صذثكجشقسدطزفتضظ]',
  );

  static final qalqala = TajweedRule(
    type: TajweedType.qalqala,
    name: 'Qalqala',
    color: const Color(0xFFF44336),
    pattern: r'[قطبجد]ْ|[قطبجد]',
  );

  static final madd = TajweedRule(
    type: TajweedType.madd,
    name: 'Madd',
    color: const Color(0xFF2196F3),
    pattern: r'[َُِ]ٓ|[اوي]ٓ|آ|[اوي]{2}|ا[َُِ]|و[َُِ]|ي[َُِ]',
  );

  static final none = TajweedRule(
    type: TajweedType.none,
    name: 'Normal',
    color: Colors.black,
    pattern: r'',
  );

  static final idghamWithGhunnah = TajweedRule(
    type: TajweedType.idghamWithGhunnah,
    name: 'Idgham dengan Ghunnah',
    color: const Color(0xFFFF9800),
    pattern: r'نْ[ينمو]|مْ[ينمو]',
  );

  static final idghamWithoutGhunnah = TajweedRule(
    type: TajweedType.idghamWithoutGhunnah,
    name: 'Idgham tanpa Ghunnah',
    color: const Color(0xFF795548),
    pattern: r'نْ[لر]|مْ[لر]',
  );

  static final iqlab = TajweedRule(
    type: TajweedType.iqlab,
    name: 'Iqlab',
    color: const Color(0xFF00BCD4),
    pattern: r'نْب|نب',
  );

  static final List<TajweedRule> rules = [
    ghunna,
    ikhfaa,
    qalqala,
    madd,
    idghamWithGhunnah,
    idghamWithoutGhunnah,
    iqlab,
  ];
}

class TajweedToken {
  final String text;
  final TajweedRule rule;

  const TajweedToken(this.text, this.rule);
}

class Tajweed {
  static List<TajweedToken> applySimpleTajweed(String text) {
    if (text.isEmpty) return [];

    List<TajweedToken> result = [];

    // Daftar karakter khusus yang menandakan tajweed
    final Map<String, TajweedRule> specialChars = {
      'ّ': TajweedRule.ghunna, // Tasydid (untuk ghunnah)
      'ْ':
          TajweedRule
              .qalqala, // Sukun (untuk qalqala jika setelah huruf qalqala)
      'ٓ': TajweedRule.madd, // Tanda madd
      'آ': TajweedRule.madd, // Alif dengan madd
      'ً': TajweedRule.ghunna, // Tanwin fathah
      'ٌ': TajweedRule.ghunna, // Tanwin dammah
      'ٍ': TajweedRule.ghunna, // Tanwin kasrah
    };

    // Daftar huruf qalqala
    final qalqalaLetters = ['ق', 'ط', 'ب', 'ج', 'د'];

    // Daftar huruf ikhfa
    final ikhfaLetters = [
      'ص',
      'ذ',
      'ث',
      'ك',
      'ج',
      'ش',
      'ق',
      'س',
      'د',
      'ط',
      'ز',
      'ف',
      'ت',
      'ض',
      'ظ',
    ];

    // Proses teks karakter per karakter
    for (int i = 0; i < text.length; i++) {
      String currentChar = text[i];
      String nextChar = (i < text.length - 1) ? text[i + 1] : '';
      String prevChar = (i > 0) ? text[i - 1] : '';

      // Tentukan aturan tajweed berdasarkan karakter saat ini dan konteksnya
      TajweedRule? rule;

      // Cek untuk ghunnah (nun dan mim dengan tasydid)
      if ((currentChar == 'ن' || currentChar == 'م') && nextChar == 'ّ') {
        rule = TajweedRule.ghunna;
        result.add(TajweedToken(currentChar + nextChar, rule));
        i++; // Lewati karakter berikutnya karena sudah diproses
        continue;
      }

      // Cek untuk ikhfa (nun dengan sukun diikuti huruf ikhfa)
      if (currentChar == 'ن' &&
          nextChar == 'ْ' &&
          i < text.length - 2 &&
          ikhfaLetters.contains(text[i + 2])) {
        rule = TajweedRule.ikhfaa;
        result.add(TajweedToken(currentChar + nextChar + text[i + 2], rule));
        i += 2; // Lewati dua karakter berikutnya
        continue;
      }

      // Cek untuk qalqala (huruf qalqala dengan sukun)
      if (qalqalaLetters.contains(currentChar) && nextChar == 'ْ') {
        rule = TajweedRule.qalqala;
        result.add(TajweedToken(currentChar + nextChar, rule));
        i++; // Lewati karakter berikutnya
        continue;
      }

      // Cek untuk madd (alif, waw, ya dengan tanda madd)
      if ((currentChar == 'ا' || currentChar == 'و' || currentChar == 'ي') &&
          nextChar == 'ٓ') {
        rule = TajweedRule.madd;
        result.add(TajweedToken(currentChar + nextChar, rule));
        i++; // Lewati karakter berikutnya
        continue;
      }

      // Cek karakter khusus tajweed
      if (specialChars.containsKey(currentChar)) {
        rule = specialChars[currentChar];
        // Jika sukun, periksa apakah huruf sebelumnya adalah huruf qalqala
        if (currentChar == 'ْ' && i > 0 && qalqalaLetters.contains(prevChar)) {
          rule = TajweedRule.qalqala;
          // Karakter sebelumnya sudah ditambahkan sebagai normal, jadi hapus dan tambahkan dengan qalqala
          if (result.isNotEmpty) {
            result.removeLast();
            result.add(TajweedToken(prevChar + currentChar, rule));
            continue;
          }
        }
        result.add(TajweedToken(currentChar, rule!));
      } else {
        // Karakter normal tanpa tajweed
        result.add(TajweedToken(currentChar, TajweedRule.none));
      }
    }

    return result;
  }
}
