import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../services/theme_provider.dart';
import '../theme/theme_colors.dart';
import '../theme/custom_styles.dart';
import '../theme/animation_constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _bioController;
  bool _isEditing = false;
  bool _isUploading = false;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _bioController = TextEditingController();
    _loadData();
  }

  void _loadData() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.fetchUserProfile();

    if (mounted && authProvider.userProfile != null) {
      _fullNameController.text = authProvider.userProfile?['full_name'] ?? '';
      _bioController.text = authProvider.userProfile?['bio'] ?? '';
    }

    final statsResult = await ApiService.getProfileStats();
    if (mounted && statsResult['success']) {
      setState(() => _stats = statsResult);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _isUploading = true);

      final result = await ApiService.uploadAvatar(image.path);

      setState(() => _isUploading = false);

      if (result['success'] && mounted) {
        final authProvider = context.read<AuthProvider>();
        await authProvider.fetchUserProfile();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tải ảnh đại diện thành công')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Lỗi tải ảnh')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_fullNameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập họ tên')));
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateProfile(
      fullName: _fullNameController.text,
      bio: _bioController.text,
    );

    if (success && mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật hồ sơ thành công')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Cập nhật thất bại')),
      );
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: MagicSkyColors.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Hồ sơ cá nhân'),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return Tooltip(
                    message: 'Chế độ sáng (cố định)',
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: MagicSkyColors.bgSoftWhite,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.light_mode,
                        color: MagicSkyColors.sunshineYellow,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final profile = authProvider.userProfile;

            if (authProvider.isLoading && profile == null) {
              return const Center(
                child: CircularProgressIndicator(
                  color: MagicSkyColors.primaryBlue,
                ),
              );
            }

            final String title = profile?['title'] ?? '🌱 Người mới';
            final int currentStreak = profile?['current_streak'] ?? 0;
            final int bestStreak = profile?['best_streak'] ?? 0;
            final int totalScore = profile?['total_score'] ?? 0;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Avatar & Title Section
                  AnimationHelpers.scaleIn(
                    child: Center(
                      child: Column(
                        children: [
                          // Avatar
                          Stack(
                            children: [
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  gradient: MagicSkyColors.primaryGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: MagicSkyColors.primaryBlue
                                          .withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: profile?['avatar_url'] != null
                                    ? Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              profile!['avatar_url'],
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 70,
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                              ),
                              // Upload button
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _isUploading
                                      ? null
                                      : _pickAndUploadAvatar,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: MagicSkyColors.sunsetGradient,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: MagicSkyColors.sunsetOrange
                                              .withValues(alpha: 0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: _isUploading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Username
                          Text(
                            profile?['username'] ?? 'Unknown',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),

                          const SizedBox(height: 12),

                          // Title Badge
                          TitleBadge(title: title, fontSize: 16),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Gamification Section
                  AnimationHelpers.slideInUp(
                    duration: const Duration(milliseconds: 400),
                    child: Column(
                      children: [
                        // Streaks
                        StreakBadge(
                          streak: currentStreak,
                          bestStreak: bestStreak,
                        ),

                        const SizedBox(height: 16),

                        // Stats Grid
                        if (_stats != null)
                          GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            children: [
                              StatItem(
                                icon: Icons.quiz,
                                label: 'Quiz',
                                value: '${_stats!['total_quizzes'] ?? 0}',
                                color: MagicSkyColors.primaryBlue,
                                gradient: MagicSkyColors.primaryGradient,
                              ),
                              StatItem(
                                icon: Icons.check_circle,
                                label: 'Độ chính xác',
                                value:
                                    '${(_stats!['accuracy_pct'] ?? 0).toStringAsFixed(0)}%',
                                color: MagicSkyColors.successMint,
                                gradient: MagicSkyColors.successGradient,
                              ),
                              StatItem(
                                icon: Icons.star,
                                label: 'Điểm',
                                value: '$totalScore',
                                color: MagicSkyColors.sunsetOrange,
                                gradient: MagicSkyColors.sunsetGradient,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Profile Info Section
                  MagicCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thông tin cá nhân',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Divider(),
                        const SizedBox(height: 12),

                        // Email
                        _buildInfoRow(
                          icon: Icons.email,
                          label: 'Email',
                          value: profile?['email'] ?? 'N/A',
                          context: context,
                        ),

                        const SizedBox(height: 16),

                        // Full Name
                        if (_isEditing)
                          TextField(
                            controller: _fullNameController,
                            decoration: InputDecoration(
                              labelText: 'Họ tên',
                              prefixIcon: const Icon(Icons.person),
                              filled: true,
                              fillColor: const Color(0xFFF3F4F6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          )
                        else
                          _buildInfoRow(
                            icon: Icons.person,
                            label: 'Họ tên',
                            value: _fullNameController.text,
                            context: context,
                          ),

                        const SizedBox(height: 16),

                        // Bio
                        if (_isEditing)
                          TextField(
                            controller: _bioController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Tiểu sử',
                              prefixIcon: const Icon(Icons.description),
                              filled: true,
                              fillColor: const Color(0xFFF3F4F6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          )
                        else
                          _buildInfoRow(
                            icon: Icons.description,
                            label: 'Tiểu sử',
                            value: _bioController.text.isEmpty
                                ? 'Chưa cập nhật'
                                : _bioController.text,
                            context: context,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  if (_isEditing)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _isEditing = false),
                            child: const Text('Hủy'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GradientButton(
                            onPressed: authProvider.isLoading
                                ? () {}
                                : _saveProfile,
                            label: 'Lưu',
                            isLoading: authProvider.isLoading,
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: GradientButton(
                            onPressed: () => setState(() => _isEditing = true),
                            label: 'Chỉnh sửa hồ sơ',
                            gradient: MagicSkyColors.primaryGradient,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: GradientButton(
                            onPressed: _logout,
                            label: 'Đăng xuất',
                            gradient: MagicSkyColors.warningGradient,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context,
  }) {
    return Row(
      children: [
        Icon(icon, color: MagicSkyColors.primaryBlue, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
