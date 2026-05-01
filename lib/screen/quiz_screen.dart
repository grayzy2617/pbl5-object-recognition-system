import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart'; // MỚI: Thư viện phát mp3
import 'package:flutter_tts/flutter_tts.dart'; // MỚI: Thư viện đọc tiếng Anh
import '../services/api_service.dart';
import '../services/auth_provider.dart'; // Đổi lại thành đường dẫn provider của bạn nếu cần

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> _answers = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  Map<String, dynamic>? _result;

  // MỚI: Khởi tạo biến cho Audio và TTS
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts(); // Khởi tạo giọng đọc
    _loadQuiz();
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ khi tắt màn hình
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  // MỚI: Cấu hình giọng đọc tiếng Anh
  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5); // Tốc độ đọc vừa phải
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  // MỚI: Hàm phát âm từ vựng
  Future<void> _speakWord(String word) async {
    await _flutterTts.speak(word);
  }

  // MỚI: Hàm phát tiếng Ting / Tè tè
  Future<void> _playSound(bool isCorrect) async {
    // Note: AssetSource tự động tìm trong thư mục 'assets/'
    String audioPath = isCorrect ? 'sounds/check.mp3' : 'sounds/fail.mp3';
    await _audioPlayer.play(AssetSource(audioPath));
  }

  Future<void> _loadQuiz() async {
    final result = await ApiService.generateQuiz(limit: 5);

    if (result['success'] && mounted) {
      final questions = List<Map<String, dynamic>>.from(result['data'] ?? []);
      setState(() {
        _questions = questions;
        _answers = List.generate(questions.length, (_) => {});
        _isLoading = false;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Lỗi tải câu hỏi')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitQuiz() async {
    if (_answers.any((a) => a.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng trả lời tất cả các câu hỏi')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final submissionAnswers = <Map<String, dynamic>>[];
    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final selectedId = _answers[i]['selected_id'];
      submissionAnswers.add({
        'dict_id': question['dict_id'],
        'is_correct': selectedId == question['correct_id'],
      });
    }

    final result = await ApiService.submitQuiz(submissionAnswers);

    if (result['success'] && mounted) {
      setState(() {
        _result = result;
        _isSubmitting = false;
      });
      // Cập nhật điểm cho user
      context.read<AuthProvider>().fetchUserProfile();
    } else if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['error'] ?? 'Lỗi gửi bài')));
    }
  }

  // CẬP NHẬT: Thêm kiểm tra đúng/sai để phát âm thanh
  void _handleAnswerSelect(int optionId) {
    if (_answers[_currentQuestionIndex].isEmpty) {
      final currentQuestion = _questions[_currentQuestionIndex];
      final isCorrect = optionId == currentQuestion['correct_id'];

      _playSound(isCorrect); // Gọi hàm phát âm thanh

      setState(() {
        _answers[_currentQuestionIndex] = {'selected_id': optionId};
      });
    }
  }

  void _goToNextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    }
  }

  void _goToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
    }
  }

  void _resetQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _answers = List.generate(_questions.length, (_) => {});
      _result = null;
      _isLoading = true;
    });
    _loadQuiz(); // Tải lại câu hỏi mới
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_result != null) {
      return _buildResultScreen();
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.help_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Không có câu hỏi nào',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() => _isLoading = true);
                  _loadQuiz();
                },
                child: const Text('Tải lại'),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final currentAnswer = _answers[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz'), elevation: 0),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            minHeight: 4,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Câu ${_currentQuestionIndex + 1}/${_questions.length}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (currentAnswer.isNotEmpty)
                  Chip(
                    label: const Text('Đã trả lời'),
                    backgroundColor: Colors.green[100],
                  ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Từ vựng:',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        // CẬP NHẬT: Thêm icon loa và phát âm thanh khi bấm
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                currentQuestion['question_en'] ?? '',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.volume_up, size: 32),
                              color: Theme.of(context).primaryColor,
                              onPressed: () => _speakWord(
                                currentQuestion['question_en'] ?? '',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Nghĩa của từ này là:',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...(currentQuestion['options'] as List<dynamic>?)
                          ?.asMap()
                          .entries
                          .map((entry) {
                            final option = entry.value as Map<String, dynamic>;
                            final isSelected =
                                currentAnswer['selected_id'] == option['id'];

                            // CẬP NHẬT: Đổi màu viền dựa vào đúng/sai nếu đã chọn đáp án
                            Color borderColor = Colors.grey[300]!;
                            Color bgColor = Colors.grey[100]!;

                            if (currentAnswer.isNotEmpty) {
                              if (option['id'] ==
                                  currentQuestion['correct_id']) {
                                borderColor =
                                    Colors.green; // Đáp án đúng hiện xanh
                                bgColor = Colors.green.withOpacity(0.1);
                              } else if (isSelected) {
                                borderColor = Colors
                                    .red; // Đáp án sai mà mình chọn thì hiện đỏ
                                bgColor = Colors.red.withOpacity(0.1);
                              }
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () => _handleAnswerSelect(option['id']),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    border: Border.all(
                                      color: borderColor,
                                      width:
                                          isSelected ||
                                              (currentAnswer.isNotEmpty &&
                                                  option['id'] ==
                                                      currentQuestion['correct_id'])
                                          ? 2
                                          : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: borderColor,
                                          ),
                                        ),
                                        child: isSelected
                                            ? Center(
                                                child: Container(
                                                  width: 12,
                                                  height: 12,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: borderColor,
                                                  ),
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          option['text_vn'] ?? '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : null,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          })
                          .toList() ??
                      [],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentQuestionIndex == 0
                        ? null
                        : _goToPreviousQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                    ),
                    child: const Text('Quay lại'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentQuestionIndex == _questions.length - 1
                        ? null
                        : _goToNextQuestion,
                    child: const Text('Tiếp theo'),
                  ),
                ),
              ],
            ),
          ),
          if (_currentQuestionIndex == _questions.length - 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text('Nộp bài'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final correct = _result!['correct'] as int? ?? 0;
    final total = _result!['total'] as int? ?? 0;
    final gainedScore = _result!['gained_score'] as int? ?? 0;
    final accuracy = total > 0
        ? (correct / total * 100).toStringAsFixed(1)
        : '0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green[100],
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 60,
                  color: Colors.green[600],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Bài quiz hoàn thành!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _ResultCard(
                      icon: Icons.check,
                      label: 'Câu đúng',
                      value: '$correct/$total',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ResultCard(
                      icon: Icons.percent,
                      label: 'Độ chính xác',
                      value: '$accuracy%',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ResultCard(
                      icon: Icons.star,
                      label: 'Điểm nhận',
                      value: '$gainedScore',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Tổng điểm của bạn',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${_result!['total_score'] ?? 0}',
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _resetQuiz,
                  child: const Text('Làm lại'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[400],
                  ),
                  child: const Text('Quay lại'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ResultCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
