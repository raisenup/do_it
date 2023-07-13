import 'package:do_it/core/task.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskWidget extends StatefulWidget {
  // callbacks
  final void Function(dynamic, dynamic, dynamic) editingCallback;

  final dynamic context;
  final dynamic sectionIndex;
  final dynamic taskIndex;

  // task
  final Task? task;

  const TaskWidget({
    required this.editingCallback,
    required this.context,
    required this.sectionIndex,
    required this.taskIndex,
    required this.task,
    super.key,
  });

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  static const List<dynamic> priorityColors = [
    Color(0xff36d100),
    Color(0xff0086d1),
    Color(0xffd1c900),
    Color(0xffd10000),
  ];

  Color dueDateColor = const Color(0xff000000);

  Future getPhotoURL(String email) async {
    String? url;
    await FirebaseFirestore.instance.collection('users').doc(email).get().then(
      (value) {
        url = value.data()?['photo_url'];
      },
    ).catchError((e) {
      debugPrint(e);
    });
    if (url != null) {
      return url;
    } else {
      return 'http://www.gravatar.com/avatar/?d=mp';
    }
  }

  double getTaskHeight() {
    final task = widget.task;
    double height = 50;
    if (task?.description != '') {
      height += 20;
    }
    if (task?.dueDate != null) {
      height += 30;
    }
    return height;
  }

  SizedBox getAssignedTo() {
    final assignedTo = widget.task!.assignedTo!;

    return SizedBox(
      width: 90,
      height: 30,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        reverse: true,
        itemCount: assignedTo.length,
        itemBuilder: (context, index) {
          final member = assignedTo[index];
          final photoURL = getPhotoURL(member);
          return FutureBuilder(
            future: photoURL,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return const CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.grey,
                  );
                } else {
                  return CircleAvatar(
                    radius: 15,
                    backgroundImage: NetworkImage(snapshot.data),
                  );
                }
              } else {
                return const CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.grey,
                );
              }
            },
          );
        },
      ),
    );
  }

  String? getDueDate() {
    final DateFormat dateFormat = DateFormat('dd.MM.yy');
    DateTime? dueDate = widget.task!.dueDate!;
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (dueDate.year == tomorrow.year &&
        dueDate.month == tomorrow.month &&
        dueDate.day == tomorrow.day) {
      return 'tomorrow';
    } else if (dueDate.year == yesterday.year &&
        dueDate.month == yesterday.month &&
        dueDate.day == yesterday.day) {
      return 'yesterday';
    } else if (dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day) {
      return 'today';
    } else {
      return dateFormat.format(dueDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final taskHeight = getTaskHeight();

    DateTime? dueDate = widget.task?.dueDate;
    final now = DateTime.now();
    if (dueDate != null) {
      if (dueDate.isAfter(now) ||
          (dueDate.year == now.year &&
              dueDate.month == now.month &&
              dueDate.day == now.day)) {
        dueDateColor = Theme.of(context).colorScheme.onSurface;
      } else {
        dueDateColor = Colors.red;
      }
    }

    Color? priorityColor;
    if (widget.sectionIndex == 2) {
      priorityColor = priorityColors[0];
      dueDateColor = const Color(0xff777777);
    } else if (widget.task?.priority != null) {
      priorityColor = priorityColors[widget.task!.priority!];
    } else {
      priorityColor = null;
    }

    return Stack(
      children: [
        Card(
          elevation: 0.0,
          child: Container(
            width: width - 50,
            height: taskHeight,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onInverseSurface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: Theme.of(context).brightness == Brightness.light
                  ? [
                      BoxShadow(
                        color: const Color(0xff000000).withOpacity(0.15),
                        blurRadius: 12,
                        spreadRadius: 6,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: const Color(0xff000000).withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        height: double.maxFinite,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: SizedBox(
                                width: 280,
                                child: Text(
                                  widget.task!.title.toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: widget.sectionIndex == 2 ? const Color(0xff777777) : Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.normal,
                                    decoration: widget.sectionIndex == 2 ? TextDecoration.lineThrough : TextDecoration.none,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            if (widget.task?.description != '')
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: SizedBox(
                                  width: 250,
                                  child: Text(
                                    widget.task!.description.toString(),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color:const Color(0xff777777),
                                      fontWeight: FontWeight.normal,
                                      decoration: widget.sectionIndex == 2 ? TextDecoration.lineThrough : TextDecoration.none,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            if (widget.task?.dueDate != null)
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, top: 7),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_month_rounded,
                                      color: dueDateColor,
                                      size: 20,
                                    ),
                                    Text(
                                      " Due ${getDueDate()} ",
                                      style: TextStyle(
                                        color: dueDateColor,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 15,
                                        decoration: widget.sectionIndex == 2 ? TextDecoration.lineThrough : TextDecoration.none,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 20,
                        bottom: 10,
                        child: getAssignedTo(),
                      )
                    ],
                  ),
                ),
                ClipRect(
                  clipper: PriorityClipper(),
                  child: Container(
                    width: width,
                    height: taskHeight,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Positioned(
          top: 3,
          left: 3,
          right: 3,
          bottom: 3,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: priorityColor?.withOpacity(0.1) ??
                  Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                widget.editingCallback(
                    widget.context, widget.sectionIndex, widget.taskIndex);
              },
            ),
          ),
        )
      ],
    );
  }
}

class PriorityClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(size.width - 10, 0, 10, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return false;
  }
}
