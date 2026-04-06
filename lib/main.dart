import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JLPT Quiz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ModeSelectPage(),
    );
  }
}

enum StudyMode { test, study }

enum QuizCategory {
  n5Kanji('N5 한자', 'n5_kanji'),
  n4Kanji('N4 한자', 'n4_kanji'),
  n3Kanji('N3 한자', 'n3_kanji'),
  n2Kanji('N2 한자', 'n2_kanji'),
  n5Word('N5 단어', 'n5_word'),
  n4Word('N4 단어', 'n4_word'),
  n3Word('N3 단어', 'n3_word');

  const QuizCategory(this.label, this.keyName);
  final String label;
  final String keyName;
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

class ModeSelectPage extends StatelessWidget {
  const ModeSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'JLPT 공부',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 16),
                const Text(
                  '모드를 선택하세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const QuizHomePage(mode: StudyMode.test),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shuffle),
                  label: const Text('테스트 (무작위)'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const QuizHomePage(mode: StudyMode.study),
                      ),
                    );
                  },
                  icon: const Icon(Icons.menu_book),
                  label: const Text('공부 (순서대로)'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuizHomePage extends StatefulWidget {
  const QuizHomePage({super.key, required this.mode});

  final StudyMode mode;

  @override
  State<QuizHomePage> createState() => _QuizHomePageState();
}

class _QuizHomePageState extends State<QuizHomePage> {
  static const _knowledgeStorageKey = 'quiz_knowledge_v1';
  static const _bookmarkStorageKey = 'study_bookmark_v1';

  final Map<QuizCategory, bool> _selected = {
    for (final c in QuizCategory.values) c: false,
  };

  final Random _random = Random();
  bool _loading = true;
  String? _error;
  Map<String, List<QuizItem>> _dataByCategory = {};
  List<QuizItem> _activeQuiz = [];
  int _currentIndex = 0;
  bool _started = false;
  bool _onlyUnknown = false;
  String _selectedCategoryTitle = '';
  SharedPreferences? _prefs;
  Map<String, int> _knowledge = {};
  String? _bookmarkCategoryKey;
  int? _bookmarkIndex;

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
      final raw = await rootBundle.loadString('data/jlpt_quiz_data.json');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final map = <String, List<QuizItem>>{};

      for (final category in QuizCategory.values) {
        final list = (decoded[category.keyName] as List<dynamic>? ?? const []);
        map[category.keyName] = list
            .map((e) => QuizItem.fromJson(e as Map<String, dynamic>, category.keyName))
            .where((item) => item.surface.isNotEmpty && item.reading.isNotEmpty && item.meaning.isNotEmpty)
            .toList();
      }

      setState(() {
        _dataByCategory = map;
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

  Future<void> _startQuiz() async {
    final selectedCategories = _selected.entries.where((e) => e.value).map((e) => e.key).toList();
    if (selectedCategories.isEmpty) {
      _showSnack('카테고리를 최소 1개 선택해 주세요.');
      return;
    }

    if (widget.mode == StudyMode.study && selectedCategories.length != 1) {
      _showSnack('공부 모드에서는 카테고리 1개만 선택해 주세요.');
      return;
    }

    var pool = <QuizItem>[];
    for (final category in selectedCategories) {
      pool.addAll(_dataByCategory[category.keyName] ?? const []);
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
    if (widget.mode == StudyMode.study && selectedCategories.length == 1) {
      final selectedKey = selectedCategories.first.keyName;
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
      _currentIndex = startIndex;
      _selectedCategoryTitle = selectedCategories.map((c) => c.label).join(' · ');
      _started = true;
    });
  }

  void _prevQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex -= 1;
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
        .split(RegExp(r'[;,/|]'))
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
      return 'v';
    }
    if (pos.contains('명사')) {
      return 'n';
    }
    if (pos.contains('형용사')) {
      return 'adj';
    }
    return 'etc';
  }

  Color _posBadgeColor(String pos, ColorScheme scheme) {
    if (pos.contains('동사')) {
      return Colors.blue.shade100;
    }
    if (pos.contains('명사')) {
      return Colors.green.shade100;
    }
    if (pos.contains('형용사')) {
      return Colors.orange.shade100;
    }
    return scheme.surfaceContainerHighest;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!)))
              : _started
                  ? _buildQuizView()
                  : _buildSetupView(),
    );
  }

  Widget _buildSetupView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          const Text('카테고리 선택', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: QuizCategory.values.map((category) {
              final count = _dataByCategory[category.keyName]?.length ?? 0;
              return FilterChip(
                label: Text('${category.label} ($count)'),
                selected: _selected[category] ?? false,
                onSelected: (value) {
                  setState(() {
                    if (widget.mode == StudyMode.study) {
                      for (final c in QuizCategory.values) {
                        _selected[c] = false;
                      }
                      _selected[category] = value;
                    } else {
                      _selected[category] = value;
                    }
                  });
                },
              );
            }).toList(),
          ),
          if (widget.mode == StudyMode.study) ...[
            const SizedBox(height: 8),
            const Text('공부 모드에서는 카테고리 1개만 선택할 수 있습니다.'),
          ],
          const SizedBox(height: 20),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('모르는 단어만'),
            subtitle: const Text('체크하면 모르는 단어로 표시한 문제만 출제'),
            value: _onlyUnknown,
            onChanged: (value) {
              setState(() {
                _onlyUnknown = value;
              });
            },
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () async => _startQuiz(),
            child: const Text('시작하기'),
          ),
          const SizedBox(height: 16),
          const Text('동사 분류 기준', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('1류: 오단동사 (예: 書く, 読む)'),
          const Text('2류: 일단동사 (예: 食べる, 見る)'),
          const Text('3류: 불규칙동사 (예: する, 来る)'),
        ],
      ),
    );
  }

  Widget _buildQuizView() {
    if (_activeQuiz.isEmpty) {
      return const Center(child: Text('문제가 없습니다.'));
    }

    final q = _activeQuiz[_currentIndex];
    final shortMeaning = _topKoreanMeanings(q.meaning);
    final verbClass = _verbClassDescription(q.pos);
    final knowledge = _itemKnowledge(q);

    final bgColor = switch (knowledge) {
      1 => Colors.green.shade50,
      -1 => Colors.red.shade50,
      _ => Theme.of(context).colorScheme.surface,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Text(
              _selectedCategoryTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '문제 ${_currentIndex + 1} / ${_activeQuiz.length}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => _toggleKnowledge(q),
                  icon: Icon(knowledge == 1 ? Icons.check_circle : Icons.error),
                  label: Text(knowledge == 1 ? '확실히 알아!' : '한번 더 보자!'),
                  style: FilledButton.styleFrom(
                    backgroundColor: knowledge == 1 ? Colors.green.shade600 : Colors.red.shade600,
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                if (widget.mode == StudyMode.study) ...[
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: '현재 위치 책갈피',
                    onPressed: () async {
                      await _saveBookmark(q.categoryKey, _currentIndex);
                      if (!mounted) {
                        return;
                      }
                      _showSnack('책갈피 저장: ${_currentIndex + 1}번');
                    },
                    icon: const Icon(Icons.bookmark_add),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            Text(q.surface, style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (q.isKanji) ...[
              if (q.onyomi != null && q.onyomi!.isNotEmpty)
                Text('음독: ${q.onyomi}', style: const TextStyle(fontSize: 20)),
              if (q.kunyomi != null && q.kunyomi!.isNotEmpty)
                Text('훈독: ${q.kunyomi}', style: const TextStyle(fontSize: 20)),
            ] else ...[
              Text('읽기: ${q.reading}', style: const TextStyle(fontSize: 22)),
            ],
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _posBadgeColor(q.pos, Theme.of(context).colorScheme),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _posShortLabel(q.pos),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(shortMeaning, style: const TextStyle(fontSize: 20)),
                ),
              ],
            ),
            if (verbClass != null) ...[
              const SizedBox(height: 8),
              Text(verbClass, style: const TextStyle(fontSize: 15)),
            ],
            if (q.isKanji && q.relatedKanji.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('관련 단어', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...List.generate(
                q.relatedKanji.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${q.relatedKanji[i]} (${i < q.relatedReading.length ? q.relatedReading[i] : ""}) - ${i < q.relatedMeaning.length ? q.relatedMeaning[i] : ""}',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ],
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _prevQuestion,
                    child: const Text('이전문제'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _nextQuestion,
                    child: const Text('다음문제'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _started = false;
                  });
                },
                child: const Text('분류 다시 선택'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
