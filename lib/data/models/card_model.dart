import 'package:flow/data/models/task_model.dart';

class CardModel {
  final String id;
  final String title;
  final List<TaskModel> tasks;

  CardModel({
    required this.id,
    required this.title,
    required this.tasks,
  });

  factory CardModel.fromMap(Map<String, dynamic> map, String cardId) {
    var taskList = <TaskModel>[];
    if (map['tasks'] != null) {
      final tasksMap = Map<String, dynamic>.from(map['tasks']);
      tasksMap.forEach((taskId, taskData) {
        taskList.add(TaskModel.fromMap(Map<String, dynamic>.from(taskData), taskId));
      });
    }

    return CardModel(
      id: cardId,
      title: map['title'] ?? '',
      tasks: taskList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'tasks': {for (var t in tasks) t.id: t.toMap()},
    };
  }
}
