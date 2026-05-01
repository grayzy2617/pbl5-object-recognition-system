// lib/models/user_model.dart
class User {
  final int? id;
  final String username;
  final String email;
  final String? fullName;
  final String? bio;
  final String? avatarUrl;
  final int? totalScore;

  User({
    this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.bio,
    this.avatarUrl,
    this.totalScore,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'],
      bio: json['bio'],
      avatarUrl: json['avatar_url'],
      totalScore: json['total_score'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'bio': bio,
      'avatar_url': avatarUrl,
      'total_score': totalScore,
    };
  }
}

// lib/models/quiz_model.dart
class Question {
  final int dictId;
  final String questionEn;
  final int correctId;
  final List<Option> options;

  Question({
    required this.dictId,
    required this.questionEn,
    required this.correctId,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      dictId: json['dict_id'] ?? 0,
      questionEn: json['question_en'] ?? '',
      correctId: json['correct_id'] ?? 0,
      options:
          (json['options'] as List<dynamic>?)
              ?.map((opt) => Option.fromJson(opt as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Option {
  final int id;
  final String textVn;

  Option({required this.id, required this.textVn});

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(id: json['id'] ?? 0, textVn: json['text_vn'] ?? '');
  }
}

class QuizAnswer {
  final int dictId;
  final bool isCorrect;

  QuizAnswer({required this.dictId, required this.isCorrect});

  Map<String, dynamic> toJson() {
    return {'dict_id': dictId, 'is_correct': isCorrect};
  }
}

class QuizResult {
  final int correct;
  final int total;
  final int gainedScore;
  final int totalScore;

  QuizResult({
    required this.correct,
    required this.total,
    required this.gainedScore,
    required this.totalScore,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      correct: json['correct'] ?? 0,
      total: json['total'] ?? 0,
      gainedScore: json['gained_score'] ?? 0,
      totalScore: json['total_score'] ?? 0,
    );
  }

  double get accuracy => total > 0 ? (correct / total * 100) : 0.0;
}

// lib/models/vocabulary_model.dart
class VocabularyItem {
  final int id;
  final String aiLabel;
  final String nameVn;
  final int isDangerous;

  VocabularyItem({
    required this.id,
    required this.aiLabel,
    required this.nameVn,
    required this.isDangerous,
  });

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      id: json['id'] ?? 0,
      aiLabel: json['ai_label'] ?? '',
      nameVn: json['name_vn'] ?? '',
      isDangerous: json['is_dangerous'] ?? 0,
    );
  }

  bool get isSafe => isDangerous == 0;
}

class HistoryItem {
  final int id;
  final String objectEn;
  final String objectVi;
  final bool isDangerous;
  final String imageUrl;
  final DateTime? createdAt;

  HistoryItem({
    required this.id,
    required this.objectEn,
    required this.objectVi,
    required this.isDangerous,
    required this.imageUrl,
    this.createdAt,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] ?? 0,
      objectEn: json['objectEn'] ?? json['ai_label'] ?? '',
      objectVi: json['objectVi'] ?? json['name_vn'] ?? '',
      isDangerous: json['isDangerous'] == true,
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}

class ProfileStats {
  final int totalQuizzes;
  final int totalQuestions;
  final int totalCorrect;
  final double accuracyPct;
  final int totalScore;
  final int bestScore;
  final int aiDetections;

  ProfileStats({
    required this.totalQuizzes,
    required this.totalQuestions,
    required this.totalCorrect,
    required this.accuracyPct,
    required this.totalScore,
    required this.bestScore,
    required this.aiDetections,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      totalQuizzes: json['total_quizzes'] ?? 0,
      totalQuestions: json['total_questions'] ?? 0,
      totalCorrect: json['total_correct'] ?? 0,
      accuracyPct: (json['accuracy_pct'] ?? 0.0).toDouble(),
      totalScore: json['total_score'] ?? 0,
      bestScore: json['best_score'] ?? 0,
      aiDetections: json['ai_detections'] ?? 0,
    );
  }
}
