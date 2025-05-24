import 'package:flow/data/models/task_model.dart';


class CardModel {
  final String id;
  final String title;
  final Map<String, TaskModel> tasks;
  final int order; 

  CardModel({
    required this.id,
    required this.title,
    required this.tasks,
    required this.order,
  });

  factory CardModel.fromMap(Map<String, dynamic> map, String cardId) {
    final tasksMapRaw = Map<String, dynamic>.from(map['tasks'] ?? {});
    final tasksMap = <String, TaskModel>{};

    tasksMapRaw.forEach((taskId, taskData) {
      tasksMap[taskId] = TaskModel.fromMap(Map<String, dynamic>.from(taskData), taskId);
    });

    return CardModel(
      id: cardId,
      title: map['title'] ?? '',
      tasks: tasksMap,
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'order': order,
      'tasks': {for (var e in tasks.entries) e.key: e.value.toMap()},
    };
  }

  CardModel copyWith({
    String? id,
    String? title,
    int? order,
    Map<String, TaskModel>? tasks,
  }) {
    return CardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      order: order ?? this.order,
      tasks: tasks ?? Map<String, TaskModel>.from(this.tasks),
    );
  }
}
