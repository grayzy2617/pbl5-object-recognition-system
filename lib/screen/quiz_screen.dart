import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../theme/theme_colors.dart';
import '../theme/custom_styles.dart';
import 'package:confetti/confetti.dart';

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

  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  late ConfettiController _confettiController;
  @override
  void initState() {
    super.initState();
    // THÊM DÒNG NÀY: Khởi tạo pháo hoa bắn trong 3 giây
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _initTts();
    _loadQuiz();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _flutterTts.stop();
    // THÊM DÒNG NÀY: Xóa controller khi đóng màn hình
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speakWord(String word) async {
    await _flutterTts.speak(word);
  }

  Future<void> _playSound(bool isCorrect) async {
    String audioPath = isCorrect ? 'sounds/check.mp3' : 'sounds/fail.mp3';
    await _audioPlayer.play(AssetSource(audioPath));
  }

  Future<void> _playApplauseSound() async {
    await _audioPlayer
        .stop(); // Dừng các âm thanh tít tít cũ (nếu có) để nhường chỗ cho tiếng vỗ tay
    await _audioPlayer.play(AssetSource('sounds/applause.mp3'));
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
      // 2. GỌI ÂM THANH VỖ TAY Ở ĐÂY
      _playApplauseSound();
      // 3. BẮN PHÁO HOA Ở ĐÂY
      _confettiController.play();
      setState(() {
        _result = result;
        _isSubmitting = false;
      });
      context.read<AuthProvider>().fetchUserProfile();
    } else if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['error'] ?? 'Lỗi gửi bài')));
    }
  }

  void _handleAnswerSelect(int optionId) {
    if (_answers[_currentQuestionIndex].isEmpty) {
      final currentQuestion = _questions[_currentQuestionIndex];
      final isCorrect = optionId == currentQuestion['correct_id'];

      _playSound(isCorrect);

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
    _loadQuiz();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: MagicSkyColors.backgroundGradient,
          ),
          child: const Center(
            child: CircularProgressIndicator(color: MagicSkyColors.primaryBlue),
          ),
        ),
      );
    }

    if (_result != null) {
      return _buildResultScreen();
    }

    if (_questions.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: MagicSkyColors.backgroundGradient,
          ),
          child: EmptyState(
            icon: Icons.help_outline,
            title: 'Không có câu hỏi',
            subtitle: 'Không thể tải câu hỏi lúc này',
            onRetry: () {
              setState(() => _isLoading = true);
              _loadQuiz();
            },
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final currentAnswer = _answers[_currentQuestionIndex];
    final isAnswered = currentAnswer.isNotEmpty;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: MagicSkyColors.backgroundGradient),
        child: Column(
          children: [
            // Progress Bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                gradient: MagicSkyColors.primaryGradient,
              ),
              width:
                  (_currentQuestionIndex + 1) /
                  _questions.length *
                  MediaQuery.of(context).size.width,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Counter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Câu ${_currentQuestionIndex + 1}/${_questions.length}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (isAnswered)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: MagicSkyColors.successGradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Đã trả lời',
                                  style: Theme.of(context).textTheme.labelSmall!
                                      .copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Question Card
                    MagicCard(
                      gradient: MagicSkyColors.lavenderGradient,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Từ vựng:',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: MagicSkyColors.textDarkNavy.withValues(
                                    alpha: 0.6,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  currentQuestion['question_en'] ?? 'Unknown',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(
                                        color: Color(0xFF9B70F4),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => _speakWord(
                                  currentQuestion['question_en'] ?? '',
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(
                                      alpha: 0.8,
                                    ), // Nền nút loa trắng mờ
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: MagicSkyColors.primaryBlue
                                            .withValues(alpha: 0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.volume_up,
                                    color: Color(
                                      0xFF9B70F4,
                                    ), // ĐÃ ĐỔI: Icon xanh đậm
                                    size: 28,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Options
                    Text(
                      'Chọn đáp án đúng:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    const SizedBox(height: 12),

                    ...((currentQuestion['options'] as List?)
                            ?.asMap()
                            .entries
                            .map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: QuizOptionCard(
                                  text: entry.value['text_vn'] ?? '',
                                  isSelected:
                                      currentAnswer['selected_id'] ==
                                      entry.value['id'],
                                  isCorrect:
                                      entry.value['id'] ==
                                      currentQuestion['correct_id'],
                                  isAnswered: isAnswered,
                                  onTap: () =>
                                      _handleAnswerSelect(entry.value['id']),
                                ),
                              ),
                            ) ??
                        []),
                  ],
                ),
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GradientButton(
                          onPressed: _currentQuestionIndex == 0
                              ? () {}
                              : _goToPreviousQuestion,
                          label: 'Quay lại',
                          gradient: _currentQuestionIndex == 0
                              ? LinearGradient(
                                  colors: MagicSkyColors.primaryGradient.colors
                                      .map(
                                        (color) => color.withValues(alpha: 0.3),
                                      )
                                      .toList(),
                                )
                              : MagicSkyColors.primaryGradient,
                          icon: Icons.arrow_back,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GradientButton(
                          onPressed:
                              _currentQuestionIndex == _questions.length - 1
                              ? () {}
                              : _goToNextQuestion,
                          label: 'Tiếp theo',
                          gradient:
                              _currentQuestionIndex == _questions.length - 1
                              ? LinearGradient(
                                  colors: MagicSkyColors.primaryGradient.colors
                                      .map(
                                        (color) => color.withValues(alpha: 0.3),
                                      )
                                      .toList(),
                                )
                              : MagicSkyColors.primaryGradient,
                          icon: Icons.arrow_forward,
                        ),
                      ),
                    ],
                  ),
                  if (_currentQuestionIndex == _questions.length - 1) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: GradientButton(
                        onPressed: _isSubmitting ? () {} : _submitQuiz,
                        label: _isSubmitting ? 'Đang gửi...' : 'Nộp bài',
                        gradient: MagicSkyColors.sunsetGradient,
                        isLoading: _isSubmitting,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final correct = _result!['correct'] as int? ?? 0;
    final total = _result!['total'] as int? ?? 0;
    final gainedScore = _result!['gained_score'] as int? ?? 0;
    final totalScore = _result!['total_score'] as int? ?? 0;
    final accuracy = total > 0
        ? (correct / total * 100).toStringAsFixed(1)
        : '0';

    return Stack(
      alignment:
          Alignment.topCenter, // Đặt bệ phóng pháo hoa ở giữa đỉnh màn hình
      children: [
        // 1. MÀN HÌNH NỘI DUNG CHÍNH
        Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: MagicSkyColors.backgroundGradient,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Success Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: MagicSkyColors.successGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Bài quiz hoàn thành!',
                      style: Theme.of(context).textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Stats Grid (ĐÃ SỬA TỶ LỆ ĐỂ THẺ CAO LÊN CHỐNG TRÀN)
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.65,
                      children: [
                        StatItem(
                          icon: Icons.check_circle,
                          label: 'Câu đúng',
                          value: '$correct/$total',
                          color: MagicSkyColors.successMint,
                          gradient: MagicSkyColors.successGradient,
                        ),
                        StatItem(
                          icon: Icons.percent,
                          label: 'Độ chính xác',
                          value: '$accuracy%',
                          color: MagicSkyColors.primaryBlue,
                          gradient: MagicSkyColors.primaryGradient,
                        ),
                        StatItem(
                          icon: Icons.star,
                          label: 'Điểm nhận',
                          value: '$gainedScore',
                          color: MagicSkyColors.sunsetOrange,
                          gradient: MagicSkyColors.sunsetGradient,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Total Score Card
                    MagicCard(
                      gradient: MagicSkyColors.primaryGradient,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            'Tổng điểm của bạn',
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '$totalScore',
                            style: Theme.of(context).textTheme.displayLarge!
                                .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Action Buttons
                    SizedBox(
                      width: double.infinity,
                      child: GradientButton(
                        onPressed: _resetQuiz,
                        label: 'Làm lại',
                        gradient: MagicSkyColors.sunsetGradient,
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: MagicSkyColors.primaryBlue,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Quay lại',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 2. HIỆU ỨNG PHÁO HOA NẰM ĐÈ LÊN TRÊN
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirection:
              3.14159 /
              2, // Góc bắn thẳng đứng từ trên xuống (tương đương pi/2)
          maxBlastForce: 5, // Lực bắn tối đa
          minBlastForce: 2, // Lực bắn tối thiểu
          emissionFrequency: 0.05, // Mật độ pháo hoa
          numberOfParticles: 20, // Số lượng mảnh vỡ
          gravity: 0.2, // Trọng lực rơi
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple,
          ],
        ),
      ],
    );
  }
}
