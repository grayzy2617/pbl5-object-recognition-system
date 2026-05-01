import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../services/theme_provider.dart';

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

    // Load stats
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

  // MỚI: Hàm quyết định màu sắc của Danh hiệu dựa vào tên Rank
  Color _getTitleColor(String title) {
    if (title.contains('Kim Cương')) return Colors.cyan;
    if (title.contains('Vàng')) return Colors.amber;
    if (title.contains('Bạc')) return Colors.grey[400]!;
    if (title.contains('Đồng')) return Colors.brown[400]!;
    if (title.contains('Huyền thoại')) return Colors.purple;
    return Colors.green; // Mầm non AI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return Tooltip(
                  message: themeProvider.isDarkMode
                      ? 'Chế độ sáng'
                      : 'Chế độ tối',
                  child: IconButton(
                    icon: Icon(
                      themeProvider.isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode,
                    ),
                    onPressed: () => themeProvider.toggleTheme(),
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
            return const Center(child: CircularProgressIndicator());
          }

          // Trích xuất dữ liệu Gamification an toàn
          final String title = profile?['title'] ?? '🌱 Người mới';
          final int currentStreak = profile?['current_streak'] ?? 0;
          final int bestStreak = profile?['best_streak'] ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ================= Avatar & Danh hiệu =================
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[300],
                              border: Border.all(
                                color: _getTitleColor(title),
                                width: 4, // Viền lấp lánh theo Rank
                              ),
                              image: profile?['avatar_url'] != null
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        profile!['avatar_url'],
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: profile?['avatar_url'] == null
                                ? Icon(
                                    Icons.person,
                                    size: 70,
                                    color: Colors.grey[600],
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).primaryColor,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: _isUploading
                                    ? null
                                    : _pickAndUploadAvatar,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Bảng tên hiển thị Danh hiệu (Title)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _getTitleColor(title).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _getTitleColor(title)),
                        ),
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getTitleColor(title),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ================= Khu vực Streak (Chuỗi ngày) =================
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Chuỗi hiện tại
                        Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  '$currentStreak',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '🔥',
                                  style: TextStyle(fontSize: 28),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Chuỗi hiện tại',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        // Đường phân cách
                        Container(
                          height: 50,
                          width: 1,
                          color: Colors.grey[300],
                        ),

                        // Kỷ lục cao nhất
                        Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  '$bestStreak',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.orange[300],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text('⚡', style: TextStyle(fontSize: 24)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kỷ lục cao nhất',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ================= Thống kê chi tiết =================
                if (_stats != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hoạt động học tập',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Divider(),
                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatItem(
                                icon: Icons.quiz,
                                label: 'Bài Quiz',
                                value: '${_stats!['total_quizzes'] ?? 0}',
                                color: Colors.blue,
                              ),
                              _StatItem(
                                icon: Icons.check_circle,
                                label: 'Tỉ lệ đúng',
                                value:
                                    '${(_stats!['accuracy_pct'] ?? 0).toStringAsFixed(1)}%',
                                color: Colors.green,
                              ),
                              _StatItem(
                                icon: Icons.star,
                                label: 'Điểm số',
                                value: '${_stats!['total_score'] ?? 0}',
                                color: Colors.amber,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.center_focus_strong,
                                  color: Colors.purple,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Camera AI đã quét: ${_stats!['ai_detections'] ?? 0} vật thể',
                                    style: const TextStyle(
                                      color: Colors.purple,
                                      fontWeight: FontWeight.bold,
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
                const SizedBox(height: 16),

                // ================= User info section =================
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thông tin cá nhân',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        const SizedBox(height: 8),

                        ListTile(
                          leading: const Icon(Icons.account_circle),
                          title: const Text('Tên đăng nhập'),
                          subtitle: Text(profile?['username'] ?? ''),
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 8),

                        ListTile(
                          leading: const Icon(Icons.email),
                          title: const Text('Email'),
                          subtitle: Text(profile?['email'] ?? ''),
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 16),

                        if (_isEditing)
                          TextFormField(
                            controller: _fullNameController,
                            decoration: const InputDecoration(
                              labelText: 'Họ tên',
                              prefixIcon: Icon(Icons.person),
                            ),
                          )
                        else
                          ListTile(
                            leading: const Icon(Icons.person),
                            title: const Text('Họ tên'),
                            subtitle: Text(_fullNameController.text),
                            contentPadding: EdgeInsets.zero,
                          ),
                        const SizedBox(height: 8),

                        if (_isEditing)
                          TextFormField(
                            controller: _bioController,
                            decoration: const InputDecoration(
                              labelText: 'Tiểu sử',
                              prefixIcon: Icon(Icons.description),
                            ),
                            maxLines: 3,
                          )
                        else
                          ListTile(
                            leading: const Icon(Icons.description),
                            title: const Text('Tiểu sử'),
                            subtitle: Text(
                              _bioController.text.isEmpty
                                  ? 'Chưa cập nhật'
                                  : _bioController.text,
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                if (_isEditing)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => setState(() => _isEditing = false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[400],
                          ),
                          child: const Text('Hủy'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : _saveProfile,
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Lưu'),
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => setState(() => _isEditing = true),
                          child: const Text('Chỉnh sửa hồ sơ'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[50],
                            foregroundColor: Colors.red,
                            elevation: 0,
                          ),
                          child: const Text('Đăng xuất'),
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
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color; // Thêm tham số màu sắc cho bắt mắt

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 28, color: color),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
