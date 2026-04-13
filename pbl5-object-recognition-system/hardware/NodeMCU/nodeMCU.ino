#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ArduinoJson.h>
#include <ESP8266HTTPClient.h>
#include <SoftwareSerial.h>
#include <DFRobotDFPlayerMini.h>

// ================= CẤU HÌNH MẠNG =================
const char* ssid = "D320";
const char* password = "tefloncf2";
const char* esp32cam_ip = "192.168.1.215";

// ================= CẤU HÌNH CHÂN =================
#define BTN_PIN D7           // Nút chụp ảnh
#define REPLAY_BTN_PIN D1    // Nút phát lại (Replay)
#define LED_PIN D2  

// ================= BIẾN TOÀN CỤC =================
bool lastState = HIGH;
bool lastReplayState = HIGH;   // Trạng thái nút Replay trước đó
int lastPlayedId = -1;         // Lưu ID của file âm thanh phát gần nhất (-1 là chưa phát gì)

bool isDanger = false;         // Cờ báo động nguy hiểm
unsigned long lastBlink = 0;   // Thời gian lần chớp cuối
bool ledState = LOW;           // Trạng thái LED hiện tại

ESP8266WebServer server(80);
SoftwareSerial mySerial(D6, D5); // RX = D6, TX = D5
DFRobotDFPlayerMini myDFPlayer;

// ================= HÀM XỬ LÝ POST /play =================
void handlePost() {
  if (!server.hasArg("plain")) {
    server.send(400, F("application/json"), F("{\"error\":\"No body\"}"));
    return;
  }

  String body = server.arg("plain");
  Serial.print(F("Received JSON: "));
  Serial.println(body);

  StaticJsonDocument<200> doc;
  DeserializationError error = deserializeJson(doc, body);

  if (error) {
    server.send(400, F("application/json"), F("{\"error\":\"Invalid JSON\"}"));
    return;
  }

  // 1. Lấy dữ liệu an toàn bằng JsonVariant
  JsonVariant led_var = doc["led"];
  int audio_id = doc["audio_id"];

  // 2. Ép kiểu về dạng chuỗi văn bản để so sánh
  String led_status = led_var.as<String>();

  // 3. Logic Đèn LED
  if (led_status == "1" || led_status == "red") {
    isDanger = true; 
    Serial.println(F("!!! CANH BAO NGUY HIEM !!!"));
  } else {
    isDanger = false;
    digitalWrite(LED_PIN, LOW); 
    Serial.println(F("Trang thai: AN TOAN."));
  }

  // 4. Logic Audio
  int new_id = audio_id + 1;
  lastPlayedId = new_id; // LƯU LẠI ID ĐỂ REPLAY

  char buffer[5];
  sprintf(buffer, "%04d", new_id);
  myDFPlayer.play(new_id);

  // 5. Trả về phản hồi cho Server
  String response = F("{\"status\":\"ok\",\"played\":\"");
  response += buffer;
  response += F("\"}");
  server.send(200, F("application/json"), response);
}

// ================= HÀM GỬI LỆNH CHỤP ẢNH =================
void sendCaptureCommand() {
  WiFiClient client;
  HTTPClient http;
  
  String url = F("http://");
  url += esp32cam_ip;
  url += F("/capture");
  
  http.begin(client, url);
  http.setTimeout(15000);
  
  int httpCode = http.GET();
  
  if (httpCode <= 0) {
    Serial.print(F("ERROR: "));
    Serial.println(http.errorToString(httpCode));
  } else {
    Serial.print(F("HTTP CODE: "));
    Serial.println(httpCode);
  }
  
  http.end();
}

void setup() {
  Serial.begin(115200);
  
  // Cấu hình chân
  pinMode(BTN_PIN, INPUT_PULLUP);
  pinMode(REPLAY_BTN_PIN, INPUT_PULLUP); // Cấu hình chân cho nút Replay
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);

  // Khởi tạo DFPlayer
  mySerial.begin(9600);
  if (!myDFPlayer.begin(mySerial)) {
    Serial.println(F("DFPlayer error!"));
  }
  myDFPlayer.volume(20); 

  // Kết nối WiFi
  WiFi.begin(ssid, password);
  Serial.print(F("Connecting WiFi"));
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(F("."));
  }
  
  Serial.println(F("\nConnected!"));
  Serial.print(F("IP: "));
  Serial.println(WiFi.localIP());

  // Khởi động HTTP Server
  server.on("/play", HTTP_POST, handlePost);
  server.begin();
  Serial.println(F("HTTP server started"));
}

// ================= LOOP =================
void loop() {
  // 1. Duy trì Server lắng nghe yêu cầu
  server.handleClient();

  // 2. Logic nháy đèn LED khi có cảnh báo
  if (isDanger) {
    unsigned long currentMillis = millis();
    if (currentMillis - lastBlink >= 300) { 
      lastBlink = currentMillis;
      ledState = !ledState;
      digitalWrite(LED_PIN, ledState);
    }
  }

  // 3. Logic nút nhấn CHỤP ẢNH
  bool currentState = digitalRead(BTN_PIN);
  if (lastState == HIGH && currentState == LOW) {
    Serial.println(F("NUT DA NHAN - Gui lenh chup anh..."));
    sendCaptureCommand();
    delay(500); // Chống dội nút (Debounce)
  }
  lastState = currentState;

  // 4. Logic nút nhấn REPLAY
  bool currentReplayState = digitalRead(REPLAY_BTN_PIN);
  if (lastReplayState == HIGH && currentReplayState == LOW) {
    Serial.println(F("NUT REPLAY DA NHAN - Phat lai am thanh..."));
    
    // Chỉ phát lại nếu đã từng có âm thanh được phát trước đó
    if (lastPlayedId != -1) {
      myDFPlayer.play(lastPlayedId);
    } else {
      Serial.println(F("Chua co am thanh nao de phat lai!"));
    }
    
    delay(500); // Chống dội nút
  }
  lastReplayState = currentReplayState;
}