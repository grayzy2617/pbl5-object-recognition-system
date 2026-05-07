import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../theme/theme_colors.dart';
import '../theme/custom_styles.dart';
import '../services/auth_provider.dart';
import 'package:provider/provider.dart';
import '../services/notification_provider.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AudioPlayer _audioPlayer;
  bool _typewriterComplete = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _audioPlayer = AudioPlayer();
  }

  void _initAnimations() {
    _breathingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playTypewriterSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/typewriter.mp3'));
    } catch (e) {
      debugPrint('Typewriter sound not found: $e');
    }
  }

  void _stopTypewriterSound() {
    _audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: MagicSkyColors.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HEADER - Typewriter animation
                _buildHeader(),

                const SizedBox(height: 24),

                // 2. PROFILE SECTION
                _buildProfileSection(),

                const SizedBox(height: 32),

                // 3. ZIGZAG STREAK PATH (Lấy data từ DB)
                _buildZigzagPath(),

                const SizedBox(height: 32),

                // 4. FEATURE CARDS (3 Thẻ)
                _buildFeatureCards(),

                const SizedBox(height: 28),

                // 5. TIPS CAROUSEL
                _buildTipsCarousel(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== 1. HEADER ====================
  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final userName = authProvider.userProfile?['full_name'] ?? 'Bạn';

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Dòng chữ đánh máy
            Expanded(
              child: SizedBox(
                height: 80,
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      '🏆Sẵn sàng chinh phục từ vựng chưa, $userName?',
                      textStyle: GoogleFonts.quicksand(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: MagicSkyColors.textDarkNavy,
                        height: 1.3,
                      ),
                      speed: const Duration(milliseconds: 100),
                    ),
                  ],
                  isRepeatingAnimation: false,
                  displayFullTextOnTap: true,
                  onTap: () {
                    _stopTypewriterSound();
                    setState(() => _typewriterComplete = true);
                  },
                  onFinished: () {
                    _stopTypewriterSound();
                    setState(() => _typewriterComplete = true);
                  },
                ),
              ),
            ),

            // 🔴 NÚT CHUÔNG THÔNG BÁO GÓC PHẢI
            Consumer<NotificationProvider>(
              builder: (context, notifProvider, _) {
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_none_rounded),
                        color: MagicSkyColors.primaryBlue,
                        iconSize: 28,
                        onPressed: () {
                          // Chuyển sang màn hình Thông báo
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    // Chấm đỏ đếm số chưa đọc
                    if (notifProvider.unreadCount > 0)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            '${notifProvider.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ==================== 2. PROFILE ====================
  Widget _buildProfileSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final profile = authProvider.userProfile;
        final title = profile?['title'] ?? '🌱 Người mới';
        final avatarUrl = profile?['avatar_url'] as String?;
        final titleColor = MagicSkyColors.getTitleColor(title);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Cụm Avatar và Danh hiệu
            Row(
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: titleColor, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: titleColor.withValues(alpha: 0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: avatarUrl != null
                          ? DecorationImage(
                              image: NetworkImage(avatarUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: Colors.white,
                    ),
                    child: avatarUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 40,
                            color: MagicSkyColors.primaryBlue,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                // Title
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Danh hiệu hiện tại',
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: MagicSkyColors.textLightGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TitleBadge(title: title, fontSize: 14),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ==================== 3. ZIGZAG STREAK PATH ====================
  Widget _buildZigzagPath() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // 1. LẤY DATA THẬT TỪ DB: Lấy 'streak' (hoặc 'best_streak' nếu không có)
        final profile = authProvider.userProfile;
        // Nếu API của bạn trả về tên biến khác (như current_streak), hãy sửa chữ 'streak' bên dưới
        final int currentStreak =
            profile?['streak'] ?? profile?['best_streak'] ?? 0;

        // 2. LOGIC TỰ ĐỘNG NHẢY CHẶNG: Luôn hiển thị dải 10 ngày tương ứng
        // Vd: Streak = 14 => startDay = 11. Bản đồ hiện 11, 12, ..., 20.
        int startDay = ((currentStreak ~/ 10) * 10) + 1;
        if (currentStreak > 0 && currentStreak % 10 == 0) {
          startDay = currentStreak - 9;
        }
        final List<int> streakDays = List.generate(
          10,
          (index) => startDay + index,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '🔥 Bản đồ tiến độ học tập',
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: MagicSkyColors.textDarkNavy,
              ),
            ),
            const SizedBox(height: 16),

            // Zigzag path
            SizedBox(
              width: double.infinity,
              child: Column(
                children: List.generate(streakDays.length, (index) {
                  final day = streakDays[index];
                  final isPassed = day <= currentStreak;
                  final isCurrentDay = day == currentStreak;

                  // Tính vị trí zigzag (Trái - Giữa - Phải)
                  late Alignment alignment;
                  if (index % 3 == 0) {
                    alignment = Alignment.centerLeft;
                  } else if (index % 3 == 1) {
                    alignment = Alignment.center;
                  } else {
                    alignment = Alignment.centerRight;
                  }

                  // Kiểm tra đoạn nối có được tô sáng không
                  final isNextDayPassed =
                      index < streakDays.length - 1 &&
                      streakDays[index + 1] <= currentStreak;

                  return Column(
                    children: [
                      // Node (Điểm dừng ngọn lửa)
                      Align(
                        alignment: alignment,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isPassed
                                ? MagicSkyColors.sunsetGradient
                                : LinearGradient(
                                    colors: [
                                      Colors.grey[300]!,
                                      Colors.grey[400]!,
                                    ],
                                  ),
                            boxShadow: isPassed
                                ? [
                                    BoxShadow(
                                      color: MagicSkyColors.sunsetOrange
                                          .withValues(alpha: 0.4),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              isCurrentDay ? '⭐' : '🔥',
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                      ),

                      // Đoạn thẳng nối giữa các ngọn lửa
                      if (index < streakDays.length - 1) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 30,
                          child: Center(
                            child: Container(
                              width: 4,
                              height: 30,
                              decoration: BoxDecoration(
                                color: isNextDayPassed
                                    ? MagicSkyColors.sunsetOrange
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Nhãn ghi số ngày bên dưới
                      const SizedBox(height: 8),
                      Text(
                        'Ngày $day',
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isPassed
                              ? MagicSkyColors.sunsetOrange
                              : MagicSkyColors.textLightGrey,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==================== 4. FEATURE CARDS ====================
  Widget _buildFeatureCards() {
    final features = [
      {
        'icon': Icons.style,
        'title': 'Học Từ vựng',
        'subtitle': 'Flashcard & Từ điển',
        'color': MagicSkyColors.primaryBlue,
        'gradient': MagicSkyColors.primaryGradient,
        'route': '/vocabulary',
      },
      {
        'icon': Icons.quiz,
        'title': 'Làm bài Test',
        'subtitle': 'Kiểm tra kiến thức',
        'color': MagicSkyColors.sunsetOrange,
        'gradient': MagicSkyColors.sunsetGradient,
        'route': '/quiz',
      },
      {
        'icon': Icons.history,
        'title': 'Lịch sử học',
        'subtitle': 'Xem lại kết quả',
        'color': const Color(0xFF9C27B0),
        'gradient': const LinearGradient(
          colors: [Color(0xFFCE93D8), Color(0xFF8E24AA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'route': '/history',
      },
      {
        'icon': Icons.videocam_rounded,
        'title': 'Live Camera',
        'subtitle': 'Giám sát trực tiếp',
        'color': Colors.redAccent,
        'gradient': const LinearGradient(
          colors: [Color(0xFFFF8A80), Color(0xFFD50000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'route': '/live_camera',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🎯 Hôm nay bạn muốn làm gì?',
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: MagicSkyColors.textDarkNavy,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.9,
          children: List.generate(features.length, (index) {
            final feature = features[index];
            return AnimatedBuilder(
              animation: _breathingController,
              builder: (context, child) {
                final scale = 1.0 + (_breathingController.value * 0.02);

                return Transform.scale(
                  scale: scale,
                  child: MagicCard(
                    gradient: feature['gradient'] as LinearGradient?,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, feature['route'] as String);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: feature['gradient'] as LinearGradient?,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (feature['color'] as Color).withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            feature['icon'] as IconData,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          feature['title'] as String,
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: MagicSkyColors.textDarkNavy,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feature['subtitle'] as String,
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  // ==================== 5. TIPS CAROUSEL ====================
  Widget _buildTipsCarousel() {
    final tips = [
      {
        'icon': '💡',
        'title': 'Mẹo hôm nay',
        'content': 'Học 10 từ mỗi ngày sẽ giúp bạn ghi nhớ lâu hơn!',
      },
      {
        'icon': '🎯',
        'title': 'Bí kíp thành công',
        'content': 'Hãy nói to từ vựng để phát âm chuẩn hơn.',
      },
      {
        'icon': '🏆',
        'title': 'Thử thách hôm nay',
        'content': 'Hoàn thành 5 bài test để lên cấp!',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📚 Mẹo học tập hôm nay',
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: MagicSkyColors.textDarkNavy,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: PageView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tips.length,
            itemBuilder: (context, index) {
              final tip = tips[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: MagicCard(
                  gradient: MagicSkyColors.lavenderGradient,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Text(
                            tip['icon'] as String,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tip['title'] as String,
                              style: GoogleFonts.quicksand(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8263FA),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        tip['content'] as String,
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8263FA).withValues(alpha: 0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
