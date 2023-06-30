import 'package:cloud_firestore/cloud_firestore.dart';

class KanbanBoard {
  String? name;
  int? iconColor;
  List<dynamic>? members;
  List<dynamic>? sections;

  KanbanBoard({
    required this.name,
    this.iconColor = 0xff808080,
    this.members = const [],
    this.sections = const [
      {
        "title": "To do",
        "tasks": [],
      },
      {
        "title": "In progress",
        "tasks": [],
      },
      {
        "title": "Done",
        "tasks": [],
      }
    ],
  });

  factory KanbanBoard.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return KanbanBoard(
      name: data?['name'],
      members: data?['members'],
      sections: data?['sections'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) "name": name,
      if (iconColor != null) "icon_color": iconColor,
      if (members != null) "members": members,
      if (sections != null) "sections": sections,
    };
  }
}
