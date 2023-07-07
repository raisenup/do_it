import 'package:cloud_firestore/cloud_firestore.dart';

class KanbanBoard {
  final String? uuid;
  final String? name;
  final int? iconColor;
  final List<dynamic>? members;
  final List<dynamic>? sections;

  const KanbanBoard({
    this.uuid,
    required this.name,
    this.iconColor,
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
      uuid: data?['uuid'],
      name: data?['name'],
      iconColor: data?['icon_color'],
      members: data?['members'],
      sections: data?['sections'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (uuid != null) "uuid": uuid,
      if (name != null) "name": name,
      if (iconColor != null) "icon_color": iconColor,
      if (members != null) "members": members,
      if (sections != null) "sections": sections,
    };
  }
}
