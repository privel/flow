import 'package:flow/data/models/task_model.dart';

// class CardModel {
//   final String id;
//   final String title;
//   final List<TaskModel> tasks;

//   CardModel({
//     required this.id,
//     required this.title,
//     required this.tasks,
//   });

//   factory CardModel.fromMap(Map<String, dynamic> map, String cardId) {
//     var taskList = <TaskModel>[];
//     if (map['tasks'] != null) {
//       final tasksMap = Map<String, dynamic>.from(map['tasks']);
//       tasksMap.forEach((taskId, taskData) {
//         taskList.add(TaskModel.fromMap(Map<String, dynamic>.from(taskData), taskId));
//       });
//     }

//     return CardModel(
//       id: cardId,
//       title: map['title'] ?? '',
//       tasks: taskList,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'title': title,
//       'tasks': {for (var t in tasks) t.id: t.toMap()},
//     };
//   }
// }


class CardModel {
  final String id;
  final String title;
  final Map<String, TaskModel> tasks;

  CardModel({
    required this.id,
    required this.title,
    required this.tasks,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'tasks': {for (var e in tasks.entries) e.key: e.value.toMap()},
    };
  }

  CardModel copyWith({
    String? id,
    String? title,
    Map<String, TaskModel>? tasks,
  }) {
    return CardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      tasks: tasks ?? Map<String, TaskModel>.from(this.tasks),
    );
  }
}
