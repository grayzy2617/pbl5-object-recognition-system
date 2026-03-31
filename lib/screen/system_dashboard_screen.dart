import 'package:flutter/material.dart';
import '../models/log_item_model.dart';
import '../services/api_service.dart';
import '../widgets/custom_card.dart';
import '../widgets/log_item_widget.dart';

class SystemDashboardScreen extends StatefulWidget {
  const SystemDashboardScreen({super.key});

  @override
  State<SystemDashboardScreen> createState() => _SystemDashboardScreenState();
}

class _SystemDashboardScreenState extends State<SystemDashboardScreen> {
  final ApiService _apiService = ApiService();

  List<LogItemModel> _logs = [];
  bool _isLoading = true;
  String _errorMessage = '';

  int _totalDetections = 0;
  int _safeObjects = 0;
  int _dangerousItems = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final logs = await _apiService.fetchHistory();
      int safeCount = logs.where((log) => log.isSafe).length;

      setState(() {
        _logs = logs;
        _totalDetections = logs.length;
        _safeObjects = safeCount;
        _dangerousItems = logs.length - safeCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF9810FA);
    const lightPurpleBg = Color(0xFFF3E8FF);
    const lightGreenBg = Color(0xFFDBFCE7);
    const lightRedBg = Color(0xFFFFE2E2);
    const lightBlueBg = Color(0xFFDBEAFE);
    const textSecondary = Color(0xFF6B7280);
    const textMain = Color(0xFF1F2937);

    // 📱 KIỂM TRA MÀN HÌNH: Nếu chiều ngang < 600px thì là Mobile
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    // ✅ KHỐI LOGO (Sử dụng Expanded cho Text để chống tràn trên Mobile)
    Widget logoSection = Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Image.asset(
            'assets/images/logo.png',
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'AI Learning System',
                style: TextStyle(
                  color: textMain,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'ESP32-CAM Active',
                style: TextStyle(color: textSecondary, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );

    // ✅ MENU TRÊN WEB (Nút bấm hàng ngang)
    Widget desktopMenu = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.history, color: textMain, size: 20),
          label: const Text(
            'History',
            style: TextStyle(color: textMain, fontSize: 16),
          ),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.menu_book, color: textMain, size: 20),
          label: const Text(
            'Vocabulary',
            style: TextStyle(color: textMain, fontSize: 16),
          ),
        ),
      ],
    );

    // ✅ MENU TRÊN ĐIỆN THOẠI (Nút bấm xổ xuống PopupMenu)
    Widget mobileMenu = PopupMenuButton<String>(
      icon: const Icon(Icons.menu, color: textMain, size: 28), // Icon Hamburger
      offset: const Offset(0, 50), // Đẩy menu xích xuống một chút cho đẹp
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        // Xử lý sự kiện khi bấm vào menu ở đây
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'History',
          child: Row(
            children: [
              Icon(Icons.history, color: textMain, size: 20),
              SizedBox(width: 12),
              Text('History', style: TextStyle(color: textMain)),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'Vocabulary',
          child: Row(
            children: [
              Icon(Icons.menu_book, color: textMain, size: 20),
              SizedBox(width: 12),
              Text('Vocabulary', style: TextStyle(color: textMain)),
            ],
          ),
        ),
      ],
    );

    return Container(
      // 🔥 NỀN GRADIENT
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFC3F1F4), Color(0xFFDEC7FE)],
          begin: Alignment.topLeft,
          end: Alignment.topRight,
        ),
      ),

      child: Scaffold(
        backgroundColor: Colors.transparent,

        // 🔥 APPBAR GỌN GÀNG (Chung 1 dòng cho cả Web và Mobile)
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: logoSection,
          actions: [
            isMobile ? mobileMenu : desktopMenu, // Tự động đổi menu
            const SizedBox(width: 8),
          ],
        ),

        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // const Text(
                        //   'System Dashboard & History',
                        //   style: TextStyle(
                        //     color: Color(0xFF5C31F8),
                        //     fontSize: 24,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: [Color(0xFF1F92DC), Color(0xFF692EF2)],
                              begin: Alignment.topLeft,
                              end: Alignment.topRight,
                            ).createShader(bounds);
                          },
                          child: const Text(
                            'System Dashboard & History',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 🔥 STATUS CARDS (Thay đổi ở đây)
                        // Nếu là điện thoại -> Dùng Column (chiếm nguyên hàng dọc)
                        // Nếu là Web -> Dùng Row (chia làm 2 cột)
                        isMobile
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment
                                    .stretch, // Bắt buộc các thẻ kéo dài 100%
                                children: const [
                                  CustomCard(
                                    title: 'WiFi Connection',
                                    value: 'Connected',
                                    subtitle: 'Signal: Strong (92%)',
                                    icon: Icons.wifi,
                                    iconColor: Color(0xFF009966),
                                    borderColor: Color(0xFFD0FAE5),
                                    bgColor: Color(0xFFEDFDF5),
                                    isStatusCard: true,
                                  ),
                                  SizedBox(height: 12),
                                  CustomCard(
                                    title: 'Device Status',
                                    value: 'Online',
                                    subtitle: 'ESP32-CAM Active',
                                    icon: Icons.network_check,
                                    iconColor: Color(0xFF009689),
                                    borderColor: Color(0xFFCBFBF1),
                                    bgColor: Color(0xFFEEFEFC),
                                    isStatusCard: true,
                                  ),
                                ],
                              )
                            : Row(
                                children: const [
                                  Expanded(
                                    child: CustomCard(
                                      title: 'WiFi Connection',
                                      value: 'Connected',
                                      subtitle: 'Signal: Strong (92%)',
                                      icon: Icons.wifi,
                                      iconColor: Color(0xFF009966),
                                      borderColor: Color(0xFFD0FAE5),
                                      bgColor: Color(0xFFEDFDF5),
                                      isStatusCard: true,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: CustomCard(
                                      title: 'Device Status',
                                      value: 'Online',
                                      subtitle: 'ESP32-CAM Active',
                                      icon: Icons.network_check,
                                      iconColor: Color(0xFF009689),
                                      borderColor: Color(0xFFCBFBF1),
                                      bgColor: Color(0xFFEEFEFC),
                                      isStatusCard: true,
                                    ),
                                  ),
                                ],
                              ),

                        const SizedBox(height: 16),

                        // STATS (ROW 1)
                        Row(
                          children: [
                            Expanded(
                              child: CustomCard(
                                title: 'Total Detections',
                                value: '$_totalDetections',
                                subtitle: 'All time',
                                icon: Icons.query_builder,
                                iconColor: const Color(0xFF155DFC),
                                borderColor: lightBlueBg,
                                bgColor: Colors.white,
                                isStatusCard: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomCard(
                                title: 'Safe Objects',
                                value: '$_safeObjects',
                                subtitle: 'Secure',
                                icon: Icons.shield_outlined,
                                iconColor: const Color(0xFF00A63E),
                                borderColor: lightGreenBg,
                                bgColor: Colors.white,
                                isStatusCard: true,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // STATS (ROW 2)
                        Row(
                          children: [
                            Expanded(
                              child: CustomCard(
                                title: 'Dangerous Items',
                                value: '$_dangerousItems',
                                subtitle: 'Alerts',
                                icon: Icons.report_problem_outlined,
                                iconColor: const Color(0xFFE7000B),
                                borderColor: lightRedBg,
                                bgColor: Colors.white,
                                isStatusCard: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: CustomCard(
                                title: 'Avg Confidence',
                                value: '95.0%',
                                subtitle: 'YOLOv8',
                                icon: Icons.analytics,
                                iconColor: primaryPurple,
                                borderColor: lightPurpleBg,
                                bgColor: Colors.white,
                                isStatusCard: true,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // TIMELINE
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Text(
                        //       'Detection Timeline ($_totalDetections)',
                        //       style: const TextStyle(
                        //         fontSize: 18,
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //     IconButton(
                        //       icon: const Icon(Icons.refresh),
                        //       onPressed: _loadData,
                        //     ),
                        //   ],
                        // ),

                        // const SizedBox(height: 16),

                        // _logs.isEmpty
                        //     ? const Center(
                        //         child: Text("No records found in database."),
                        //       )
                        //     : ListView.builder(
                        //         shrinkWrap: true,
                        //         physics: const NeverScrollableScrollPhysics(),
                        //         itemCount: _logs.length,
                        //         itemBuilder: (context, index) {
                        //           return Padding(
                        //             padding: const EdgeInsets.only(
                        //               bottom: 12.0,
                        //             ),
                        //             child: LogItemWidget(logItem: _logs[index]),
                        //           );
                        //         },
                        //       ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // 🔥 HEADER CÓ MÀU RIÊNG
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: const BoxDecoration(
                                  color: Color(
                                    0xFFECE3F9,
                                  ), // 👉 màu header (tím nhạt)
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Detection Timeline ($_totalDetections)',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF6B39B3),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.refresh,
                                        color: Color(0xFF6B39B3),
                                      ),
                                      onPressed: _loadData,
                                    ),
                                  ],
                                ),
                              ),

                              // 🔹 CONTENT
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: _logs.isEmpty
                                    ? const Center(
                                        child: Text(
                                          "No records found in database.",
                                        ),
                                      )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: _logs.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 12.0,
                                            ),
                                            child: LogItemWidget(
                                              logItem: _logs[index],
                                            ),
                                          );
                                        },
                                      ),
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
    );
  }
}
