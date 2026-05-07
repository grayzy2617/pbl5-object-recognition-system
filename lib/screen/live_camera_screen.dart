import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme_colors.dart';
import '../theme/custom_styles.dart';

class LiveCameraScreen extends StatefulWidget {
  const LiveCameraScreen({super.key});

  @override
  State<LiveCameraScreen> createState() => _LiveCameraScreenState();
}

class _LiveCameraScreenState extends State<LiveCameraScreen>
    with TickerProviderStateMixin {
  // ==================== STREAM CONFIG ====================
  final String streamUrl = 'http://192.168.1.61:80/stream';
  bool isRunning = true;
  bool isConnected = false;
  bool showStats = true;

  // ==================== ANIMATION ====================
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  // ==================== STATS ====================
  DateTime streamStartTime = DateTime.now();
  int frameCount = 0;
  String connectionStatus = 'Đang kết nối...';
  String streamQuality = 'HD';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeStream();
  }

  void _setupAnimations() {
    // Pulse animation for recording indicator
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Fade animation for status text
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  void _initializeStream() {
    // Simulate stream connection check
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          isConnected = true;
          connectionStatus = 'Kết nối thành công ✓';
        });
      }
    });

    // Update frame count periodically
    // Sửa thành như sau:
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && isRunning) {
        setState(() {
          frameCount++;
        });
      }
    });
  }

  String _formatUptime() {
    final elapsed = DateTime.now().difference(streamStartTime);
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes.remainder(60);
    final seconds = elapsed.inSeconds.remainder(60);
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatFPS() {
    final elapsed = DateTime.now().difference(streamStartTime);
    if (elapsed.inSeconds == 0) return '0 FPS';
    final fps = frameCount / elapsed.inSeconds;
    return '${fps.toStringAsFixed(1)} FPS';
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(gradient: MagicSkyColors.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Recording indicator
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: MagicSkyColors.warningCoral,
                    boxShadow: [
                      BoxShadow(
                        color: MagicSkyColors.warningCoral.withValues(
                          alpha: 0.5,
                        ),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                // <--- BỌC TEXT TRONG FLEXIBLE
                child: Text(
                  '🔴 Live Camera',
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    color: MagicSkyColors.textDarkNavy,
                  ),
                  overflow: TextOverflow
                      .ellipsis, // <--- THÊM DÒNG NÀY ĐỂ HIỆN DẤU ... NẾU QUÁ DÀI
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Tooltip(
                message: 'Video settings',
                child: IconButton(
                  icon: Icon(Icons.settings, color: MagicSkyColors.primaryBlue),
                  onPressed: _showSettingsDialog,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // ==================== LIVE STREAM CONTAINER ====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MagicCard(
                  padding: const EdgeInsets.all(0),
                  onTap: () => _toggleFullscreen(),
                  child: Stack(
                    children: [
                      // Main stream
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: MagicSkyColors.primaryBlue.withValues(
                              alpha: 0.3,
                            ),
                            width: 2,
                          ),
                          color: Colors.black,
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Mjpeg(
                            isLive: isRunning,
                            error: (context, error, stack) {
                              return Container(
                                color: Colors.black87,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.videocam_off,
                                        size: 64,
                                        color: MagicSkyColors.warningCoral,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Mất kết nối',
                                        style: GoogleFonts.quicksand(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Vui lòng kiểm tra mạng Wi-Fi',
                                        style: GoogleFonts.quicksand(
                                          fontSize: 13,
                                          color: Colors.grey[400],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            stream: streamUrl,
                          ),
                        ),
                      ),

                      // Top overlay: Status badge
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isConnected
                                ? MagicSkyColors.successMint
                                : MagicSkyColors.warningCoral,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (isConnected
                                            ? MagicSkyColors.successMint
                                            : MagicSkyColors.warningCoral)
                                        .withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isConnected)
                                ScaleTransition(
                                  scale: _fadeAnimation,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(
                                  width: 8,
                                  height: 8,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 6),
                              Text(
                                isConnected ? '📡 Live' : 'Kết nối...',
                                style: GoogleFonts.quicksand(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Bottom overlay: Stream info
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'HD 1280x960',
                                style: GoogleFonts.quicksand(
                                  fontSize: 11,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_formatFPS()}',
                                style: GoogleFonts.quicksand(
                                  fontSize: 10,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Play/Pause overlay (center)
                      if (!isRunning)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: MagicSkyColors.primaryBlue.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.pause,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ==================== CONTROL BUTTONS ====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Play/Pause button
                    Expanded(
                      child: GradientButton(
                        onPressed: () {
                          setState(() {
                            isRunning = !isRunning;
                          });
                        },
                        label: isRunning ? 'Tạm dừng' : 'Tiếp tục xem',
                        gradient: isRunning
                            ? MagicSkyColors.successGradient
                            : MagicSkyColors.primaryGradient,
                        icon: isRunning ? Icons.pause : Icons.play_arrow,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Fullscreen button
                    Expanded(
                      child: GradientButton(
                        onPressed: _toggleFullscreen,
                        label: 'Toàn màn hình',
                        gradient: MagicSkyColors.primaryGradient,
                        icon: Icons.fullscreen,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==================== STATS SECTION ====================
              if (showStats)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: MagicCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Thông tin kết nối',
                              style: GoogleFonts.quicksand(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: MagicSkyColors.textDarkNavy,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() => showStats = false);
                              },
                              child: Icon(
                                Icons.close,
                                size: 20,
                                color: MagicSkyColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Stats grid
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.4,
                          children: [
                            // Status
                            _buildStatItem(
                              icon: Icons.signal_cellular_4_bar,
                              label: 'Trạng thái',
                              value: isConnected ? 'Tốt ✓' : 'Chờ...',
                              gradient: isConnected
                                  ? MagicSkyColors.successGradient
                                  : MagicSkyColors.warningGradient,
                            ),

                            // FPS
                            _buildStatItem(
                              icon: Icons.speed,
                              label: 'Tốc độ',
                              value: _formatFPS(),
                              gradient: MagicSkyColors.primaryGradient,
                            ),

                            // Uptime
                            _buildStatItem(
                              icon: Icons.access_time,
                              label: 'Thời gian',
                              value: _formatUptime(),
                              gradient: MagicSkyColors.sunsetGradient,
                            ),

                            // Network
                            _buildStatItem(
                              icon: Icons.router,
                              label: 'Mạng',
                              value: '192.168.1.61',
                              gradient: MagicSkyColors.lavenderGradient,
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Connection info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: MagicSkyColors.primaryBlue.withValues(
                              alpha: 0.08,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: MagicSkyColors.primaryBlue.withValues(
                                alpha: 0.2,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info,
                                size: 18,
                                color: MagicSkyColors.primaryBlue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Camera phải đang bật thì mới xem được hình ảnh. Nếu bị lag, hãy thử giảm chất lượng video hoặc kiểm tra lại kết nối mạng.',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 12,
                                    color: MagicSkyColors.textGrey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (!showStats)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() => showStats = true);
                    },
                    icon: const Icon(Icons.info),
                    label: const Text('Xem thông tin kết nối'),
                    style: TextButton.styleFrom(
                      foregroundColor: MagicSkyColors.primaryBlue,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // ==================== QUALITY PRESETS ====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chất lượng video',
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: MagicSkyColors.textDarkNavy,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildQualityChip('SD', streamQuality == 'SD', () {
                          setState(() => streamQuality = 'SD');
                        }),
                        const SizedBox(width: 8),
                        _buildQualityChip('HD', streamQuality == 'HD', () {
                          setState(() => streamQuality = 'HD');
                        }),
                        const SizedBox(width: 8),
                        _buildQualityChip('FHD', streamQuality == 'FHD', () {
                          setState(() => streamQuality = 'FHD');
                        }),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==================== TIPS SECTION ====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: MagicSkyColors.successMint.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: MagicSkyColors.successMint.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb,
                            size: 20,
                            color: MagicSkyColors.sunshineYellow,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Mẹo sử dụng',
                            style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: MagicSkyColors.textDarkNavy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '• Bấm vào video để xem toàn màn hình\n'
                        '• Tạm dừng để xem lại hình ảnh\n'
                        '• Thay đổi chất lượng nếu bị lag\n'
                        '• Kiểm tra mạng nếu mất kết nối',
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          color: MagicSkyColors.textGrey,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: gradient,
                ),
                child: Icon(icon, size: 12, color: Colors.white),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    color: MagicSkyColors.textGrey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: MagicSkyColors.textDarkNavy,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQualityChip(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected ? MagicSkyColors.primaryGradient : null,
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey[300]!,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? null : Colors.white,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : MagicSkyColors.textGrey,
            ),
          ),
        ),
      ),
    );
  }

  // ==================== ACTIONS ====================

  void _toggleFullscreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black87,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: Mjpeg(
              isLive: isRunning,
              stream: streamUrl,
              error: (context, error, stack) {
                return Center(
                  child: Text(
                    'Mất kết nối',
                    style: GoogleFonts.quicksand(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Cài đặt Camera',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            color: MagicSkyColors.textDarkNavy,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingRow('Địa chỉ IP:', streamUrl),
            const SizedBox(height: 12),
            _buildSettingRow('Độ phân giải:', '1280 x 960'),
            const SizedBox(height: 12),
            _buildSettingRow('Tốc độ frame:', '25 FPS'),
            const SizedBox(height: 12),
            _buildSettingRow('Định dạng:', 'MJPEG Stream'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Đóng',
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                color: MagicSkyColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 11,
            color: MagicSkyColors.textGrey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.quicksand(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: MagicSkyColors.textDarkNavy,
          ),
        ),
      ],
    );
  }
}
