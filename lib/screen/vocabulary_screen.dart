import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/api_service.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _vocabulary = [];
  List<Map<String, dynamic>> _filteredVocabulary = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();
  late TabController _tabController;
  final _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initTts();
    _loadVocabulary();
    _searchController.addListener(_filterVocabulary);
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speakWord(String word) async {
    await _flutterTts.speak(word);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _loadVocabulary() async {
    final result = await ApiService.getDictionary();

    if (result['success'] && mounted) {
      setState(() {
        _vocabulary = List<Map<String, dynamic>>.from(result['data'] ?? []);
        _filteredVocabulary = _vocabulary;
        _isLoading = false;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Lỗi tải từ điển')),
      );
      setState(() => _isLoading = false);
    }
  }

  void _filterVocabulary() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredVocabulary = _vocabulary;
      } else {
        _filteredVocabulary = _vocabulary.where((item) {
          final enMatch = (item['ai_label'] ?? '').toLowerCase().contains(
            query,
          );
          final viMatch = (item['name_vn'] ?? '').toLowerCase().contains(query);
          return enMatch || viMatch;
        }).toList();
      }
    });
  }

  // CẬP NHẬT: Hàm phát âm thanh chung, nhận loại âm thanh truyền vào
  Future<void> _playSound(String type) async {
    try {
      String audioPath = 'sounds/beep.mp3'; // Mặc định lật thẻ
      if (type == 'correct') {
        audioPath = 'sounds/check.mp3';
      } else if (type == 'wrong') {
        audioPath = 'sounds/fail.mp3';
      }
      await _audioPlayer.play(AssetSource(audioPath));
    } catch (e) {
      // Silently handle
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Từ điển'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Danh sách'),
            Tab(icon: Icon(Icons.school), text: 'Học Flashcard'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildListTab(), _buildFlashcardTab()],
            ),
    );
  }

  Widget _buildListTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SearchBar(
            controller: _searchController,
            hintText: 'Tìm kiếm từ vựng...',
            leading: const Icon(Icons.search),
            trailing: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterVocabulary();
                  },
                ),
            ],
          ),
        ),
        if (_filteredVocabulary.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Tìm thấy ${_filteredVocabulary.length} từ',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ),
        Expanded(
          child: _filteredVocabulary.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Không tìm thấy từ nào',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredVocabulary.length,
                  itemBuilder: (context, index) {
                    final item = _filteredVocabulary[index];
                    return _buildVocabularyCard(item);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildVocabularyCard(Map<String, dynamic> item) {
    final isDangerous = item['is_dangerous'] == 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item['ai_label'] ?? 'Unknown',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up, size: 20),
                        color: Theme.of(context).primaryColor,
                        onPressed: () => _speakWord(item['ai_label'] ?? ''),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.only(left: 8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['name_vn'] ?? '',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            if (isDangerous)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, size: 16, color: Colors.red[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Nguy hiểm',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[600],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashcardTab() {
    if (_vocabulary.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không có từ vựng nào',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return FlashcardLearner(
      vocabulary: _vocabulary,
      onPlaySound: _playSound, // Truyền hàm playSound đã được cập nhật
      onSpeak: _speakWord,
    );
  }
}

class FlashcardLearner extends StatefulWidget {
  final List<Map<String, dynamic>> vocabulary;
  final Function(String) onPlaySound; // Sửa kiểu Function để truyền string
  final Function(String) onSpeak;

  const FlashcardLearner({
    super.key,
    required this.vocabulary,
    required this.onPlaySound,
    required this.onSpeak,
  });

  @override
  State<FlashcardLearner> createState() => _FlashcardLearnerState();
}

class _FlashcardLearnerState extends State<FlashcardLearner>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _flipController;

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';
  bool? _isPronunciationCorrect;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    _speech.cancel();
    super.dispose();
  }

  void _resetSpeechState() {
    if (_isListening) _speech.stop();
    setState(() {
      _isListening = false;
      _recognizedText = '';
      _isPronunciationCorrect = null;
    });
  }

  void _checkPronunciation(String targetWord) {
    if (_recognizedText.isEmpty) return;

    String cleanTarget = targetWord
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .toLowerCase()
        .trim();
    String cleanRecognized = _recognizedText
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .toLowerCase()
        .trim();

    bool isCorrect = (cleanTarget == cleanRecognized);

    setState(() {
      _isPronunciationCorrect = isCorrect;
    });

    // Phát âm thanh tương ứng
    if (isCorrect) {
      widget.onPlaySound('correct');
    } else {
      widget.onPlaySound('wrong');
    }
  }

  void _toggleListening(String targetWord) async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
            _checkPronunciation(targetWord);
          }
        },
        onError: (error) {
          setState(() => _isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi Micro: ${error.errorMsg}')),
          );
        },
      );

      if (available) {
        setState(() {
          _isListening = true;
          _recognizedText = '';
          _isPronunciationCorrect = null;
        });
        _speech.listen(
          onResult: (result) {
            setState(() {
              _recognizedText = result.recognizedWords;
            });
          },
          localeId: 'en_US',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chưa cấp quyền Micro hoặc thiết bị không hỗ trợ'),
          ),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      _checkPronunciation(targetWord);
    }
  }

  void _toggleFlip() {
    _resetSpeechState();
    if (_flipController.isCompleted) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    widget.onPlaySound('flip'); // Truyền chuỗi 'flip' để báo lật thẻ
  }

  void _nextCard() {
    if (_currentIndex < widget.vocabulary.length - 1) {
      _resetSpeechState();
      _flipController.reset();
      setState(() => _currentIndex++);
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      _resetSpeechState();
      _flipController.reset();
      setState(() => _currentIndex--);
    }
  }

  Widget _buildCardContent(Map<String, dynamic> item, bool isFront) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isFront ? 'Tiếng Anh' : 'Tiếng Việt',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),

        if (isFront) ...[
          // MẶT TRƯỚC (TIẾNG ANH)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  item['ai_label'] ?? '',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up, size: 28),
                color: Theme.of(context).primaryColor,
                onPressed: () => widget.onSpeak(item['ai_label'] ?? ''),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Cụm Nút thu âm & Kết quả
          Column(
            children: [
              GestureDetector(
                onTap: () => _toggleListening(item['ai_label'] ?? ''),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening ? Colors.red[100] : Colors.blue[50],
                    border: Border.all(
                      color: _isListening ? Colors.red : Colors.blue,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.red : Colors.blue,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_isListening)
                const Text(
                  'Đang nghe...',
                  style: TextStyle(
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                ),

              if (_recognizedText.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Bạn đọc: $_recognizedText',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                if (_isPronunciationCorrect != null)
                  Text(
                    _isPronunciationCorrect! ? 'Chính xác! 🎉' : 'Chưa đúng!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _isPronunciationCorrect!
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
              ],
            ],
          ),

          if (item['is_dangerous'] == 1)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, size: 16, color: Colors.red[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Nguy hiểm',
                      style: TextStyle(
                        color: Colors.red[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ] else ...[
          // MẶT SAU (TIẾNG VIỆT)
          Text(
            item['name_vn'] ?? '',
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.touch_app, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              'Chạm để lật',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = widget.vocabulary[_currentIndex];

    return Column(
      children: [
        // Thanh Process Bar (Không cuộn)
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_currentIndex + 1}/${widget.vocabulary.length}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / widget.vocabulary.length,
                      minHeight: 6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // FIX LỖI OVERFLOW: Bọc phần thẻ và nút vào SingleChildScrollView
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 24,
              ), // Đệm dưới cùng để không bị che khuất
              child: IntrinsicHeight(
                // Ép thẻ và nút bấm thành một khối cố định nếu màn hình to
                child: Column(
                  children: [
                    // Khung thẻ Flashcard
                    GestureDetector(
                      onTap: _toggleFlip,
                      child: AnimatedBuilder(
                        animation: _flipController,
                        builder: (context, child) {
                          final angle = _flipController.value * math.pi;
                          final isFront = _flipController.value < 0.5;

                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(angle),
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              padding: const EdgeInsets.all(
                                16,
                              ), // Thêm padding trong khung thẻ
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: isFront
                                  ? _buildCardContent(currentItem, true)
                                  : Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..rotateY(math.pi),
                                      child: _buildCardContent(
                                        currentItem,
                                        false,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Khung thông tin và Nút bấm (Quay lại / Tiếp)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info,
                                  color: Colors.blue[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Chạm nút Loa để nghe, chạm nút Micro để luyện đọc.',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.blue[600]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _currentIndex == 0
                                      ? null
                                      : _previousCard,
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text('Trước'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed:
                                      _currentIndex ==
                                          widget.vocabulary.length - 1
                                      ? null
                                      : _nextCard,
                                  icon: const Icon(Icons.arrow_forward),
                                  label: const Text('Tiếp'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
