#include <WiFi.h>
#include <TFT_eSPI.h>
#include <TJpg_Decoder.h>

// 1. Cấu hình WiFi
const char* ssid = "dddd";
const char* password = "hidroxyanuaHCN";

// 2. IP của mạch ESP32-CAM (Hãy kiểm tra IP chính xác trên Serial của CAM)
const char* cam_host = "10.227.38.141"; 
const int cam_port = 80;

TFT_eSPI tft = TFT_eSPI();
WiFiClient client;

// ====== CALLBACK VẼ JPEG (Tối ưu tốc độ đẩy pixel) ======
bool tft_output(int16_t x, int16_t y, uint16_t w, uint16_t h, uint16_t *bitmap) {
  if (y >= tft.height()) return 0;
  tft.pushImage(x, y, w, h, bitmap);
  return 1;
}

void setup() {
  Serial.begin(115200);

  // Khởi tạo màn hình TFT
  tft.init();
  tft.setRotation(1); // Xoay ngang 320x240
  tft.fillScreen(TFT_BLACK);
  
  // Cấu hình bộ giải mã JPG
  TJpgDec.setCallback(tft_output);
  TJpgDec.setJpgScale(1); // Giữ nguyên tỉ lệ 1:1 để ảnh nét nhất
  TJpgDec.setSwapBytes(true); // Đảm bảo bảng màu RGB565 chính xác

  // Kết nối WiFi
  tft.setTextColor(TFT_CYAN, TFT_BLACK);
  tft.drawString("Connecting to WiFi...", 10, 10, 2);
  
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  tft.fillScreen(TFT_BLACK);
  tft.drawString("WiFi OK! Connecting CAM...", 10, 10, 2);
  Serial.println("\nWiFi Connected.");
}

void loop() {
  // 1. Kiểm tra và kết nối lại luồng Stream nếu bị rớt
  if (!client.connected()) {
    Serial.println("Connecting to Camera Stream...");
    if (client.connect(cam_host, cam_port)) {
      client.print("GET /stream HTTP/1.1\r\n");
      client.print("Host: "); client.print(cam_host); client.print("\r\n");
      client.print("Connection: keep-alive\r\n\r\n");
    } else {
      delay(1000);
      return;
    }
  }

  // 2. Xử lý dữ liệu luồng Stream
  if (client.available()) {
    String line = client.readStringUntil('\n');
    
    // Tìm Header báo kích thước ảnh
    if (line.indexOf("Content-Length:") != -1) {
      int imgSize = line.substring(line.indexOf(":") + 1).toInt();
      
      // Đọc bỏ qua các dòng Header trống để tới dữ liệu nhị phân (Binary)
      while (client.readStringUntil('\n').length() > 1);

      if (imgSize > 0 && imgSize < 100000) { // Tăng giới hạn lên 100KB cho ảnh chất lượng cao
        uint8_t *jpgBuf = (uint8_t *)malloc(imgSize);
        
        if (jpgBuf) {
          int bytesRead = 0;
          uint32_t timeout = millis();

          // Hút toàn bộ dữ liệu ảnh vào Buffer (có cơ chế chống treo)
          while (bytesRead < imgSize && (millis() - timeout < 1500)) {
            if (client.available()) {
              int n = client.read(jpgBuf + bytesRead, imgSize - bytesRead);
              bytesRead += n;
              timeout = millis();
            }
          }

          // Giải mã và vẽ lên màn hình nếu đủ dữ liệu
          if (bytesRead == imgSize) {
            // Hiển thị ảnh tại tọa độ (0,0)
            TJpgDec.drawJpg(0, 0, jpgBuf, imgSize);
          } else {
            Serial.println("Frame incomplete - Dropped");
          }
          
          free(jpgBuf); // Giải phóng RAM ngay lập tức
        }
      }
    }
  }
}