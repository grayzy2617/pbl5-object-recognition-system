# AI Learning System - Flutter App

Đây là ứng dụng di động (Frontend) được viết bằng Flutter cho dự án **"Hệ thống học từ vựng thông minh qua nhận diện hình ảnh AI bằng ESP32-CAM"**. Ứng dụng cung cấp giao diện hiện đại, kết nối với Server Flask backend để quản lý người dùng, xem lịch sử nhận diện AI, làm bài trắc nghiệm và học từ vựng qua Flashcard.

## 🌟 Tính năng nổi bật

* **Xác thực bảo mật:** Đăng nhập, Đăng ký an toàn với JWT Token.
* **Chế độ Sáng/Tối (Light/Dark Mode):** Hỗ trợ đổi Theme toàn ứng dụng mượt mà, lưu trạng thái cục bộ.
* **Dashboard & Lịch sử AI:** Theo dõi trạng thái kết nối ESP32-CAM, thống kê số lượng vật thể an toàn/nguy hiểm và xem timeline nhận diện.
* **Xuất dữ liệu (Export CSV):** Hỗ trợ trích xuất lịch sử nhận diện ra định dạng `.csv` lưu trực tiếp vào máy.
* **Từ điển & Flashcard:** Xem danh sách từ vựng AI hỗ trợ. Học qua thẻ Flashcard 3D có hiệu ứng lật và âm thanh sinh động.
* **Trắc nghiệm (Quiz):** Hệ thống tạo câu hỏi tự động, chấm điểm thời gian thực và tích lũy điểm số vào hồ sơ.

## 🛠 Công nghệ sử dụng

* **Framework:** Flutter / Dart
* **State Management:** Provider (`theme_provider`, `auth_provider`)
* **Local Storage:** `shared_preferences` (Lưu JWT và cài đặt)
* **Networking:** `http` (Tương tác với RESTful API)
* **Utilities:** `csv` & `path_provider` (Xuất file), `audioplayers` (Âm thanh lật thẻ).

## 📂 Cấu trúc thư mục (lib/)

```text
lib/
├── models/                  # Các lớp cấu trúc dữ liệu (User, History, Vocab...)
├── providers/               # Quản lý trạng thái toàn cục (State Management)
│   ├── auth_provider.dart
│   └── theme_provider.dart
├── screens/                 # Giao diện các trang
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── main_navigation_screen.dart # Chứa BottomNavigationBar
│   ├── history_screen.dart         # Dashboard và Lịch sử
│   ├── vocabulary_screen.dart      # Từ điển & Flashcard 3D
│   ├── quiz_screen.dart            # Trắc nghiệm
│   └── profile_screen.dart         # Thông tin user & Setting Theme
├── services/                # Các dịch vụ giao tiếp với bên ngoài
│   └── api_service.dart            # Gọi API và gắn Token JWT
├── widgets/                 # Các Component UI tái sử dụng
│   ├── custom_card.dart
│   └── log_item_widget.dart
└── main.dart                # Điểm khởi chạy của ứng dụng