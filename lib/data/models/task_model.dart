// class TaskModel {
//   final String id;
//   final String title;
//   final String description;
//   final bool isDone;

//   TaskModel({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.isDone,
//   });

//   factory TaskModel.fromMap(Map<String, dynamic> map, String taskId) {
//     return TaskModel(
//       id: taskId,
//       title: map['title'] ?? '',
//       description: map['description'] ?? '',
//       isDone: map['isDone'] ?? false,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'title': title,
//       'description': description,
//       'isDone': isDone,
//     };
//   }
// }

// class TaskModel {
//   final String id;
//   final String title;
//   final String description;
//   final bool isDone;

//   TaskModel({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.isDone,
//   });

//   factory TaskModel.fromMap(Map<String, dynamic> map, String taskId) {
//     return TaskModel(
//       id: taskId,
//       title: map['title'] ?? '',
//       description: map['description'] ?? '',
//       isDone: map['isDone'] ?? false,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'title': title,
//       'description': description,
//       'isDone': isDone,
//     };
//   }

//   TaskModel copyWith({
//     String? id,
//     String? title,
//     String? description,
//     bool? isDone,
//   }) {
//     return TaskModel(
//       id: id ?? this.id,
//       title: title ?? this.title,
//       description: description ?? this.description,
//       isDone: isDone ?? this.isDone,
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final bool isDone;
  final DateTime? startDate;
  final DateTime? dueDate;
  final int order; // <-- Новое поле

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isDone,
    this.startDate,
    this.dueDate,
    required this.order,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isDone,
    DateTime? startDate,
    DateTime? dueDate,
    int? order,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      order: order ?? this.order,
    );
  }

  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
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
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isDone': isDone,
      'startDate': startDate,
      'dueDate': dueDate,
      'order': order,
    };
  }
}
