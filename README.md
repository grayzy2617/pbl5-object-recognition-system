# PBL5
Project_Root/
│
├── 📂 hardware/               # Toàn bộ phần cứng & Firmware
│   ├── 📂 firmware/           # Code nạp cho ESP32-CAM (C++/Arduino)
│   ├── 📂 schemas/            # Sơ đồ nguyên lý (Proteus, Altium, PDF)
│   └── 📜 hardware_bom.md     # Danh sách linh kiện (Bill of Materials)
│
├── 📂 backend/                # Mã nguồn Server (Spring Boot/FastAPI...)
│   ├── 📂 src/
│   ├── 📜 pom.xml or req.txt  # File quản lý thư viện
│   
│
├── 📂 frontend/               # Giao diện người dùng (React/Mobile App)
│   ├── 📂 public/
│   └── 📂 src/
│
├── 📂 ai_module/              # Phần xử lý trí tuệ nhân tạo
│   ├── 📂 datasets/           # Dữ liệu train (nên để mẫu, không push data nặng)
│   ├── 📂 notebooks/          # File .ipynb để thử nghiệm/train model
│   ├── 📂 models/             # Chứa file model đã train (.h5, .pth, .tflite)
│   └── 📜 inference.py        # Script chạy thực tế để Backend gọi
│
├── 📂 docs/                   # Tài liệu môn học
│   ├── 📜 SRS.pdf             # Đặc tả yêu cầu
│   └── 📜 Report_PBL5.docx    # Báo cáo tiến độ/kết thúc
│
├── 📜 .gitignore              # Khai báo các file không đưa lên Git
├── 📜 README.md               # Hướng dẫn cài đặt và chạy đồ án
└── 📜 docker-compose.yml      # (Tùy chọn) Kết nối Backend, DB, AI lại với nhau
