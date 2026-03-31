class LogItemModel {
  final int id;
  final bool isSafe;
  final String imageUrl;
  final String nameVietnamese;
  final String nameEnglish;
  final String time;
  final String date;
  final double confidence;

  LogItemModel({
    required this.id,
    required this.isSafe,
    required this.imageUrl,
    required this.nameVietnamese,
    required this.nameEnglish,
    required this.time,
    required this.date,
    required this.confidence,
  });

  factory LogItemModel.fromJson(Map<String, dynamic> json) {
    String dateTimeStr = json['createdAt'] ?? '';
    String parsedDate = '';
    String parsedTime = '';

    // Tách thời gian từ định dạng: "2026-03-18 09:38:56"
    if (dateTimeStr.length >= 19) {
      parsedDate = dateTimeStr.substring(0, 10);
      parsedTime = dateTimeStr.substring(11, 19);
    }

    return LogItemModel(
      id: json['id'] ?? 0,
      isSafe: !(json['isDangerous'] ?? false),
      imageUrl: json['imageUrl'] ?? '',
      nameEnglish: json['objectEn'] ?? 'Unknown',
      nameVietnamese: json['objectVi'] ?? 'Không xác định',
      date: parsedDate,
      time: parsedTime,
      confidence: 0.95,
    );
  }
}
