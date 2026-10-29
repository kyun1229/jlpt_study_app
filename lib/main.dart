import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

// ---------------------------------------------------------------------------
// 디자인 토큰: 일본식 미니멀리즘 (화지 종이 바탕, 먹색 글자, 남색 藍 주색, 주색 朱 강조)
// ---------------------------------------------------------------------------
class Washi {
  static const paper = Color(0xFFF6F1E7); // 화지 바탕
  static const paperDeep = Color(0xFFECE4D3); // 진한 종이
  static const card = Color(0xFFFFFDF8); // 카드 면
  static const line = Color(0xFFD8CEBB); // 가는 괘선
  static const ink = Color(0xFF1E1A17); // 먹
  static const inkSoft = Color(0xFF6B625A); // 옅은 먹
  static const indigo = Color(0xFF274C77); // 藍
  static const indigoSoft = Color(0xFFDCE5F0);
  static const vermilion = Color(0xFFC8402F); // 朱
  static const vermilionSoft = Color(0xFFF7E1DC);
  static const moss = Color(0xFF55774A); // 苔
  static const mossSoft = Color(0xFFDFE8D6);
  static const amber = Color(0xFFC08A2B); // 黄土
  static const amberSoft = Color(0xFFF5E8CF);

  // 무한지옥 (어두운 먹 + 불꽃)
  static const night = Color(0xFF171210);
  static const nightCard = Color(0xFF241C18);
  static const nightLine = Color(0xFF3A2E28);
  static const ember = Color(0xFFE2572F);
  static const emberSoft = Color(0xFF4A2A1E);
  static const cream = Color(0xFFF3E9D8);

  static const double maxContentWidth = 640;
}

ThemeData buildLightTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: Washi.indigo,
    onPrimary: Colors.white,
    primaryContainer: Washi.indigoSoft,
    onPrimaryContainer: Washi.indigo,
    secondary: Washi.vermilion,
    onSecondary: Colors.white,
    secondaryContainer: Washi.vermilionSoft,
    onSecondaryContainer: Washi.vermilion,
    tertiary: Washi.moss,
    onTertiary: Colors.white,
    tertiaryContainer: Washi.mossSoft,
    onTertiaryContainer: Washi.moss,
    error: Washi.vermilion,
    onError: Colors.white,
    surface: Washi.paper,
    onSurface: Washi.ink,
    onSurfaceVariant: Washi.inkSoft,
    surfaceContainerHighest: Washi.paperDeep,
    outline: Washi.line,
    outlineVariant: Washi.line,
  );

  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  final textTheme = GoogleFonts.notoSansKrTextTheme(base.textTheme).apply(
    bodyColor: Washi.ink,
    displayColor: Washi.ink,
  );
  final rounded = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));

  return base.copyWith(
    scaffoldBackgroundColor: Washi.paper,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Washi.paper,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Washi.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    ),
    cardTheme: CardThemeData(
      color: Washi.card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Washi.line),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: rounded,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: rounded,
        foregroundColor: Washi.ink,
        side: const BorderSide(color: Washi.ink, width: 1.2),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(shape: rounded, foregroundColor: Washi.indigo),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Washi.card,
      selectedColor: Washi.indigo,
      side: const BorderSide(color: Washi.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      labelStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      checkmarkColor: Colors.white,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Colors.white : Washi.inkSoft,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Washi.indigo : Washi.paperDeep,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Washi.indigo : Washi.line,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Washi.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      contentTextStyle: textTheme.bodyMedium,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Washi.ink,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: Washi.cream),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Washi.indigo,
      linearTrackColor: Washi.paperDeep,
    ),
    dividerTheme: const DividerThemeData(color: Washi.line, thickness: 1),
  );
}

ThemeData buildInfiniteTheme(ThemeData light) {
  const scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Washi.ember,
    onPrimary: Colors.white,
    primaryContainer: Washi.emberSoft,
    onPrimaryContainer: Washi.cream,
    secondary: Washi.ember,
    onSecondary: Colors.white,
    secondaryContainer: Washi.emberSoft,
    onSecondaryContainer: Washi.cream,
    tertiary: Color(0xFF8FB07E),
    onTertiary: Washi.night,
    tertiaryContainer: Color(0xFF2E3A28),
    onTertiaryContainer: Color(0xFFCFE3C2),
    error: Washi.ember,
    onError: Colors.white,
    surface: Washi.night,
    onSurface: Washi.cream,
    onSurfaceVariant: Color(0xFFB9ACA0),
    surfaceContainerHighest: Washi.nightLine,
    outline: Washi.nightLine,
    outlineVariant: Washi.nightLine,
  );
  final textTheme = light.textTheme.apply(bodyColor: Washi.cream, displayColor: Washi.cream);
  return light.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: Washi.night,
    textTheme: textTheme,
    appBarTheme: light.appBarTheme.copyWith(
      backgroundColor: Washi.night,
      foregroundColor: Washi.cream,
      titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    ),
    cardTheme: light.cardTheme.copyWith(
      color: Washi.nightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Washi.nightLine),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: light.outlinedButtonTheme.style?.copyWith(
        foregroundColor: const WidgetStatePropertyAll(Washi.cream),
        side: const WidgetStatePropertyAll(BorderSide(color: Washi.cream, width: 1.2)),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Washi.ember,
      linearTrackColor: Washi.nightLine,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JLPT 공부',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      home: const ModeSelectPage(),
    );
  }
}

enum StudyMode { test, study, infinite }

enum QuizCategory {
  hiragana('히라가나', 'hiragana'),
  katakana('가타카나', 'katakana'),
  n5Kanji('N5 한자', 'n5_kanji'),
  n4Kanji('N4 한자', 'n4_kanji'),
  n3Kanji('N3 한자', 'n3_kanji'),
  n2Kanji('N2 한자', 'n2_kanji'),
  n1Kanji('N1 한자', 'n1_kanji'),
  n5Word('N5 단어', 'n5_word'),
  n4Word('N4 단어', 'n4_word'),
  n3Word('N3 단어', 'n3_word'),
  n2Word('N2 단어', 'n2_word'),
  n1Word('N1 단어', 'n1_word');

  const QuizCategory(this.label, this.keyName);
  final String label;
  final String keyName;
}

// 한자 레벨을 몇 개의 그룹(80~100개 단위)으로 쪼갤지 설정.
const Map<String, int> kKanjiGroupCounts = {
  'n5_kanji': 1,
  'n4_kanji': 2,
  'n3_kanji': 4,
  'n2_kanji': 5,
  'n1_kanji': 12,
};

const List<String> _kCircledNumbers = ['①', '②', '③', '④', '⑤', '⑥', '⑦', '⑧', '⑨', '⑩', '⑪', '⑫', '⑬', '⑭', '⑮'];

// 카테고리 선택 화면에 표시되는 선택 단위.
// 한자 레벨은 '전체' 옵션 1개 + 그룹 옵션 여러 개로 분리된다.
class CategoryOption {
  const CategoryOption({
    required this.id,
    required this.label,
    required this.categoryKey,
    required this.section,
    required this.items,
    required this.isWhole,
  });

  final String id; // 선택 식별자 (예: 'n4_kanji#all', 'n4_kanji#0')
  final String label; // 화면 표시 라벨
  final String categoryKey; // 데이터/지식 저장에 쓰는 레벨 키 (예: 'n4_kanji')
  final String section; // 섹션 헤더 (예: 'N4')
  final List<QuizItem> items;
  final bool isWhole; // 레벨 전체(또는 비분할) 옵션 여부

  int get count => items.length;
}

class QuizItem {
  const QuizItem({
    required this.surface,
    required this.reading,
    required this.meaning,
    required this.pos,
    required this.categoryKey,
    this.onyomi,
    this.kunyomi,
    this.relatedKanji = const [],
    this.relatedReading = const [],
    this.relatedMeaning = const [],
  });

  final String surface;
  final String reading;
  final String meaning;
  final String pos;
  final String categoryKey;
  final String? onyomi;
  final String? kunyomi;
  final List<String> relatedKanji;
  final List<String> relatedReading;
  final List<String> relatedMeaning;

  bool get isKanji => categoryKey.contains('kanji');

  bool get isKana => categoryKey == 'hiragana' || categoryKey == 'katakana';

  factory QuizItem.fromJson(Map<String, dynamic> json, String categoryKey) {
    final isKanji = categoryKey.contains('kanji');
    String reading;
    if (isKanji) {
      final onyomi = (json['onyomi'] ?? '').toString();
      final kunyomi = (json['kunyomi'] ?? '').toString();
      reading = [onyomi, kunyomi].where((s) => s.isNotEmpty).join(' / ');
    } else {
      reading = (json['reading'] ?? '').toString();
    }

    return QuizItem(
      surface: (json['surface'] ?? '').toString(),
      reading: reading,
      meaning: (json['meaning'] ?? '').toString(),
      pos: (json['pos'] ?? '').toString(),
      categoryKey: categoryKey,
      onyomi: isKanji ? (json['onyomi'] ?? '').toString() : null,
      kunyomi: isKanji ? (json['kunyomi'] ?? '').toString() : null,
      relatedKanji: isKanji ? _parseStringList(json['related_kanji']) : const [],
      relatedReading: isKanji ? _parseStringList(json['related_reading']) : const [],
      relatedMeaning: isKanji ? _parseStringList(json['related_meaning']) : const [],
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return const [];
  }
}

// ---------------------------------------------------------------------------
// 공용 위젯
// ---------------------------------------------------------------------------

// 웹/태블릿에서 가운데 정렬된 고정 폭 컬럼.
class CenteredColumn extends StatelessWidget {
  const CenteredColumn({super.key, required this.child, this.maxWidth = Washi.maxContentWidth});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

// 낙관(落款) 도장 느낌의 붉은 네모 마크.
class HankoMark extends StatelessWidget {
  const HankoMark({super.key, required this.text, this.size = 56, this.color = Washi.vermilion});

  final String text;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.06,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size * 0.18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.5,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ),
    );
  }
}

// 주색 세로 괘선이 붙은 섹션 제목.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: scheme.secondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (trailing != null) ...[const Spacer(), trailing!],
      ],
    );
  }
}

// 작은 라벨 뱃지.
class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, required this.background, required this.foreground, this.icon});

  final String text;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(color: foreground, fontWeight: FontWeight.w700, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 모드 선택 화면
// ---------------------------------------------------------------------------
class ModeSelectPage extends StatelessWidget {
  const ModeSelectPage({super.key});

  void _open(BuildContext context, StudyMode mode) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => QuizHomePage(mode: mode)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: CenteredColumn(
          maxWidth: 480,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Row(
                  children: [
                    const HankoMark(text: '日', size: 60),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'JLPT 공부',
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '가나 · 한자 · 단어를 매일 조금씩',
                            style: textTheme.bodyMedium?.copyWith(color: Washi.inkSoft),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                Text(
                  '모드를 선택하세요',
                  style: textTheme.labelLarge?.copyWith(
                    color: Washi.inkSoft,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                _ModeCard(
                  icon: Icons.shuffle_rounded,
                  kanji: '試',
                  title: '테스트',
                  subtitle: '무작위 순서로 출제, 정답은 가려진 채 시작',
                  accent: Washi.indigo,
                  accentSoft: Washi.indigoSoft,
                  onTap: () => _open(context, StudyMode.test),
                ),
                const SizedBox(height: 12),
                _ModeCard(
                  icon: Icons.menu_book_rounded,
                  kanji: '学',
                  title: '공부',
                  subtitle: '순서대로 보며 외우기, 책갈피로 이어하기',
                  accent: Washi.moss,
                  accentSoft: Washi.mossSoft,
                  onTap: () => _open(context, StudyMode.study),
                ),
                const SizedBox(height: 12),
                _ModeCard(
                  icon: Icons.local_fire_department_rounded,
                  kanji: '鬼',
                  title: '무한지옥',
                  subtitle: '확실히 알 때까지 계속 다시 나오는 반복 훈련',
                  accent: Washi.ember,
                  accentSoft: Washi.emberSoft,
                  dark: true,
                  onTap: () => _open(context, StudyMode.infinite),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    '学びて時にこれを習う',
                    style: textTheme.bodySmall?.copyWith(color: Washi.line.withValues(alpha: 1), letterSpacing: 2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.kanji,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.accentSoft,
    required this.onTap,
    this.dark = false,
  });

  final IconData icon;
  final String kanji;
  final String title;
  final String subtitle;
  final Color accent;
  final Color accentSoft;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bg = dark ? Washi.night : Washi.card;
    final fg = dark ? Washi.cream : Washi.ink;
    final sub = dark ? const Color(0xFFB9ACA0) : Washi.inkSoft;
    final border = dark ? Washi.night : Washi.line;

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Positioned(
              right: -6,
              bottom: -22,
              child: Text(
                kanji,
                style: TextStyle(
                  fontSize: 96,
                  fontWeight: FontWeight.w900,
                  color: accent.withValues(alpha: dark ? 0.22 : 0.08),
                  height: 1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accentSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: dark ? Washi.ember : accent, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: fg),
                        ),
                        const SizedBox(height: 3),
                        Text(subtitle, style: textTheme.bodySmall?.copyWith(color: sub, height: 1.4)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios_rounded, size: 16, color: sub),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 퀴즈 화면 (카테고리 선택 → 문제 풀이)
// ---------------------------------------------------------------------------
class QuizHomePage extends StatefulWidget {
  const QuizHomePage({super.key, required this.mode});

  final StudyMode mode;

  @override
  State<QuizHomePage> createState() => _QuizHomePageState();
}

class _QuizHomePageState extends State<QuizHomePage> {
  static const _knowledgeStorageKey = 'quiz_knowledge_v1';
  static const _bookmarkStorageKey = 'study_bookmark_v1';

  final Map<String, bool> _selected = {};

  final Random _random = Random();
  bool _loading = true;
  String? _error;
  List<CategoryOption> _options = [];
  List<QuizItem> _activeQuiz = [];
  int _currentIndex = 0;
  bool _started = false;
  bool _onlyUnknown = false;
  String _selectedCategoryTitle = '';
  String? _activeOptionId;
  SharedPreferences? _prefs;
  Map<String, int> _knowledge = {};
  String? _bookmarkCategoryKey;
  int? _bookmarkIndex;
  bool _revealed = false;

  bool get _isInfinite => widget.mode == StudyMode.infinite;

  String get _modeTitle => switch (widget.mode) {
        StudyMode.test => '테스트',
        StudyMode.study => '공부',
        StudyMode.infinite => '무한지옥',
      };

  @override
  void initState() {
    super.initState();
    _loadKnowledge();
    _loadData();
  }

  Future<void> _loadKnowledge() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_knowledgeStorageKey);
    final parsed = <String, int>{};

    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          final value = entry.value;
          if (value is int) {
            parsed[entry.key] = value;
          } else if (value is String) {
            parsed[entry.key] = int.tryParse(value) ?? 0;
          }
        }
      } catch (_) {
        // Ignore broken cache and start fresh.
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _prefs = prefs;
      _knowledge = parsed;
    });
  }

  Future<void> _saveKnowledge() async {
    final prefs = _prefs;
    if (prefs == null) {
      return;
    }
    await prefs.setString(_knowledgeStorageKey, jsonEncode(_knowledge));
  }

  Future<void> _loadBookmark() async {
    final prefs = _prefs;
    if (prefs == null) {
      return;
    }
    final raw = prefs.getString(_bookmarkStorageKey);
    if (raw == null || raw.isEmpty) {
      return;
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final category = decoded['categoryKey']?.toString();
      final index = decoded['index'];
      final parsedIndex = index is int ? index : int.tryParse(index?.toString() ?? '');
      if (!mounted) {
        return;
      }
      setState(() {
        _bookmarkCategoryKey = category;
        _bookmarkIndex = parsedIndex;
      });
    } catch (_) {
      // Ignore corrupted bookmark data.
    }
  }

  Future<void> _saveBookmark(String categoryKey, int index) async {
    final prefs = _prefs;
    if (prefs == null) {
      return;
    }
    final payload = jsonEncode({
      'categoryKey': categoryKey,
      'index': index,
    });
    await prefs.setString(_bookmarkStorageKey, payload);
    if (!mounted) {
      return;
    }
    setState(() {
      _bookmarkCategoryKey = categoryKey;
      _bookmarkIndex = index;
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final raw = await rootBundle.loadString('data/jlpt_quiz_data2.json');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final map = <String, List<QuizItem>>{};

      for (final category in QuizCategory.values) {
        final list = (decoded[category.keyName] as List<dynamic>? ?? const []);
        map[category.keyName] = list
            .map((e) => QuizItem.fromJson(e as Map<String, dynamic>, category.keyName))
            .where((item) => item.surface.isNotEmpty && item.reading.isNotEmpty && (item.isKana || item.meaning.isNotEmpty))
            .toList();
      }

      final examRaw = await rootBundle.loadString('data/jlpt_kanzi_data.json');
      final examDecoded = jsonDecode(examRaw) as Map<String, dynamic>;

      final options = [..._buildExamOptions(examDecoded), ..._buildOptions(map)];

      setState(() {
        _options = options;
        for (final option in options) {
          _selected.putIfAbsent(option.id, () => false);
        }
        _loading = false;
      });
      await _loadBookmark();
    } catch (e) {
      setState(() {
        _loading = false;
        _error = '데이터 로딩 실패: $e';
      });
    }
  }

  String _sectionFor(String categoryKey) {
    if (categoryKey == 'hiragana' || categoryKey == 'katakana') {
      return '가나';
    }
    return categoryKey.substring(0, 2).toUpperCase(); // n5_kanji -> N5
  }

  // JLPT 시험대비: 전체 상용한자 2136자를 무작위로 섞어 22일치(100개씩, 마지막 36개)로
  // 나눈 jlpt_kanzi_data.json을 일차별 선택지로 만든다.
  // 지식(알아/몰라) 기록은 한자의 원래 레벨 카테고리(n5_kanji 등)와 공유된다.
  List<CategoryOption> _buildExamOptions(Map<String, dynamic> decoded) {
    int dayNumber(String key) => int.tryParse(key.replaceFirst('day_', '')) ?? 0;

    final dayKeys = decoded.keys.toList()
      ..sort((a, b) => dayNumber(a).compareTo(dayNumber(b)));

    final options = <CategoryOption>[];
    for (final key in dayKeys) {
      final list = (decoded[key] as List<dynamic>? ?? const []);
      final items = list.map((e) {
        final json = e as Map<String, dynamic>;
        final level = (json['level'] ?? '').toString().toLowerCase();
        final categoryKey = level.startsWith('n') ? '${level}_kanji' : 'n1_kanji';
        return QuizItem.fromJson(json, categoryKey);
      }).where((item) => item.surface.isNotEmpty && item.reading.isNotEmpty && item.meaning.isNotEmpty).toList();

      options.add(CategoryOption(
        id: 'exam#$key',
        label: '${dayNumber(key)}일차',
        categoryKey: 'exam_kanji',
        section: 'JLPT 시험대비',
        items: items,
        isWhole: false,
      ));
    }
    return options;
  }

  List<CategoryOption> _buildOptions(Map<String, List<QuizItem>> map) {
    final options = <CategoryOption>[];
    for (final category in QuizCategory.values) {
      final items = map[category.keyName] ?? const <QuizItem>[];
      final section = _sectionFor(category.keyName);
      final groupCount = kKanjiGroupCounts[category.keyName] ?? 1;

      if (groupCount <= 1) {
        // 분할하지 않는 카테고리(가나, 단어, N5 한자).
        options.add(CategoryOption(
          id: category.keyName,
          label: category.label,
          categoryKey: category.keyName,
          section: section,
          items: items,
          isWhole: true,
        ));
        continue;
      }

      // 레벨 전체 옵션.
      options.add(CategoryOption(
        id: '${category.keyName}#all',
        label: '${category.label} 전체',
        categoryKey: category.keyName,
        section: section,
        items: items,
        isWhole: true,
      ));

      // 그룹 옵션.
      final chunks = _chunk(items, groupCount);
      for (var i = 0; i < chunks.length; i++) {
        final marker = i < _kCircledNumbers.length ? _kCircledNumbers[i] : '${i + 1}';
        options.add(CategoryOption(
          id: '${category.keyName}#$i',
          label: '${category.label} $marker',
          categoryKey: category.keyName,
          section: section,
          items: chunks[i],
          isWhole: false,
        ));
      }
    }
    return options;
  }

  // 리스트를 거의 균등한 groups개의 묶음으로 순서대로 나눈다.
  List<List<QuizItem>> _chunk(List<QuizItem> items, int groups) {
    final result = <List<QuizItem>>[];
    final base = items.length ~/ groups;
    final remainder = items.length % groups;
    var start = 0;
    for (var i = 0; i < groups; i++) {
      final size = base + (i < remainder ? 1 : 0);
      result.add(items.sublist(start, start + size));
      start += size;
    }
    return result;
  }

  Future<void> _startQuiz() async {
    final selectedOptions = _options.where((o) => _selected[o.id] == true).toList();
    if (selectedOptions.isEmpty) {
      _showSnack('카테고리를 최소 1개 선택해 주세요.');
      return;
    }

    if (widget.mode == StudyMode.study && selectedOptions.length != 1) {
      _showSnack('공부 모드에서는 카테고리 1개만 선택해 주세요.');
      return;
    }

    final activeOptionId = selectedOptions.length == 1 ? selectedOptions.first.id : null;

    var pool = <QuizItem>[];
    for (final option in selectedOptions) {
      pool.addAll(option.items);
    }

    if (widget.mode == StudyMode.infinite) {
      // 무한지옥: 선택한 카테고리의 모든 단어를 '모르는 것'으로 간주하고 시작한다.
      if (pool.isEmpty) {
        _showSnack('선택한 카테고리에 단어가 없습니다.');
        return;
      }
      setState(() {
        _activeQuiz = pool;
        _activeOptionId = activeOptionId;
        _currentIndex = _random.nextInt(pool.length);
        _selectedCategoryTitle = selectedOptions.map((o) => o.label).join(' · ');
        _started = true;
        _revealed = false;
      });
      return;
    }

    if (_onlyUnknown) {
      pool = pool.where((item) => _itemKnowledge(item) == -1).toList();
    }

    if (pool.isEmpty) {
      _showSnack(_onlyUnknown ? '모르는 단어로 표시한 문제가 없습니다.' : '선택한 카테고리에 문제가 없습니다.');
      return;
    }

    if (widget.mode == StudyMode.test) {
      pool.shuffle(_random);
    }

    int startIndex = 0;
    if (widget.mode == StudyMode.study && selectedOptions.length == 1) {
      final selectedKey = activeOptionId;
      final hasBookmark = _bookmarkCategoryKey == selectedKey && _bookmarkIndex != null;
      if (hasBookmark && mounted) {
        final resume = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('책갈피 발견'),
              content: Text('이 카테고리는 ${_bookmarkIndex! + 1}번 문제부터 시작할 수 있어요.\n이어서 시작할까요?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('처음부터'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('이어하기'),
                ),
              ],
            );
          },
        );
        if (resume == true) {
          startIndex = _bookmarkIndex!.clamp(0, pool.length - 1);
        }
      }
    }

    setState(() {
      _activeQuiz = pool;
      _activeOptionId = activeOptionId;
      _currentIndex = startIndex;
      _selectedCategoryTitle = selectedOptions.map((o) => o.label).join(' · ');
      _started = true;
      _revealed = false;
    });
  }

  void _prevQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex -= 1;
        _revealed = false;
      });
    }
  }

  void _nextQuestion() {
    if (_activeQuiz.isEmpty) {
      return;
    }
    if (_currentIndex < _activeQuiz.length - 1) {
      setState(() {
        _currentIndex += 1;
        _revealed = false;
      });
      return;
    }
    _showSnack('마지막 문제입니다.');
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  bool _containsHangul(String text) {
    return RegExp(r'[가-힣]').hasMatch(text);
  }

  String _topKoreanMeanings(String raw, {int maxCount = 3}) {
    final parts = raw
        .split(RegExp(r'[;,|]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final seen = <String>{};
    final korean = <String>[];
    for (final p in parts) {
      if (!_containsHangul(p)) {
        continue;
      }
      if (seen.add(p)) {
        korean.add(p);
      }
      if (korean.length >= maxCount) {
        break;
      }
    }

    if (korean.isNotEmpty) {
      return korean.join(', ');
    }

    return parts.take(maxCount).join(', ');
  }

  List<String> _getAllKoreanMeanings(String raw) {
    final parts = raw
        .split(RegExp(r'[;,|]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final seen = <String>{};
    final korean = <String>[];
    for (final p in parts) {
      if (!_containsHangul(p)) {
        continue;
      }
      if (seen.add(p)) {
        korean.add(p);
      }
    }

    if (korean.isNotEmpty) {
      return korean;
    }

    return parts;
  }

  String? _verbClassDescription(String pos) {
    if (pos.contains('동사(1류)')) {
      return '1류 동사(오단동사): ます형에서 어간 끝이 여러 음으로 변형되는 동사';
    }
    if (pos.contains('동사(2류)')) {
      return '2류 동사(일단동사): ます를 떼고 る를 중심으로 규칙적으로 활용되는 동사';
    }
    if (pos.contains('동사(기타)')) {
      return '3류 동사(불규칙): する/くる 계열처럼 예외 활용하는 동사';
    }
    return null;
  }

  String _posShortLabel(String pos) {
    if (pos.contains('동사')) {
      return '동사';
    }
    if (pos.contains('명사')) {
      return '명사';
    }
    if (pos.contains('형용사')) {
      return '형용사';
    }
    return '기타';
  }

  (Color, Color) _posBadgeColors(String pos, ColorScheme scheme) {
    if (pos.contains('동사')) {
      return (scheme.primaryContainer, scheme.onPrimaryContainer);
    }
    if (pos.contains('명사')) {
      return (scheme.tertiaryContainer, scheme.onTertiaryContainer);
    }
    if (pos.contains('형용사')) {
      return scheme.brightness == Brightness.dark
          ? (const Color(0xFF4A3A1E), const Color(0xFFF0D9A8))
          : (Washi.amberSoft, Washi.amber);
    }
    return (scheme.surfaceContainerHighest, scheme.onSurfaceVariant);
  }

  String _itemKey(QuizItem item) {
    return '${item.categoryKey}|${item.surface}|${item.reading}';
  }

  int _itemKnowledge(QuizItem item) {
    final value = _knowledge[_itemKey(item)] ?? 1;
    return value == -1 ? -1 : 1;
  }

  Future<void> _toggleKnowledge(QuizItem item) async {
    final key = _itemKey(item);
    final current = _itemKnowledge(item);

    setState(() {
      _knowledge[key] = current == 1 ? -1 : 1;
    });

    await _saveKnowledge();
  }

  // 무한지옥: 모르는 단어 풀에서 복원 추출로 다음 단어를 뽑는다.
  // 현재 단어도 풀에 그대로 남아 있어 1/N 확률로 다시 등장할 수 있다.
  void _infiniteDrawNext() {
    if (_activeQuiz.isEmpty) {
      return;
    }
    setState(() {
      _currentIndex = _random.nextInt(_activeQuiz.length);
      _revealed = false;
    });
  }

  // 무한지옥: '확실히 알아!' → 풀에서 영구 제거 후 다음 단어로.
  Future<void> _infiniteMarkKnown() async {
    if (_activeQuiz.isEmpty) {
      return;
    }
    final item = _activeQuiz[_currentIndex];
    _knowledge[_itemKey(item)] = 1;
    await _saveKnowledge();
    if (!mounted) {
      return;
    }
    setState(() {
      _activeQuiz.removeAt(_currentIndex);
      _revealed = false;
      if (_activeQuiz.isNotEmpty) {
        _currentIndex = _random.nextInt(_activeQuiz.length);
      } else {
        _currentIndex = 0;
      }
    });
  }

  void _backToSetup() {
    setState(() {
      _started = false;
      _revealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context);
    final useDark = _isInfinite && _started;
    final theme = useDark ? buildInfiniteTheme(light) : light;

    final Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!)));
    } else if (_started) {
      body = _isInfinite ? _buildInfiniteView() : _buildQuizView();
    } else {
      body = _buildSetupView();
    }

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: _started ? '카테고리 선택으로' : '모드 선택으로',
            onPressed: () {
              if (_started) {
                _backToSetup();
              } else {
                Navigator.of(context).maybePop();
              }
            },
          ),
          title: Row(
            children: [
              if (_isInfinite)
                Icon(Icons.local_fire_department_rounded, color: useDark ? Washi.ember : Washi.ember, size: 22)
              else
                HankoMark(text: widget.mode == StudyMode.test ? '試' : '学', size: 26,
                    color: widget.mode == StudyMode.test ? Washi.indigo : Washi.moss),
              const SizedBox(width: 10),
              Text(_modeTitle),
            ],
          ),
        ),
        body: CenteredColumn(child: body),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 카테고리 선택
  // ---------------------------------------------------------------------------
  List<Widget> _buildCategorySections() {
    final sections = <String, List<CategoryOption>>{};
    for (final option in _options) {
      sections.putIfAbsent(option.section, () => []).add(option);
    }

    final widgets = <Widget>[];
    for (final entry in sections.entries) {
      final selectedCount = entry.value.where((o) => _selected[o.id] == true).length;
      widgets.add(SectionTitle(
        entry.key,
        trailing: selectedCount > 0
            ? Pill('$selectedCount 선택', background: Washi.indigoSoft, foreground: Washi.indigo)
            : null,
      ));
      widgets.add(const SizedBox(height: 10));
      widgets.add(Wrap(
        spacing: 8,
        runSpacing: 8,
        children: entry.value.map((option) {
          final selected = _selected[option.id] ?? false;
          return FilterChip(
            label: Text.rich(
              TextSpan(
                text: option.label,
                children: [
                  TextSpan(
                    text: '  ${option.count}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: selected ? Colors.white70 : Washi.inkSoft,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            labelStyle: TextStyle(color: selected ? Colors.white : Washi.ink),
            selected: selected,
            onSelected: (value) {
              setState(() {
                if (widget.mode == StudyMode.study) {
                  for (final key in _selected.keys) {
                    _selected[key] = false;
                  }
                  _selected[option.id] = value;
                } else {
                  _selected[option.id] = value;
                }
              });
            },
          );
        }).toList(),
      ));
      widgets.add(const SizedBox(height: 22));
    }
    return widgets;
  }

  Widget _buildSetupView() {
    final textTheme = Theme.of(context).textTheme;
    final selectedTotal = _options.where((o) => _selected[o.id] == true).fold<int>(0, (a, o) => a + o.count);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            // 칸 사이 여백 등 빈 공간을 눌러도 스크롤되도록 뷰포트 전체를 스크롤 영역으로 둔다.
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '카테고리 선택',
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.mode == StudyMode.study
                      ? '공부 모드에서는 카테고리 1개만 선택할 수 있습니다.'
                      : '여러 카테고리를 함께 선택할 수 있습니다.',
                  style: textTheme.bodyMedium?.copyWith(color: Washi.inkSoft),
                ),
                const SizedBox(height: 22),
                ..._buildCategorySections(),
                if (!_isInfinite)
                  Card(
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                      title: const Text('모르는 단어만', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: const Text('"한번 더 보자!"로 표시한 문제만 출제'),
                      value: _onlyUnknown,
                      onChanged: (value) {
                        setState(() {
                          _onlyUnknown = value;
                        });
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Washi.paperDeep.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('동사 분류 기준', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      _verbRule('1류', '오단동사', '書く, 読む'),
                      _verbRule('2류', '일단동사', '食べる, 見る'),
                      _verbRule('3류', '불규칙동사', 'する, 来る'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // 하단 고정 시작 버튼.
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: const BoxDecoration(
            color: Washi.paper,
            border: Border(top: BorderSide(color: Washi.line)),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('선택한 문제', style: textTheme.labelSmall?.copyWith(color: Washi.inkSoft)),
                      Text(
                        '$selectedTotal개',
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () async => _startQuiz(),
                  icon: Icon(_isInfinite ? Icons.local_fire_department_rounded : Icons.play_arrow_rounded),
                  label: const Text('시작하기'),
                  style: _isInfinite
                      ? FilledButton.styleFrom(backgroundColor: Washi.ember, foregroundColor: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _verbRule(String cls, String name, String example) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Pill(cls, background: Washi.indigoSoft, foreground: Washi.indigo),
          const SizedBox(width: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text('예: $example', style: const TextStyle(color: Washi.inkSoft)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 테스트 / 공부 화면
  // ---------------------------------------------------------------------------
  Widget _buildQuizView() {
    if (_activeQuiz.isEmpty) {
      return const Center(child: Text('문제가 없습니다.'));
    }

    final q = _activeQuiz[_currentIndex];
    final knowledge = _itemKnowledge(q);
    final unknown = knowledge == -1;
    final textTheme = Theme.of(context).textTheme;
    final hidden = widget.mode == StudyMode.test && !_revealed;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _selectedCategoryTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_currentIndex + 1} / ${_activeQuiz.length}',
                style: textTheme.labelLarge?.copyWith(color: Washi.inkSoft, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / _activeQuiz.length,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _FlashCard(
              item: q,
              hidden: hidden,
              accent: unknown ? Washi.vermilion : Washi.line,
              statusPill: unknown
                  ? const Pill('한번 더', background: Washi.vermilionSoft, foreground: Washi.vermilion, icon: Icons.replay_rounded)
                  : const Pill('알아요', background: Washi.mossSoft, foreground: Washi.moss, icon: Icons.check_rounded),
              onReveal: () => setState(() => _revealed = true),
              // 테스트 모드의 정답 공개 버튼은 마우스 이동을 줄이기 위해 하단 버튼 영역에 둔다.
              showRevealButton: widget.mode != StudyMode.test,
              answer: _buildAnswerWidgets(q),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => _toggleKnowledge(q),
                  icon: Icon(unknown ? Icons.check_circle_rounded : Icons.replay_rounded),
                  label: Text(unknown ? '확실히 알아!' : '한번 더 보자!'),
                  style: FilledButton.styleFrom(
                    backgroundColor: unknown ? Washi.mossSoft : Washi.vermilionSoft,
                    foregroundColor: unknown ? Washi.moss : Washi.vermilion,
                  ),
                ),
              ),
              if (widget.mode == StudyMode.study) ...[
                const SizedBox(width: 10),
                IconButton.outlined(
                  tooltip: '현재 위치 책갈피',
                  style: IconButton.styleFrom(
                    side: const BorderSide(color: Washi.line),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.all(14),
                  ),
                  onPressed: () async {
                    await _saveBookmark(_activeOptionId ?? q.categoryKey, _currentIndex);
                    if (!mounted) {
                      return;
                    }
                    _showSnack('책갈피 저장: ${_currentIndex + 1}번');
                  },
                  icon: const Icon(Icons.bookmark_add_rounded, color: Washi.indigo),
                ),
              ],
            ],
          ),
          if (widget.mode == StudyMode.test) ...[
            const SizedBox(height: 10),
            // "다음 문제" 바로 위에 두어 공개 → 다음 → 공개 흐름에서 마우스 이동을 최소화한다.
            FilledButton.icon(
              onPressed: _revealed ? null : () => setState(() => _revealed = true),
              icon: Icon(_revealed ? Icons.visibility_off_rounded : Icons.visibility_rounded),
              label: Text(_revealed ? '정답 공개됨' : '정답 공개'),
              style: FilledButton.styleFrom(
                backgroundColor: Washi.ink,
                foregroundColor: Washi.cream,
                disabledBackgroundColor: Washi.paperDeep,
                disabledForegroundColor: Washi.inkSoft,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _currentIndex > 0 ? _prevQuestion : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                  label: const Text('이전'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _nextQuestion,
                  icon: const Icon(Icons.chevron_right_rounded),
                  iconAlignment: IconAlignment.end,
                  label: const Text('다음 문제'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 정답(읽기/뜻/품사) 표시 위젯. 일반 모드와 무한지옥 모드가 공유한다.
  List<Widget> _buildAnswerWidgets(QuizItem q) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final shortMeaning = _topKoreanMeanings(q.meaning);
    final verbClass = _verbClassDescription(q.pos);

    Widget readingRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 44,
              child: Text(
                label,
                style: textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: Text(value, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, height: 1.3)),
            ),
          ],
        ),
      );
    }

    return [
      if (q.isKanji) ...[
        if (q.onyomi != null && q.onyomi!.isNotEmpty) readingRow('음독', q.onyomi!),
        if (q.kunyomi != null && q.kunyomi!.isNotEmpty) readingRow('훈독', q.kunyomi!),
      ] else if (q.isKana) ...[
        readingRow('발음', q.reading),
      ] else ...[
        readingRow('읽기', q.reading),
      ],
      if (!q.isKana) ...[
        Divider(height: 24, color: scheme.outline),
      ],
      if (q.isKanji) ...[
        ..._getAllKoreanMeanings(q.meaning).map(
          (m) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 9, right: 10),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(color: scheme.secondary, shape: BoxShape.circle),
                  ),
                ),
                Expanded(child: Text(m, style: textTheme.titleMedium?.copyWith(height: 1.4))),
              ],
            ),
          ),
        ),
      ] else if (!q.isKana) ...[
        Builder(builder: (context) {
          final (bg, fg) = _posBadgeColors(q.pos, scheme);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Pill(_posShortLabel(q.pos), background: bg, foreground: fg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(shortMeaning, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, height: 1.3)),
              ),
            ],
          );
        }),
        if (verbClass != null) ...[
          const SizedBox(height: 10),
          Text(verbClass, style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant, height: 1.5)),
        ],
      ],
    ];
  }

  // ---------------------------------------------------------------------------
  // 무한지옥 화면
  // ---------------------------------------------------------------------------
  Widget _buildInfiniteView() {
    if (_activeQuiz.isEmpty) {
      return _buildInfiniteDone();
    }

    final q = _activeQuiz[_currentIndex];
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _selectedCategoryTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              Pill(
                '남은 단어 ${_activeQuiz.length}',
                background: Washi.ember,
                foreground: Colors.white,
                icon: Icons.local_fire_department_rounded,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _FlashCard(
              item: q,
              hidden: !_revealed,
              accent: Washi.ember,
              dark: true,
              onReveal: () => setState(() => _revealed = true),
              showRevealButton: false,
              answer: _buildAnswerWidgets(q),
            ),
          ),
          const SizedBox(height: 14),
          // 판정 버튼 바로 위에 두어 공개 → 판정 → 공개 흐름에서 마우스 이동을 최소화한다.
          FilledButton.icon(
            onPressed: _revealed ? null : () => setState(() => _revealed = true),
            icon: Icon(_revealed ? Icons.visibility_off_rounded : Icons.visibility_rounded),
            label: Text(_revealed ? '정답 공개됨' : '정답 공개'),
            style: FilledButton.styleFrom(
              backgroundColor: Washi.ember,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Washi.nightLine,
              disabledForegroundColor: Washi.cream.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 10),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: _revealed ? 1 : 0.35,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _revealed ? _infiniteDrawNext : null,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('아직 몰라'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Washi.cream,
                      side: const BorderSide(color: Washi.cream, width: 1.2),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _revealed ? _infiniteMarkKnown : null,
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('확실히 알아!'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF8FB07E),
                      foregroundColor: Washi.night,
                      disabledBackgroundColor: Washi.nightLine,
                      disabledForegroundColor: Washi.cream.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfiniteDone() {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HankoMark(text: '完', size: 88, color: Washi.ember),
            const SizedBox(height: 28),
            Text(
              '무한지옥 탈출!',
              style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              '모르는 단어를 모두 정복했어요.',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(color: const Color(0xFFB9ACA0)),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _backToSetup,
              icon: const Icon(Icons.grid_view_rounded),
              label: const Text('카테고리 선택으로'),
              style: FilledButton.styleFrom(backgroundColor: Washi.ember, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// 문제 카드: 큰 글자 + (정답 가림 버튼 | 정답 영역)
class _FlashCard extends StatelessWidget {
  const _FlashCard({
    required this.item,
    required this.hidden,
    required this.accent,
    required this.onReveal,
    required this.answer,
    this.statusPill,
    this.dark = false,
    this.showRevealButton = true,
  });

  final QuizItem item;
  final bool hidden;
  final Color accent;
  final VoidCallback onReveal;
  final List<Widget> answer;
  final Widget? statusPill;
  final bool dark;
  final bool showRevealButton; // false면 카드 안에는 힌트 문구만 표시 (버튼은 바깥에 있음)

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final surfaceSize = item.surface.length <= 2 ? 88.0 : (item.surface.length <= 5 ? 56.0 : 40.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: dark ? Washi.nightCard : Washi.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent, width: accent == Washi.line ? 1 : 1.6),
        boxShadow: [
          BoxShadow(
            color: (dark ? Colors.black : Washi.ink).withValues(alpha: dark ? 0.35 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 배경 장식: 옅은 큰 글자.
          Positioned(
            right: -10,
            top: -24,
            child: Text(
              item.isKanji ? '漢' : (item.isKana ? 'あ' : '語'),
              style: TextStyle(
                fontSize: 160,
                fontWeight: FontWeight.w900,
                color: accent.withValues(alpha: dark ? 0.08 : 0.05),
                height: 1,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Pill(
                      _categoryLabel(item.categoryKey),
                      background: scheme.surfaceContainerHighest,
                      foreground: scheme.onSurfaceVariant,
                    ),
                    const Spacer(),
                    if (statusPill != null) statusPill!,
                  ],
                ),
                const SizedBox(height: 28),
                Center(
                  child: SelectableText(
                    item.surface,
                    textAlign: TextAlign.center,
                    style: textTheme.displayMedium?.copyWith(
                      fontSize: surfaceSize,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      letterSpacing: item.surface.length <= 2 ? 4 : 0,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: hidden
                      ? Column(
                          key: const ValueKey('hidden'),
                          children: [
                            Divider(color: scheme.outline),
                            const SizedBox(height: 18),
                            if (showRevealButton) ...[
                              FilledButton.icon(
                                onPressed: onReveal,
                                icon: const Icon(Icons.visibility_rounded),
                                label: const Text('정답 공개'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: dark ? Washi.ember : Washi.ink,
                                  foregroundColor: dark ? Colors.white : Washi.cream,
                                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ] else ...[
                              Icon(Icons.lock_outline_rounded, color: scheme.onSurfaceVariant, size: 28),
                              const SizedBox(height: 8),
                            ],
                            Text(
                              '먼저 떠올려 본 뒤 확인하세요',
                              style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        )
                      : Column(
                          key: const ValueKey('answer'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: answer,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _categoryLabel(String key) {
    for (final c in QuizCategory.values) {
      if (c.keyName == key) return c.label;
    }
    return key;
  }
}
