class Course {
  final String? id;
  final String title;
  final String instructor;
  final String rating;
  final String image;
  final String videoUrl;
  final String category;
  final String price;
  final String description;
  final String duration;
  final String level;
  final int lessonsCount;
  final int studentsCount;
  final bool isFeatured;
  final bool isCompleted;
  final double progress;

  const Course({
    this.id,
    required this.title,
    required this.instructor,
    required this.rating,
    required this.image,
    required this.videoUrl,
    required this.category,
    required this.price,
    this.description = '',
    this.duration = '8 soat',
    this.level = 'Intermediate',
    this.lessonsCount = 8,
    this.studentsCount = 120,
    this.isFeatured = false,
    this.isCompleted = false,
    this.progress = 0.12,
  });

  factory Course.fromMap(Map<String, dynamic> data, {String? id}) {
    return Course(
      id: id,
      title: (data['title'] ?? 'Nomsiz kurs').toString(),
      instructor: (data['instructor'] ?? 'Mentor').toString(),
      rating: (data['rating'] ?? '4.8').toString(),
      image: (data['image'] ?? 'https://picsum.photos/seed/course/800/600')
          .toString(),
      videoUrl:
          (data['videoUrl'] ?? 'https://www.youtube.com/watch?v=fq4N0hgOWzU')
              .toString(),
      category: (data['category'] ?? 'General').toString(),
      price: (data['price'] ?? 'Bepul').toString(),
      description:
          (data['description'] ??
                  "Amaliy topshiriqlar, mentor yordami va aniq yo'l xaritasi bilan tuzilgan kurs.")
              .toString(),
      duration: (data['duration'] ?? '8 soat').toString(),
      level: (data['level'] ?? 'Intermediate').toString(),
      lessonsCount: _parseInt(data['lessonsCount'], fallback: 8),
      studentsCount: _parseInt(data['studentsCount'], fallback: 120),
      isFeatured: data['isFeatured'] == true,
      isCompleted: data['isCompleted'] == true,
      progress: _parseDouble(data['progress'], fallback: 0.12).clamp(0.0, 1.0),
    );
  }

  Map<String, dynamic> toEnrollmentMap() {
    return {
      'title': title,
      'image': image,
      'category': category,
      'instructor': instructor,
      'price': price,
      'rating': rating,
      'videoUrl': videoUrl,
      'description': description,
      'duration': duration,
      'level': level,
      'lessonsCount': lessonsCount,
      'studentsCount': studentsCount,
      'isFeatured': isFeatured,
      'isCompleted': isCompleted,
      'progress': progress,
    };
  }

  Course copyWith({
    String? id,
    String? title,
    String? instructor,
    String? rating,
    String? image,
    String? videoUrl,
    String? category,
    String? price,
    String? description,
    String? duration,
    String? level,
    int? lessonsCount,
    int? studentsCount,
    bool? isFeatured,
    bool? isCompleted,
    double? progress,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      instructor: instructor ?? this.instructor,
      rating: rating ?? this.rating,
      image: image ?? this.image,
      videoUrl: videoUrl ?? this.videoUrl,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      level: level ?? this.level,
      lessonsCount: lessonsCount ?? this.lessonsCount,
      studentsCount: studentsCount ?? this.studentsCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
    );
  }

  double get numericRating => _parseDouble(rating, fallback: 4.8);

  bool get isFree {
    final lower = price.toLowerCase();
    return lower.contains('bepul') || lower == '0' || lower == '0\$';
  }

  String get progressLabel => '${(progress * 100).round()}%';

  static int _parseInt(dynamic value, {required int fallback}) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static double _parseDouble(dynamic value, {required double fallback}) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
