class TaskModel {
  final String id;
  final String title;
  final String description;
  final bool isDone;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isDone,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String taskId) {
    return TaskModel(
      id: taskId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isDone: map['isDone'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isDone': isDone,
    };
  }
}
