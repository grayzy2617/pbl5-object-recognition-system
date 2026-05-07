import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// ĐÃ XÓA import firebase_options.dart

// Import các file hiện tại của bạn
import 'services/api_service.dart';
import 'services/auth_provider.dart';
import 'services/theme_provider.dart';
import 'screen/login_screen.dart';
import 'screen/register_screen.dart';
import 'screen/main_navigation_screen.dart';
import 'screen/quiz_screen.dart';
import 'screen/vocabulary_screen.dart';
import 'screen/history_screen.dart';
import 'screen/live_camera_screen.dart';
import 'services/notification_provider.dart';

// 1. HÀM CHẠY NGẦM NHẬN THÔNG BÁO KHI TẮT APP
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Khởi tạo Firebase gọn nhẹ không cần options
  await Firebase.initializeApp();
  debugPrint("Đã nhận thông báo cảnh báo ngầm: ${message.messageId}");
}

void main() async {
  // Bắt buộc phải có khi tương tác với Native Code (Firebase) trước runApp
  WidgetsFlutterBinding.ensureInitialized();

  // 2. KHỞI TẠO FIREBASE (Không cần cấu hình options)
  await Firebase.initializeApp();

  // 3. ĐĂNG KÝ HÀM CHẠY NGẦM
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 4. XIN QUYỀN GỬI THÔNG BÁO (Quan trọng cho iOS/Android 13+)
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // 5. ĐĂNG KÝ KÊNH ĐỂ NGHE CẢNH BÁO TỪ SERVER
  await FirebaseMessaging.instance.subscribeToTopic('danger_alerts');

  // Khởi chạy App
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Smart Vocabulary Learning',
            debugShowCheckedModeBanner: false,
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AuthGateway(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/main': (context) => const MainNavigationScreen(),
              '/quiz': (context) => const QuizScreen(),
              '/vocabulary': (context) => const VocabularyScreen(),
              '/history': (context) => const HistoryScreen(),
              '/live_camera': (context) => const LiveCameraScreen(),
            },
          );
        },
      ),
    );
  }
}

/// Auth Gateway - Determines which screen to show based on auth state
class AuthGateway extends StatefulWidget {
  const AuthGateway({super.key});

  @override
  State<AuthGateway> createState() => _AuthGatewayState();
}

class _AuthGatewayState extends State<AuthGateway> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Check if token exists
    final token = await ApiService.getToken();

    if (mounted) {
      if (token != null) {
        // Token exists, navigate to main screen
        Navigator.of(context).pushReplacementNamed('/main');
      } else {
        // No token, navigate to login screen
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang khởi tạo ứng dụng...'),
          ],
        ),
      ),
    );
  }
}
