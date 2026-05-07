import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_colors.dart';

// ==================== GRADIENT BUTTONS ====================
class GradientButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final LinearGradient gradient;
  final IconData? icon;
  final bool isLoading;
  final double borderRadius;
  final EdgeInsets padding;
  final double elevation;

  const GradientButton({
    required this.onPressed,
    required this.label,
    this.gradient = MagicSkyColors.primaryGradient,
    this.icon,
    this.isLoading = false,
    this.borderRadius = 28,
    // SỬA LỖI 1: Giảm padding ngang từ 28 xuống 16 để nút không bị quá mập
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.elevation = 6,
    super.key,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 1.0,
          end: 0.95,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.colors.first.withValues(alpha: 0.3),
                blurRadius: widget.elevation * 2,
                offset: Offset(0, widget.elevation / 2),
              ),
            ],
          ),
          child: widget.isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: Colors.white, size: 20),
                      const SizedBox(
                        width: 4,
                      ), // Thu hẹp khoảng cách icon và chữ
                    ],
                    // SỬA LỖI 2: Bọc Flexible và thêm overflow cho chữ
                    Flexible(
                      child: Text(
                        widget.label,
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis, // Hiện ... nếu chữ dài
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ==================== MAGIC CARD ====================
class MagicCard extends StatefulWidget {
  final Widget child;
  final LinearGradient? gradient;
  final double borderRadius;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final VoidCallback? onTap;
  final bool isAnimated;

  const MagicCard({
    required this.child,
    this.gradient,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.onTap,
    this.isAnimated = true,
    super.key,
  });

  @override
  State<MagicCard> createState() => _MagicCardState();
}

class _MagicCardState extends State<MagicCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => widget.onTap != null ? _controller.forward() : null,
      onTapUp: (_) {
        if (widget.onTap != null) {
          _controller.reverse();
          widget.onTap!();
        }
      },
      onTapCancel: () => widget.onTap != null ? _controller.reverse() : null,
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 1.0,
          end: 0.98,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
        child: Container(
          margin: widget.margin,
          padding: widget.padding,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            color: widget.gradient == null ? Colors.white : null,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: MagicSkyColors.cardShadows,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ==================== STREAK BADGE ====================
class StreakBadge extends StatelessWidget {
  final int streak;
  final int bestStreak;
  final bool showLabel;

  const StreakBadge({
    required this.streak,
    required this.bestStreak,
    this.showLabel = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isBestStreak = streak == bestStreak && streak > 0;

    return MagicCard(
      gradient: MagicSkyColors.successGradient,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 20,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(isBestStreak ? '⚡' : '🔥', style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          // FIX LỖI 1: Bọc Column trong Expanded để tránh tràn chữ ngang
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // CHỐNG TRÀN DỌC
              children: [
                if (showLabel)
                  Text(
                    isBestStreak ? 'Kỷ lục Streak' : 'Streak hiện tại',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                Text(
                  '$streak ngày',
                  style: GoogleFonts.quicksand(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (isBestStreak) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'BEST',
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ==================== TITLE BADGE ====================
class TitleBadge extends StatelessWidget {
  final String title;
  final bool showEmoji;
  final double fontSize;

  const TitleBadge({
    required this.title,
    this.showEmoji = true,
    this.fontSize = 18,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = MagicSkyColors.getTitleColor(title);
    final isLegend =
        title.contains('Huyền thoại') || title.contains('Kim Cương');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: isLegend
            ? LinearGradient(
                colors: [
                  color.withValues(alpha: 0.8),
                  color.withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: !isLegend ? color.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: isLegend ? 2 : 1),
        boxShadow: isLegend
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Text(
        title,
        style: GoogleFonts.quicksand(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: isLegend ? Colors.white : color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ==================== STAT ITEM ====================
class StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final LinearGradient? gradient;

  const StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.gradient,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MagicCard(
      gradient: gradient,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      // Giữ lại cuộn dọc phòng hờ điện thoại màn hình quá thấp
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: gradient,
                color: gradient == null ? color.withValues(alpha: 0.1) : null,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: gradient != null ? Colors.white : color,
              ),
            ),
            const SizedBox(height: 8),
            // Chỉ dùng FittedBox cho chữ số (value), vì số "10000" có thể dài
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: GoogleFonts.quicksand(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: MagicSkyColors.textDarkNavy,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // BỎ FITTEDBOX KHỎI LABEL ĐỂ CHỮ KHÔNG BỊ TÀNG HÌNH NỮA
            Text(
              label,
              style: GoogleFonts.quicksand(
                fontSize: 12, // Cố định cỡ chữ
                fontWeight: FontWeight.w600,
                color: MagicSkyColors.textLightGrey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2, // Cho phép rớt xuống tối đa 2 dòng nếu chữ quá dài
              overflow:
                  TextOverflow.ellipsis, // Hiện 3 chấm nếu vẫn dài hơn 2 dòng
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== PROGRESS CARD ====================
class ProgressCard extends StatelessWidget {
  final String label;
  final double progress;
  final LinearGradient gradient;
  final String? suffix;

  const ProgressCard({
    required this.label,
    required this.progress,
    this.gradient = MagicSkyColors.primaryGradient,
    this.suffix,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MagicCard(
      padding: const EdgeInsets.all(16),
      // THÊM SingleChildScrollView chống tràn dọc cho thanh tiến độ
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: MagicSkyColors.textDarkNavy,
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%${suffix ?? ''}',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: MagicSkyColors.textDarkNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      width: progress * 100,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== EMPTY STATE ====================
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const EmptyState({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onRetry,
    this.retryLabel = 'Tải lại',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        // THÊM SingleChildScrollView chống tràn dọc cho các trạng thái trống
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: MagicSkyColors.lavenderGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 64, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: GoogleFonts.quicksand(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: MagicSkyColors.textDarkNavy,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: MagicSkyColors.textGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                GradientButton(onPressed: onRetry!, label: retryLabel!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== QUIZ OPTION CARD ====================
class QuizOptionCard extends StatefulWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isAnswered;
  final VoidCallback onTap;
  final Color color;

  const QuizOptionCard({
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.isCorrect = false,
    this.isAnswered = false,
    this.color = MagicSkyColors.primaryBlue,
    super.key,
  });

  @override
  State<QuizOptionCard> createState() => _QuizOptionCardState();
}

class _QuizOptionCardState extends State<QuizOptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    _controller.forward().then((_) {
      widget.onTap();
      _controller.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    Color borderColor = const Color(0xFFE7E4FD);
    Color textColor = MagicSkyColors.textDarkNavy;

    // --- SỬA LẠI LOGIC ĐỔI MÀU VIỀN Ở ĐÂY ---
    if (widget.isAnswered) {
      if (widget.isCorrect) {
        // 1. LUÔN HIỆN VIỀN XANH CHO ĐÁP ÁN ĐÚNG (Bất kể có chọn trúng hay không)
        bgColor = MagicSkyColors.successMint.withValues(alpha: 0.1);
        borderColor = MagicSkyColors.successMint; // Viền xanh lá
        textColor = MagicSkyColors.successMint;
      } else if (widget.isSelected && !widget.isCorrect) {
        // 2. NẾU BẤM SAI THÌ HIỆN VIỀN ĐỎ CAM
        bgColor = MagicSkyColors.warningCoral.withValues(alpha: 0.1);
        borderColor = MagicSkyColors.warningCoral; // Viền đỏ cam
        textColor = MagicSkyColors.warningCoral;
      }
    } else if (widget.isSelected) {
      // 3. Trạng thái đang chạm vào
      bgColor = widget.color.withValues(alpha: 0.15);
      borderColor = widget.color;
      textColor = widget.color;
    }

    return GestureDetector(
      onTap: widget.isAnswered ? null : _onTap,
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 1.0,
          end: 0.98,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            // ĐÂY LÀ CHỖ VẼ VIỀN (border) CHO Ô ĐÁP ÁN:
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.text,
                  style: GoogleFonts.quicksand(
                    fontSize: 15,
                    // ĐÃ SỬA: Chỉ in đậm đáp án đúng SAU KHI đã trả lời
                    fontWeight:
                        widget.isSelected ||
                            (widget.isAnswered && widget.isCorrect)
                        ? FontWeight.bold
                        : FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              // --- SỬA LẠI LOGIC HIỆN ICON ---
              if (widget.isAnswered)
                if (widget.isCorrect)
                  Icon(
                    Icons.check_circle,
                    color: textColor,
                    size: 24,
                  ) // Đáp án đúng luôn có dấu check
                else if (widget.isSelected)
                  Icon(
                    Icons.cancel,
                    color: textColor,
                    size: 24,
                  ), // Chỗ bấm sai sẽ có dấu X
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== LOADING SHIMMER ====================
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const ShimmerLoading({
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: borderRadius,
      ),
    );
  }
}
