import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String? title;
  final String? description;
  final DateTime? dueDate; 
  final int? priority; // null - without priority, 0 - done, 1-3 - priority
  final List<dynamic>? assignedTo; // by default is empty

  const Task({
    required this.title,
    this.description,
    this.dueDate,
    this.priority,
    this.assignedTo = const [],
  });

  factory Task.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Task(
      title: data?['title'],
      description: data?['description'],
      dueDate: data?['due_date'],
      priority: data?['priority'],
      assignedTo: data?['assigned_to'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (title != null) "title": title,
      if (description != null) "description": description,
      if (dueDate != null) "due_date": dueDate,
      if (priority != null) "priority": priority,
      if (assignedTo != null) "assigned_to": assignedTo,
    };
  }
}
