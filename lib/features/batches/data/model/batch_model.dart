class BatchModel {
  final String id;
  final String userId;
  final String batchName;
  final String breed;
  final int birdCount;
  final int ageWeeks;
  final int mortalityCount;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BatchModel({
    required this.id,
    required this.userId,
    required this.batchName,
    required this.breed,
    required this.birdCount,
    required this.ageWeeks,
    required this.mortalityCount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory BatchModel.fromMap(Map<String, dynamic> map) {
    return BatchModel(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      batchName: map['batch_name'] as String? ?? '',
      breed: map['breed'] as String? ?? '',
      birdCount: ((map['quantity'] ?? map['bird_count']) as num?)?.toInt() ?? 0,
      ageWeeks: (map['age_weeks'] as num?)?.toInt() ?? 0,
      mortalityCount: (map['mortality_count'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? 'Active',
      createdAt:
          DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'batch_name': batchName,
      'breed': breed,
      'bird_count': birdCount,
      'age_weeks': ageWeeks,
      'mortality_count': mortalityCount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  BatchModel copyWith({
    String? id,
    String? userId,
    String? batchName,
    String? breed,
    int? birdCount,
    int? ageWeeks,
    int? mortalityCount,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BatchModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      batchName: batchName ?? this.batchName,
      breed: breed ?? this.breed,
      birdCount: birdCount ?? this.birdCount,
      ageWeeks: ageWeeks ?? this.ageWeeks,
      mortalityCount: mortalityCount ?? this.mortalityCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
