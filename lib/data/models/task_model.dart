import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final bool isDone;
  final DateTime? startDate;
  final DateTime? dueDate;
  final Map<String, DateTime> assignees;
  final int order;
  final Map<String, Map<String, dynamic>> images;
  final Map<String, bool> lablesColor;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isDone,
    this.startDate,
    this.dueDate,
    required this.assignees,
    required this.order,
    this.images = const {},
    this.lablesColor = const {
      "#b60205": false,
      "#d93f0b": false,
      "#fbca04": false,
      "#0e8a16": false,
      "#006b75": false,
      "#1d76db": false,
      
    },
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isDone,
    DateTime? startDate,
    DateTime? dueDate,
    Map<String, DateTime>? assignees,
    int? order,
    Map<String, Map<String, dynamic>>? images,
    Map<String, bool>? lablesColor,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      assignees: assignees ?? this.assignees,
      order: order ?? this.order,
      images: images ?? this.images,
      lablesColor: lablesColor ?? this.lablesColor,
    );
  }

  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    final Map<String, Map<String, dynamic>> parsedImages = {};
    if (map['images'] != null && map['images'] is Map) {
      (map['images'] as Map<String, dynamic>).forEach((imageId, imageData) {
        if (imageData is Map<String, dynamic>) {
          parsedImages[imageId] = {
            'url': imageData['url'] as String? ?? '',
            'dateAdded': imageData['dateAdded'] != null
                ? (imageData['dateAdded'] as Timestamp).toDate()
                : DateTime.now(),
            'order': imageData['order'] as int? ?? 0,
          };
        }
      });
    }

    Map<String, bool> parsedLablesColor = {};
    if (map['lablesColor'] != null && map['lablesColor'] is Map) {
      (map['lablesColor'] as Map<String, dynamic>).forEach((key, value) {
        // Ensure the value is indeed a boolean
        if (value is bool) {
          parsedLablesColor[key] = value;
        } else {
          // Handle cases where the value might be something else (e.g., old data, null)
          // You can choose to default to false, true, or log an error.
          parsedLablesColor[key] = false; // Defaulting to false for robustness
        }
      });
    }
    return TaskModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isDone: map['isDone'] ?? false,
      startDate: map['startDate'] != null
          ? (map['startDate'] as Timestamp).toDate()
          : null,
      dueDate: map['dueDate'] != null
          ? (map['dueDate'] as Timestamp).toDate()
          : null,
      assignees: map['assignees'] != null && map['assignees'] is Map
          ? (map['assignees'] as Map<String, dynamic>).map(
              (key, value) {
                try {
                  return MapEntry(key, (value as Timestamp).toDate());
                } catch (_) {
                  return MapEntry(key, DateTime.now());
                }
              },
            )
          : {},
      order: map['order'] ?? 0,
      images: parsedImages,
      lablesColor: parsedLablesColor,
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, Map<String, dynamic>> imagesToMap = {};
    images.forEach((imageId, imageData) {
      imagesToMap[imageId] = {
        'url': imageData['url'],
        'dateAdded': Timestamp.fromDate(imageData['dateAdded']),
        'order': imageData['order'],
      };
    });

    return {
      'title': title,
      'description': description,
      'isDone': isDone,
      'startDate': startDate,
      'dueDate': dueDate,
      'assignees': assignees
          .map((key, value) => MapEntry(key, Timestamp.fromDate(value))),
      'order': order,
      'images': imagesToMap,
      'lablesColor': lablesColor,
    };
  }
}
