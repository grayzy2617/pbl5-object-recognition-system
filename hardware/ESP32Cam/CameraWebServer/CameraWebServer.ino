#include "esp_camera.h"
#include <WiFi.h>
#include <WebServer.h>
#include <HTTPClient.h>
#include "board_config.h"

const char* ssid = "D320";
const char* password = "tefloncf2";

/* server Python */
const char* uploadServer = "http://192.168.1.69:5000/upload";

WebServer server(80);

// Các cờ hiệu (flags) để điều phối luồng an toàn
bool isUploading = false; 
bool needCapture = false; // Cờ báo hiệu có lệnh chụp từ NodeMCU

// --- KHAI BÁO BIẾN CHO STREAM CHẠY SONG SONG ---
WiFiClient streamClient;
bool isStreaming = false;

/* ======================
   UPLOAD TASK
====================== */
void uploadTask(void * parameter){
  camera_fb_t *fb = (camera_fb_t*)parameter;

  if(!fb){
    Serial.println("[Upload Task] LỖI: Buffer ảnh trống, hủy task!");
    isUploading = false;
    vTaskDelete(NULL);
    return;
  }

  Serial.println("[Upload Task] Đang kết nối WiFi để upload...");
  
  if (WiFi.status() == WL_CONNECTED) {
    WiFiClient client;
    HTTPClient http;
    http.setTimeout(15000); 

    if(http.begin(client, uploadServer)){
      http.addHeader("Content-Type","image/jpeg");
      Serial.println("[Upload Task] Đang POST ảnh lên server...");
      
      int httpResponse = http.POST(fb->buf, fb->len);
      Serial.printf("[Upload Task] Server phản hồi HTTP: %d\n", httpResponse);

      http.end();
    } else {
      Serial.println("[Upload Task] LỖI: Không kết nối được Server Python.");
    }
  } else {
     Serial.println("[Upload Task] LỖI: Rớt mạng WiFi!");
  }

  // Dọn dẹp và mở khóa hệ thống
  esp_camera_fb_return(fb);
  isUploading = false; 
  Serial.println("[Upload Task] Hoàn tất. Đã mở khóa cho lần chụp tiếp theo.\n");
  vTaskDelete(NULL);
}

/* ======================
   CAPTURE (Chỉ nhận lệnh và báo OK)
====================== */
void handleCapture(){
  Serial.println("--- CÓ LỆNH TỪ NODEMCU ---");
  
  if (isUploading || needCapture) {
    Serial.println("[Capture] Hệ thống đang bận. Bỏ qua.");
    server.send(429, "text/plain", "Busy");
    return;
  }
  
  // Trả lời NodeMCU ngay lập tức để NodeMCU không bị treo chờ
  server.send(200, "text/plain", "OK");
  Serial.println("[Capture] Đã báo OK về NodeMCU. Chuẩn bị chụp...");
  
  // Bật cờ để vòng lặp loop() tự động đi chụp ảnh
  needCapture = true; 
}

/* ======================
   ROOT & CAMERA SETUP
====================== */
void handleRoot(){
  server.send(200,"text/plain","ESP32-CAM SERVER RUNNING");
}

void setupCamera(){
  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = Y2_GPIO_NUM; config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM; config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM; config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM; config.pin_d7 = Y9_GPIO_NUM;
  config.pin_xclk = XCLK_GPIO_NUM; config.pin_pclk = PCLK_GPIO_NUM;
  config.pin_vsync = VSYNC_GPIO_NUM; config.pin_href = HREF_GPIO_NUM;
  config.pin_sccb_sda = SIOD_GPIO_NUM; config.pin_sccb_scl = SIOC_GPIO_NUM;
  config.pin_pwdn = PWDN_GPIO_NUM; config.pin_reset = RESET_GPIO_NUM;
  config.xclk_freq_hz = 20000000;
  config.pixel_format = PIXFORMAT_JPEG;
  config.frame_size = FRAMESIZE_QVGA;  
  config.jpeg_quality = 12;
  config.fb_count = 1;

  if(psramFound()){
    config.fb_count = 2;
    config.jpeg_quality = 10;
  }

  if(esp_camera_init(&config) != ESP_OK){
    Serial.println("Camera init failed");
  }
}

/* ======================
   STREAM (Đã phá bỏ vòng lặp while)
====================== */
void handleStream(){
  streamClient = server.client(); // Lưu lại thiết bị đang xem (Trình duyệt)
  String response =
  "HTTP/1.1 200 OK\r\n"
  "Content-Type: multipart/x-mixed-replace; boundary=frame\r\n\r\n";

  streamClient.print(response);
  isStreaming = true; // Bật cờ cho phép stream chạy ở hàm loop()
  Serial.println("[Stream] Có trình duyệt đang xem video.");
}
void handleJPG(){
  camera_fb_t *fb = esp_camera_fb_get();
  if (!fb) {
    server.send(500, "text/plain", "Camera error");
    return;
  }

  server.send_P(200, "image/jpeg", (const char*)fb->buf, fb->len);
  esp_camera_fb_return(fb);
}

/* ======================
   SETUP
====================== */
void setup(){
  Serial.begin(115200);
  setupCamera();

  WiFi.begin(ssid,password);
  Serial.print("Connecting WiFi");
  while(WiFi.status()!=WL_CONNECTED){
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected");
  Serial.print("ESP32 IP: ");
  Serial.println(WiFi.localIP());

  server.on("/",handleRoot);
  server.on("/capture",handleCapture);
  server.on("/stream",handleStream);
  server.on("/jpg", handleJPG);
  server.begin();
}

/* ======================
   LOOP (Xử lý ĐA NHIỆM)
====================== */
void loop(){
  // 1. Luôn ưu tiên xử lý tín hiệu mạng trước
  server.handleClient();

  // 2. Chạy Video Stream (Chỉ thực hiện khi cờ isStreaming được bật)
  if (isStreaming) {
    if (!streamClient.connected()) {
      isStreaming = false;
      streamClient.stop();
      Serial.println("[Stream] Trình duyệt đã đóng.");
    } else {
      // Chỉ bơm ảnh Stream khi KHÔNG bận chụp và KHÔNG bận upload
      if (!isUploading && !needCapture) {
        camera_fb_t *fb = esp_camera_fb_get();
        if (fb) {
          streamClient.printf("--frame\r\nContent-Type: image/jpeg\r\nContent-Length: %u\r\n\r\n", fb->len);
          streamClient.write(fb->buf, fb->len);
          streamClient.print("\r\n");
          esp_camera_fb_return(fb);
        }
      }
    }
  }

  // 3. Kiểm tra xem có lệnh chụp bị treo lại từ hàm handleCapture không
  if (needCapture && !isUploading) {
    needCapture = false; // Tắt cờ
    isUploading = true;  // Khóa hệ thống (Luồng stream ở bước 2 sẽ tự động khựng lại)
    
    Serial.println("[Loop] Bắt đầu khởi động cảm biến để chụp...");
    camera_fb_t *fb = esp_camera_fb_get();

    if(!fb){
      Serial.println("[Loop] LỖI: Chụp thất bại!");
      isUploading = false;
    } else {
      Serial.println("[Loop] Chụp thành công! Đẩy vào Task Upload...");
      BaseType_t xReturned = xTaskCreate(uploadTask, "uploadTask", 8192, fb, 1, NULL);
      if (xReturned != pdPASS) {
         Serial.println("[Loop] LỖI: Hết RAM tạo Task!");
         esp_camera_fb_return(fb); 
         isUploading = false;
      }
    }
  }
}