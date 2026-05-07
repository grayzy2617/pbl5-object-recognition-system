import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../theme/theme_colors.dart';
import '../theme/custom_styles.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // ==================== API DATA ====================
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  bool _isExporting = false;

  // ==================== FILTER STATE (Date Range) ====================
  DateTime? _startDate;
  DateTime? _endDate;
  String _statusFilter = 'Tất cả'; // "Tất cả", "Nguy hiểm", "An toàn"

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

  // ==================== FILTER LOGIC ====================
  /// Getter để lọc dữ liệu dựa trên date range và status filters
  List<Map<String, dynamic>> get _filteredHistory {
    return _history.where((item) {
      // Filter by date range
      if (_startDate != null || _endDate != null) {
        final DateTime? itemDate = item['createdAt'] != null
            ? DateTime.tryParse(item['createdAt'].toString())
            : null;

        if (itemDate == null) return false;

        // So sánh chỉ ngày (bỏ giờ phút giây)
        final itemDateOnly = DateTime(
          itemDate.year,
          itemDate.month,
          itemDate.day,
        );

        // Check start date
        if (_startDate != null) {
          final startDateOnly = DateTime(
            _startDate!.year,
            _startDate!.month,
            _startDate!.day,
          );
          if (itemDateOnly.isBefore(startDateOnly)) return false;
        }

        // Check end date
        if (_endDate != null) {
          final endDateOnly = DateTime(
            _endDate!.year,
            _endDate!.month,
            _endDate!.day,
          );
          if (itemDateOnly.isAfter(endDateOnly)) return false;
        }
      }

      // Filter by status
      if (_statusFilter != 'Tất cả') {
        final isDangerous = item['isDangerous'] == true;
        if (_statusFilter == 'Nguy hiểm' && !isDangerous) return false;
        if (_statusFilter == 'An toàn' && isDangerous) return false;
      }

      return true;
    }).toList();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: _endDate ?? DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: MagicSkyColors.primaryBlue,
              onPrimary: Colors.white,
              surface: MagicSkyColors.bgWhite,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: MagicSkyColors.primaryBlue,
              onPrimary: Colors.white,
              surface: MagicSkyColors.bgWhite,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  void _clearDateFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  Future<void> _exportToCSV() async {
    setState(() => _isExporting = true);

    try {
      // Prepare CSV data từ filtered history
      List<List<dynamic>> csvData = [
        ['Tên vật thể', 'Tên vật thể (VN)', 'Loại', 'Thời gian'],
        ..._filteredHistory.map(
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
                  return '"${cell.toString().replaceAll('"', '""')}"';
                })
                .join(',');
          })
          .join('\n');

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'history_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(csvString, encoding: utf8);

      setState(() => _isExporting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xuất CSV thành công: $fileName'),
            backgroundColor: MagicSkyColors.successMint,
          ),
        );
      }
    } catch (e) {
      setState(() => _isExporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xuất CSV: $e'),
            backgroundColor: MagicSkyColors.warningCoral,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: MagicSkyColors.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Lịch sử & Thống kê',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              color: MagicSkyColors.textDarkNavy,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            if (_filteredHistory.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Tooltip(
                  message: 'Xuất CSV',
                  child: IconButton(
                    icon: const Icon(Icons.download),
                    color: MagicSkyColors.primaryBlue,
                    onPressed: _isExporting ? null : _exportToCSV,
                  ),
                ),
              ),
          ],
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: MagicSkyColors.primaryBlue,
                ),
              )
            : RefreshIndicator(
                color: MagicSkyColors.primaryBlue,
                onRefresh: _loadHistory,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Statistics Dashboard
                      _buildStatisticsDashboard(),
                      const SizedBox(height: 24),

                      // Filter Bar (2 rows)
                      _buildFilterBar(),
                      const SizedBox(height: 16),

                      // History list
                      if (_filteredHistory.isEmpty)
                        _buildEmptyState()
                      else
                        _buildHistoryList(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // ==================== STATISTICS DASHBOARD ====================
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
          style: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: MagicSkyColors.textDarkNavy,
          ),
        ),
        const SizedBox(height: 16),

        // Main stats cards - Horizontal scroll để không overflow
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 100,
                  child: MagicCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: MagicSkyColors.primaryGradient,
                          ),
                          child: const Icon(
                            Icons.image,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          totalDetections.toString(),
                          style: GoogleFonts.quicksand(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: MagicSkyColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tổng ảnh',
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            color: MagicSkyColors.textGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 100,
                  child: MagicCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: MagicSkyColors.successGradient,
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          safeCount.toString(),
                          style: GoogleFonts.quicksand(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: MagicSkyColors.successMint,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'An toàn',
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            color: MagicSkyColors.textGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: MagicCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: MagicSkyColors.warningGradient,
                        ),
                        child: const Icon(
                          Icons.warning,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dangerousCount.toString(),
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: MagicSkyColors.warningCoral,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nguy hiểm',
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          color: MagicSkyColors.textGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Progress bar
        if (totalDetections > 0) ...[
          MagicCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tỷ lệ an toàn',
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: MagicSkyColors.textDarkNavy,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: safeCount / totalDetections,
                    minHeight: 24,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation(
                      Color.fromARGB(255, 45, 212, 191),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(safeCount / totalDetections * 100).toStringAsFixed(1)}%',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: MagicSkyColors.successMint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Export button
        SizedBox(
          width: double.infinity,
          child: GradientButton(
            onPressed: _filteredHistory.isEmpty || _isExporting
                ? () {}
                : _exportToCSV,
            label: _isExporting ? 'Đang xuất...' : 'Xuất dữ liệu thành CSV',
            gradient: MagicSkyColors.sunsetGradient,
            icon: Icons.file_download,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  // ==================== FILTER BAR (2 ROWS) ====================
  Widget _buildFilterBar() {
    return MagicCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Bộ lọc',
            style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: MagicSkyColors.textDarkNavy,
            ),
          ),
          const SizedBox(height: 12),

          // ==================== ROW 1: DATE RANGE ====================
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lọc theo ngày tháng',
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: MagicSkyColors.textGrey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Start Date Button
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickStartDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _startDate != null
                                ? MagicSkyColors.primaryBlue
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: _startDate != null
                                        ? MagicSkyColors.primaryBlue
                                        : Colors.grey[500],
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _startDate != null
                                          ? DateFormat(
                                              'dd/MM/yyyy',
                                            ).format(_startDate!)
                                          : 'Từ ngày',
                                      style: GoogleFonts.quicksand(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _startDate != null
                                            ? MagicSkyColors.textDarkNavy
                                            : Colors.grey[500],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_startDate != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _startDate = null),
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: MagicSkyColors.sunsetOrange,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Separator
                  Text(
                    '→',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: MagicSkyColors.textGrey,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // End Date Button
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickEndDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _endDate != null
                                ? MagicSkyColors.primaryBlue
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: _endDate != null
                                        ? MagicSkyColors.primaryBlue
                                        : Colors.grey[500],
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _endDate != null
                                          ? DateFormat(
                                              'dd/MM/yyyy',
                                            ).format(_endDate!)
                                          : 'Đến ngày',
                                      style: GoogleFonts.quicksand(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _endDate != null
                                            ? MagicSkyColors.textDarkNavy
                                            : Colors.grey[500],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_endDate != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: GestureDetector(
                                  onTap: () => setState(() => _endDate = null),
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: MagicSkyColors.sunsetOrange,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Clear All button
                  if (_startDate != null || _endDate != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: GestureDetector(
                        onTap: _clearDateFilters,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: MagicSkyColors.warningCoral.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.clear_all,
                            size: 18,
                            color: MagicSkyColors.warningCoral,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Divider
          Container(height: 1, color: Colors.grey[200]),

          const SizedBox(height: 14),

          // ==================== ROW 2: STATUS FILTER ====================
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lọc theo trạng thái',
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: MagicSkyColors.textGrey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: DropdownButton<String>(
                  value: _statusFilter,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _statusFilter = value);
                    }
                  },
                  underline: const SizedBox(),
                  isExpanded: true,
                  icon: Icon(
                    Icons.expand_more,
                    color: MagicSkyColors.primaryBlue,
                  ),
                  items: ['Tất cả', 'An toàn', 'Nguy hiểm']
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Row(
                            children: [
                              Icon(
                                status == 'Nguy hiểm'
                                    ? Icons.warning
                                    : status == 'An toàn'
                                    ? Icons.check_circle
                                    : Icons.filter_list,
                                size: 16,
                                color: status == 'Nguy hiểm'
                                    ? MagicSkyColors.sunsetOrange
                                    : status == 'An toàn'
                                    ? MagicSkyColors.successMint
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                status,
                                style: GoogleFonts.quicksand(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: MagicSkyColors.textDarkNavy,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.search_off,
      title: 'Không có dữ liệu',
      subtitle:
          _startDate != null || _endDate != null || _statusFilter != 'Tất cả'
          ? 'Thử thay đổi bộ lọc'
          : 'Chưa có lịch sử phát hiện',
      onRetry: _loadHistory,
    );
  }

  // ==================== HISTORY LIST ====================
  Widget _buildHistoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lịch sử phát hiện (${_filteredHistory.length})',
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: MagicSkyColors.textDarkNavy,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredHistory.length,
          itemBuilder: (context, index) {
            final item = _filteredHistory[index];
            return _buildHistoryCard(item);
          },
        ),
      ],
    );
  }

  // ==================== HISTORY CARD ====================
  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final isDangerous = item['isDangerous'] == true;
    final borderColor = isDangerous
        ? MagicSkyColors.sunsetOrange
        : MagicSkyColors.successMint;
    final DateTime? createdAt = item['createdAt'] != null
        ? DateTime.tryParse(item['createdAt'].toString())
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MagicCard(
        padding: const EdgeInsets.all(0),
        onTap: () {
          if (item['imageUrl'] != null) {
            _showImagePreview(item['imageUrl']);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Colored border indicator
              Container(
                width: 6,
                height: 120,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Thumbnail
              if (item['imageUrl'] != null)
                Container(
                  width: 90,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                    image: DecorationImage(
                      image: NetworkImage(item['imageUrl']),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  width: 90,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[500],
                    size: 36,
                  ),
                ),

              const SizedBox(width: 12),

              // Content - English on one line
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // English name on single line
                      Text(
                        item['objectEn'] ?? 'Unknown',
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: MagicSkyColors.textDarkNavy,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Vietnamese name
                      Text(
                        item['objectVi'] ?? '',
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          color: MagicSkyColors.textGrey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      // Time
                      Text(
                        createdAt != null
                            ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt)
                            : 'Thời gian không xác định',
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          color: MagicSkyColors.textLightGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Status badge
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: isDangerous
                            ? MagicSkyColors.warningGradient
                            : MagicSkyColors.successGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDangerous ? Icons.warning : Icons.check_circle,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isDangerous ? 'Nguy hiểm' : 'An toàn',
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 300,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[600],
                        size: 64,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: GradientButton(
                  onPressed: () => Navigator.pop(context),
                  label: 'Đóng',
                  gradient: MagicSkyColors.primaryGradient,
                  icon: Icons.close,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
