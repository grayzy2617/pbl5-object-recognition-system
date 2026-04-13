from flask import Flask, request, jsonify
import numpy as np
import cv2
from datetime import datetime
import cloudinary
import cloudinary.uploader
import mysql.connector
import os
import traceback
from ultralytics import YOLO
from flask_cors import CORS
import requests
import threading
import time

app = Flask(__name__)
CORS(app)

model = YOLO("best.pt")

cloudinary.config(
    cloud_name="dn71wgng3",
    api_key="125962815347642",
    api_secret="xh-MHpbbqyyFyEQsUMPlBWRBK7s"
)

def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="20012005",
        database="pbl5",
        charset="utf8mb4"
    )


def predict_image(img):
    results = model(img)
    if not results:
        return None

    r = results[0]

    # TH1: Model Classification (Dựa trên log của bạn, khả năng cao là cái này)
    if hasattr(r, 'probs') and r.probs is not None:
        cls_id = int(r.probs.top1)
        return model.names[cls_id]

    # TH2: Model Object Detection (Nếu có khung hình)
    if r.boxes is not None and len(r.boxes) > 0:
        confs = r.boxes.conf
        max_idx = confs.argmax()
        cls_id = int(r.boxes.cls[max_idx])
        return model.names[cls_id]

    return None

# HAM GUI LOA CHO NODE MCU
def send_to_ip(dict_id, is_dangerous):
    url = "http://192.168.1.236/play" # id cua nodemcu
    
    payload = {
        "audio_id": int(dict_id),          
        "led": "1" if int(is_dangerous) == 1 else "0" 
    }

    max_retries = 3  

    for attempt in range(max_retries):
        try:
            response = requests.post(url, json=payload, timeout=5)
            
            if response.status_code == 200:
                print(f"[THÀNH CÔNG] Đã gửi NodeMCU ở lần thử thứ {attempt + 1}: {payload}")
                return 
            else:
                print(f"[CẢNH BÁO] NodeMCU trả về mã lỗi: {response.status_code}")
                
        except requests.exceptions.RequestException as e:
            print(f"[ĐỢI] Lần thử {attempt + 1}/{max_retries} thất bại. NodeMCU đang bận...")
                    
        time.sleep(1.5) 

    print(" [THẤT BẠI] Đã thử 3 lần nhưng NodeMCU không phản hồi. Vui lòng kiểm tra lại nguồn điện hoặc WiFi của mạch.")

@app.route("/history", methods=["GET"])
def get_history():
    conn = get_db_connection()
    # Dùng dictionary=True để gọi row['tên_cột'] thay vì row[số]
    cursor = conn.cursor(dictionary=True)

    query = """
        SELECT 
            h.id,
            d.ai_label,
            d.name_vn,
            d.is_dangerous,
            h.image_url,
            h.created_at
        FROM history h
        LEFT JOIN dictionary d ON h.dict_id = d.id
        ORDER BY h.created_at DESC
    """

    cursor.execute(query)
    rows = cursor.fetchall()

    result = []
    for row in rows:
        # Xử lý thời gian an toàn
        created_at_val = row['created_at']
        if created_at_val and hasattr(created_at_val, 'isoformat'):
            created_at_str = created_at_val.isoformat()
        else:
            created_at_str = str(created_at_val) if created_at_val else None

        result.append({
        "id": row["id"],
        "objectEn": row["ai_label"],
        "objectVi": row["name_vn"],
        "isDangerous": bool(row["is_dangerous"]) if row["is_dangerous"] is not None else False,
        "imageUrl": row["image_url"],
        "createdAt": str(row["created_at"])
    })

    cursor.close()
    conn.close()

    return jsonify(result)

# Thêm endpoint này vào file Flask của bạn
@app.route("/dictionary", methods=["GET"])
def get_dictionary():
    db = get_db_connection()
    cursor = db.cursor(dictionary=True) # Dùng dictionary=True để trả về dạng key-value
    try:
        cursor.execute("SELECT id, ai_label, name_vn, is_dangerous FROM dictionary")
        rows = cursor.fetchall()
        return jsonify(rows)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()
        db.close()

# Endpoint chính: /upload
@app.route("/upload", methods=["POST"])
def upload():
    db = None
    filepath = None
    print("Received /upload request")
    try:
        # Nhận ảnh
        if "image" in request.files:
            img_bytes = request.files["image"].read()
        elif request.data:
            img_bytes = request.data
        else:
            return jsonify({"error": "No image data"}), 400

        npimg = np.frombuffer(img_bytes, np.uint8)
        img = cv2.imdecode(npimg, cv2.IMREAD_COLOR)
        if img is None:
            return jsonify({"error": "Invalid image format"}), 400

        # Nhận diện AI
        ai_label = predict_image(img)
        print(f"--- AI Result: {ai_label} ---")

        if not ai_label:
            return jsonify({"error": "AI could not detect anything"}), 400

        # Tra Dictionary lấy dict_id
        db = get_db_connection()
        cursor = db.cursor(buffered=True)
        
        cursor.execute("SELECT id, is_dangerous FROM Dictionary WHERE ai_label = %s", (ai_label.strip(),))
        row = cursor.fetchone()
        
        if row is None:
            return jsonify({"error": f"Label '{ai_label}' not found in Dictionary"}), 404
        
        dict_id = row[0]
        is_dangerous = row[1]
        
        print("DICT:", dict_id, is_dangerous)

        threading.Thread(
            target=send_to_ip,
            args=(dict_id, is_dangerous),
            daemon=True
        ).start()

        # Upload Cloudinary
        os.makedirs("images", exist_ok=True)
        filename = f"cap_{datetime.now().strftime('%H%M%S')}.jpg"
        filepath = os.path.join("images", filename)
        cv2.imwrite(filepath, img)

        cloud = cloudinary.uploader.upload(filepath)
        image_url = cloud["secure_url"]

        # Lưu History
        cursor.execute(
            "INSERT INTO history (dict_id, image_url) VALUES (%s, %s)",
            (dict_id, image_url)
        )
        db.commit()

        # PHẢN HỒI 
        return jsonify({
            "label": ai_label,
            "dict_id": dict_id,
            "image_url": image_url
        })

    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500
    finally:
        if db and db.is_connected():
            cursor.close()
            db.close()
        if filepath and os.path.exists(filepath):
            os.remove(filepath)

# Chạy Server
if __name__ == "__main__":
    @app.route("/", methods=["GET"])
    def home():
        return jsonify({"status": "Server 5000 is running"})

    app.run(host="0.0.0.0", port=5000, debug=True)