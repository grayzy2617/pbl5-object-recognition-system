import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../services/api_service.dart';
// import '../providers/auth_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final result = await ApiService.getHistory();

    if (result['success'] && mounted) {
      setState(() {
        _history = List<Map<String, dynamic>>.from(result['data'] ?? []);
        _isLoading = false;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Lỗi tải lịch sử')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportToCSV() async {
    setState(() => _isExporting = true);

    try {
      // Prepare CSV data
      List<List<dynamic>> csvData = [
        ['Tên vật thể', 'Tên vật thể (VN)', 'Loại', 'Thời gian'],
        ..._history.map(
          (item) => [
            item['objectEn'] ?? '',
            item['objectVi'] ?? '',
            (item['isDangerous'] == true ? 'Nguy hiểm' : 'An toàn'),
            item['createdAt'] ?? '',
          ],
        ),
      ];

      String csvString = csvData
          .map((row) {
            return row
                .map((cell) {
                  // Bọc trong dấu ngoặc kép để chống lỗi nếu chữ có chứa dấu phẩy
                  return '"${cell.toString().replaceAll('"', '""')}"';
                })
                .join(','); // Nối các cột bằng dấu phẩy
          })
          .join('\n'); // Nối các hàng bằng dấu xuống dòng

      // Get documents directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'history_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName');

      // Write CSV file
      await file.writeAsString(csvString, encoding: utf8);

      setState(() => _isExporting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xuất CSV thành công: $fileName'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isExporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xuất CSV: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử & Thống kê'),
        actions: [
          if (_history.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Tooltip(
                message: 'Xuất CSV',
                child: IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: _isExporting ? null : _exportToCSV,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadHistory,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Statistics Dashboard
                    _buildStatisticsDashboard(),
                    const SizedBox(height: 24),

                    // History list
                    if (_history.isEmpty)
                      _buildEmptyState()
                    else
                      _buildHistoryList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatisticsDashboard() {
    int totalDetections = _history.length;
    int dangerousCount = _history
        .where((item) => item['isDangerous'] == true)
        .length;
    int safeCount = totalDetections - dangerousCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bảng điều khiển',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Main stats cards
        Row(
          children: [
            Expanded(
              child: _StatsCard(
                icon: Icons.image,
                label: 'Tổng ảnh',
                value: totalDetections.toString(),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatsCard(
                icon: Icons.check_circle,
                label: 'An toàn',
                value: safeCount.toString(),
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatsCard(
                icon: Icons.warning,
                label: 'Nguy hiểm',
                value: dangerousCount.toString(),
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Progress bar
        if (totalDetections > 0)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: safeCount / totalDetections,
              minHeight: 20,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation(Colors.green),
              semanticsLabel: 'Tỷ lệ an toàn',
            ),
          ),
        if (totalDetections > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Tỷ lệ an toàn: ${(safeCount / totalDetections * 100).toStringAsFixed(1)}%',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ),

        // Export button
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Icon(Icons.file_download),
            label: Text(
              _isExporting ? 'Đang xuất...' : 'Xuất dữ liệu thành CSV',
            ),
            onPressed: _history.isEmpty || _isExporting ? null : _exportToCSV,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Chưa có lịch sử nào',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Các ảnh được chụp sẽ xuất hiện ở đây',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadHistory,
            icon: const Icon(Icons.refresh),
            label: const Text('Tải lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lịch sử phát hiện (${_history.length})',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _history.length,
          itemBuilder: (context, index) {
            final item = _history[index];
            return _buildHistoryCard(item);
          },
        ),
      ],
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final isDangerous = item['isDangerous'] == true;
    final DateTime? createdAt = item['createdAt'] != null
        ? DateTime.tryParse(item['createdAt'].toString())
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (item['imageUrl'] != null) {
            _showImagePreview(item['imageUrl']);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              if (item['imageUrl'] != null)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[300],
                    image: DecorationImage(
                      image: NetworkImage(item['imageUrl']),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[300],
                  ),
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[600],
                  ),
                ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['objectEn'] ?? 'Unknown',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['objectVi'] ?? '',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDangerous
                                ? Colors.red[100]
                                : Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isDangerous
                                    ? Icons.warning
                                    : Icons.check_circle,
                                size: 14,
                                color: isDangerous
                                    ? Colors.red[600]
                                    : Colors.green[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isDangerous ? 'Nguy hiểm' : 'An toàn',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDangerous
                                      ? Colors.red[600]
                                      : Colors.green[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      createdAt != null
                          ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt)
                          : 'Thời gian không xác định',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatsCard({
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
