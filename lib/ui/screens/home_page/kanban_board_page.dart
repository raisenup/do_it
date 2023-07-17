import 'package:do_it/core/kanban_board.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_it/core/task.dart';
import 'package:do_it/ui/widgets/task_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class KanbanBoardPage extends StatefulWidget {
  final KanbanBoard? board;
  const KanbanBoardPage({
    required this.board,
    super.key,
  });

  @override
  State<KanbanBoardPage> createState() => _KanbanBoardPageState();
}

class _KanbanBoardPageState extends State<KanbanBoardPage> {
  // task
  final _taskFormKey = GlobalKey<FormState>();
  final _taskTitleController = TextEditingController();
  final _taskDescriptionController = TextEditingController();
  String? taskSelectedDate;
  int? taskSelectedPriority;
  List<dynamic> taskSelectedAssignedTo = [];
  dynamic selectedSectionIndex;

  // section
  final _sectionFormKey = GlobalKey<FormState>();
  final _sectionTitleController = TextEditingController();

  // task functions
  void addTask(sectionIndex) async {
    final db = FirebaseFirestore.instance;
    final uuid = widget.board?.uuid.toString();
    final ref = db.collection('boards').doc(uuid);
    await ref.get().then(
      (snapshot) {
        if (snapshot.exists) {
          List<Map<String, dynamic>> sections =
              List<Map<String, dynamic>>.from(snapshot.data()!['sections']);

          var section = sections[sectionIndex];
          section['tasks'].add(
            {
              'title': _taskTitleController.text.toString(),
              'description': _taskDescriptionController.text.toString(),
              'due_date': taskSelectedDate,
              'priority': taskSelectedPriority,
              'assigned_to': taskSelectedAssignedTo,
            },
          );
          ref
              .update({'sections': sections})
              .then(
                (value) => debugPrint("Document updated successfully"),
              )
              .catchError(
                (error) => debugPrint("Failed to update document: $error"),
              );
        }
      },
    );
  }

  void saveTask(sectionIndex, taskIndex) async {
    final db = FirebaseFirestore.instance;
    final uuid = widget.board?.uuid.toString();
    final ref = db.collection('boards').doc(uuid);
    await ref.get().then(
      (snapshot) {
        if (snapshot.exists) {
          List<Map<String, dynamic>> sections =
              List<Map<String, dynamic>>.from(snapshot.data()!['sections']);

          var section = sections[sectionIndex];
          section['tasks'][taskIndex] = {
            'title': _taskTitleController.text.toString(),
            'description': _taskDescriptionController.text.toString(),
            'due_date': taskSelectedDate,
            'priority': taskSelectedPriority,
            'assigned_to': taskSelectedAssignedTo,
          };

          ref
              .update({'sections': sections})
              .then(
                (value) => debugPrint("Document updated successfully"),
              )
              .catchError(
                (error) => debugPrint("Failed to update document: $error"),
              );
        }
      },
    );
  }

  void deleteTask(sectionIndex, taskIndex) async {
    final db = FirebaseFirestore.instance;
    final uuid = widget.board?.uuid.toString();
    final ref = db.collection('boards').doc(uuid);
    await ref.get().then(
      (snapshot) {
        if (snapshot.exists) {
          List<Map<String, dynamic>> sections =
              List<Map<String, dynamic>>.from(snapshot.data()!['sections']);

          var section = sections[sectionIndex];
          section['tasks'].removeAt(taskIndex);
          ref
              .update({'sections': sections})
              .then(
                (value) => debugPrint("Document updated successfully"),
              )
              .catchError(
                (error) => debugPrint("Failed to update document: $error"),
              );
        }
      },
    );
  }

  void moveTask(sectionIndex, oldIndex, newIndex) async {
    final db = FirebaseFirestore.instance;
    final uuid = widget.board?.uuid.toString();
    final ref = db.collection('boards').doc(uuid);
    await ref.get().then(
      (snapshot) {
        if (snapshot.exists) {
          List<Map<String, dynamic>> sections =
              List<Map<String, dynamic>>.from(snapshot.data()!['sections']);
          final tasks = sections[sectionIndex]['tasks'];

          // onReorder fix
          if (newIndex > tasks.length) newIndex = tasks.length;
          if (oldIndex < newIndex) newIndex--;

          final task = tasks.removeAt(oldIndex);
          sections[sectionIndex]['tasks'].insert(newIndex, task);

          ref
              .update({'sections': sections})
              .then(
                (value) => debugPrint("Document updated successfully"),
              )
              .catchError(
                (error) => debugPrint("Failed to update document: $error"),
              );
        }
      },
    );
  }

  void moveTaskToSection(oldSectionIndex, newSectionIndex, taskIndex) async {
    final db = FirebaseFirestore.instance;
    final uuid = widget.board?.uuid.toString();
    final ref = db.collection('boards').doc(uuid);
    await ref.get().then(
      (snapshot) {
        if (snapshot.exists) {
          List<Map<String, dynamic>> sections =
              List<Map<String, dynamic>>.from(snapshot.data()!['sections']);

          final task = sections[oldSectionIndex]['tasks'].removeAt(taskIndex);
          sections[newSectionIndex]['tasks'].add(task);

          ref
              .update({'sections': sections})
              .then(
                (value) => debugPrint("Document updated successfully"),
              )
              .catchError(
                (error) => debugPrint("Failed to update document: $error"),
              );
        }
      },
    );
  }

  void selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final DateFormat dateFormat = DateFormat('dd.MM.yyyy');
      setState(() {
        taskSelectedDate =
            dateFormat.format(pickedDate); // Store the selected date
      });
    }
  }

  void selectPriority() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select priority:'),
          content: SizedBox(
            width: 300,
            height: 175,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                ListTile(
                  leading: const Icon(
                    Icons.priority_high,
                    color: Colors.red,
                  ),
                  title: const Text('High'),
                  onTap: () {
                    setState(() {
                      taskSelectedPriority = 3;
                    });
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.priority_high,
                    color: Colors.yellow,
                  ),
                  title: const Text('Medium'),
                  onTap: () {
                    setState(() {
                      taskSelectedPriority = 2;
                    });
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.priority_high,
                    color: Colors.blue,
                  ),
                  title: const Text('Low'),
                  onTap: () {
                    setState(() {
                      taskSelectedPriority = 1;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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

  void selectAssignedTo() async {
    showDialog(
      context: context,
      builder: (context) {
        final members = widget.board!.members!;
        return SimpleDialog(
          title: const Align(
            alignment: Alignment.center,
            child: Text("Assign to"),
          ),
          children: [
            SizedBox(
              width: 500,
              height: 400,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  final photoURL = getPhotoURL(member);

                  void itemChange(String itemValue, bool isSelected) {
                    setState(() {
                      if (isSelected) {
                        if (!taskSelectedAssignedTo.contains(member)) {
                          taskSelectedAssignedTo.add(member);
                        }
                      } else {
                        taskSelectedAssignedTo.remove(member);
                      }
                    });
                  }

                  return FutureBuilder(
                    future: photoURL,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return CheckboxListTile(
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                value: taskSelectedAssignedTo
                                    .contains(member.toString()),
                                onChanged: (isChecked) {
                                  setState(() {
                                    itemChange(member.toString(), isChecked!);
                                  });
                                },
                                dense: true,
                                title: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 0.0, vertical: 0.0),
                                  leading: const CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey,
                                  ),
                                  title: Text(member.toString()),
                                ),
                              );
                            },
                          );
                        } else {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return CheckboxListTile(
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                value: taskSelectedAssignedTo
                                    .contains(member.toString()),
                                onChanged: (isChecked) {
                                  setState(() {
                                    itemChange(member.toString(), isChecked!);
                                  });
                                },
                                dense: true,
                                title: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 0.0, vertical: 0.0),
                                  leading: CircleAvatar(
                                    radius: 20,
                                    backgroundImage:
                                        NetworkImage(snapshot.data),
                                  ),
                                  title: Text(member.toString()),
                                ),
                              );
                            },
                          );
                        }
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }

  void showNewTaskBottomSheet(context, index) {
    final width = MediaQuery.of(context).size.width;
    _taskTitleController.clear();
    _taskDescriptionController.clear();
    taskSelectedDate = null;
    taskSelectedPriority = null;
    taskSelectedAssignedTo = [];

    showModalBottomSheet<dynamic>(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28), topRight: Radius.circular(28))),
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Form(
                key: _taskFormKey,
                child: Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 15, left: 20, right: 20),
                      child: TextFormField(
                        controller: _taskTitleController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                        cursorColor: const Color(0xff6750a4),
                        autofocus: true,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'Name',
                          hintStyle: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 10),
                      child: SizedBox(
                        width: width,
                        child: TextFormField(
                          controller: _taskDescriptionController,
                          style: const TextStyle(
                            color: Color(0xff7d7d7d),
                            fontSize: 20,
                          ),
                          cursorColor: const Color(0xff6750a4),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: 'Description',
                            hintStyle: TextStyle(
                              color: Color(0xff7d7d7d),
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InputChip(
                          avatar: Icon(
                            Icons.calendar_month_outlined,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          label: const Text(
                            "Due date",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                          onPressed: () {
                            selectDate();
                          },
                        ),
                        InputChip(
                          avatar: Icon(
                            Icons.priority_high_outlined,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          label: const Text(
                            "Priority",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                          onPressed: () {
                            selectPriority();
                          },
                        ),
                        InputChip(
                          avatar: Icon(
                            Icons.person_outline_outlined,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          label: const Text(
                            "Assign to",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                          onPressed: () {
                            selectAssignedTo();
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8, bottom: 8),
                        child: FilledButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text("Add task"),
                          onPressed: () {
                            if (_taskFormKey.currentState!.validate()) {
                              addTask(index);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showEditingTaskBottomSheet(context, sectionIndex, taskIndex) {
    final width = MediaQuery.of(context).size.width;

    final task = widget.board!.sections![sectionIndex]['tasks'][taskIndex];
    _taskTitleController.text = task['title'];
    _taskDescriptionController.text = task['description'];
    taskSelectedDate = task['due_date'];
    taskSelectedPriority = task['priority'];
    taskSelectedAssignedTo = task['assigned_to'];
    selectedSectionIndex = sectionIndex;

    showModalBottomSheet<dynamic>(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28), topRight: Radius.circular(28))),
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Form(
                key: _taskFormKey,
                child: Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 15, left: 20, right: 20),
                      child: TextFormField(
                        controller: _taskTitleController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                        cursorColor: const Color(0xff6750a4),
                        autofocus: true,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'Name',
                          hintStyle: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 10),
                      child: SizedBox(
                        width: width,
                        child: TextFormField(
                          controller: _taskDescriptionController,
                          style: const TextStyle(
                            color: Color(0xff7d7d7d),
                            fontSize: 20,
                          ),
                          cursorColor: const Color(0xff6750a4),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: 'Description',
                            hintStyle: TextStyle(
                              color: Color(0xff7d7d7d),
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InputChip(
                          avatar: Icon(
                            Icons.calendar_month_outlined,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          label: const Text(
                            "Due date",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                          onPressed: () {
                            selectDate();
                          },
                        ),
                        InputChip(
                          avatar: Icon(
                            Icons.priority_high_outlined,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          label: const Text(
                            "Priority",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                          onPressed: () {
                            selectPriority();
                          },
                        ),
                        InputChip(
                          avatar: Icon(
                            Icons.person_outline_outlined,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          label: const Text(
                            "Assign to",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                          onPressed: () {
                            selectAssignedTo();
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8, right: 8, bottom: 8),
                          child: IconButton(
                            onPressed: () {
                              deleteTask(sectionIndex, taskIndex);
                              Navigator.pop(context);
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.red),
                            ),
                            icon: const Icon(
                              Icons.delete_forever,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8, right: 8, bottom: 8),
                          child: DropdownButton(
                            value: selectedSectionIndex,
                            items: widget.board!.sections!
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: widget.board!.sections!.indexOf(e),
                                    child: Text(
                                      e['title'].toString(),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedSectionIndex = value;
                                moveTaskToSection(
                                    sectionIndex, value, taskIndex);
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8, right: 8, bottom: 8),
                          child: FilledButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text("Save task"),
                            onPressed: () {
                              if (_taskFormKey.currentState!.validate()) {
                                saveTask(sectionIndex, taskIndex);
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // section functions
  void addSection(String title) async {
    final db = FirebaseFirestore.instance;
    final uuid = widget.board?.uuid.toString();

    final ref = db.collection('boards').doc(uuid);

    await ref.get().then(
      (snapshot) {
        if (snapshot.exists) {
          List<Map<String, dynamic>> sections =
              List<Map<String, dynamic>>.from(snapshot.data()!['sections']);

          sections.add({
            'title': title,
            'tasks': [],
          });

          ref
              .update({'sections': sections})
              .then(
                (value) => debugPrint("Section added successfully"),
              )
              .catchError(
                (error) => debugPrint("Failed to add section: $error"),
              );
        }
      },
    );
  }

  void deleteSection(index) async {
    final db = FirebaseFirestore.instance;
    final uuid = widget.board?.uuid.toString();

    final title = widget.board!.sections![index]['title'];
    if (title == 'To do' || title == 'In progress' || title == 'Done') {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.clearSnackBars();
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text(
            "You can't delete main sections 'To do', 'In progress', 'Done'",
          ),
        ),
      );
      return;
    }

    final ref = db.collection('boards').doc(uuid);

    await ref.get().then(
      (snapshot) {
        if (snapshot.exists) {
          List<Map<String, dynamic>> sections =
              List<Map<String, dynamic>>.from(snapshot.data()!['sections']);

          sections.removeAt(index);

          ref
              .update({'sections': sections})
              .then(
                (value) => debugPrint("Section deleted successfully"),
              )
              .catchError(
                (error) => debugPrint("Failed to delete section: $error"),
              );
        }
      },
    );
  }

  void showNewSectionBottomSheet(context) {
    showModalBottomSheet<dynamic>(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28), topRight: Radius.circular(28))),
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Form(
                key: _sectionFormKey,
                child: Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 15, left: 20, right: 20),
                      child: TextFormField(
                        controller: _sectionTitleController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                        cursorColor: const Color(0xff6750a4),
                        autofocus: true,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'Name',
                          hintStyle: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8, right: 8, bottom: 8),
                        child: FilledButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text("Add section"),
                          onPressed: () {
                            if (_sectionFormKey.currentState!.validate()) {
                              addSection(_sectionTitleController.text);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
    _sectionTitleController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final sections = widget.board!.sections!;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final DateFormat dateFormat = DateFormat('dd.MM.yy');

    return StatefulBuilder(
      builder: (context, setState) {
        return Scaffold(
          body: PageView.builder(
            dragStartBehavior: DragStartBehavior.down,
            scrollDirection: Axis.horizontal,
            itemCount: sections.length + 1,
            itemBuilder: (context, sectionIndex) {
              if (sectionIndex < sections.length) {
                final section = sections[sectionIndex];
                final tasks = sections[sectionIndex]['tasks'];

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    decelerationRate: ScrollDecelerationRate
                        .fast, // ! changing this may result in bug
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 10),
                    child: SizedBox(
                      width: width,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: ListTile(
                                  title: Text(
                                    section['title'],
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: PopupMenuButton(
                                  itemBuilder: (context) {
                                    return [
                                      const PopupMenuItem(
                                        value: 0,
                                        child: Text("Delete section"),
                                      )
                                    ];
                                  },
                                  onSelected: (value) {
                                    if (value == 0) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text(
                                              "Are you sure you want to delete \"${section['title']}\"?",
                                              textAlign: TextAlign.center,
                                            ),
                                            content: SizedBox(
                                              width: 500,
                                              height: 50,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  FilledButton.icon(
                                                    onPressed: () {
                                                      deleteSection(
                                                          sectionIndex);
                                                      Navigator.pop(context);
                                                    },
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all(Colors.red),
                                                    ),
                                                    icon: Icon(
                                                      Icons.delete_forever,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                    ),
                                                    label: Text(
                                                      "Delete",
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface,
                                                      ),
                                                    ),
                                                  ),
                                                  OutlinedButton.icon(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    icon: Icon(
                                                      Icons.close,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                    ),
                                                    label: Text(
                                                      "Cancel",
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          ReorderableListView(
                            proxyDecorator: (child, index, animation) {
                              return Material(
                                borderRadius: BorderRadius.circular(16),
                                child: child,
                              );
                            },
                            physics: const NeverScrollableScrollPhysics(),
                            onReorder: ((oldIndex, newIndex) {
                              moveTask(sectionIndex, oldIndex, newIndex);

                              // blinking fix
                              if (newIndex > tasks.length) {
                                newIndex = tasks.length;
                              }
                              if (oldIndex < newIndex) newIndex--;
                              setState(() {
                                var task = sections[sectionIndex]['tasks']
                                    .removeAt(oldIndex);
                                sections[sectionIndex]['tasks']
                                    .insert(newIndex, task);
                              });
                            }),
                            shrinkWrap: true,
                            children: [
                              ...tasks.map(
                                (item) {
                                  // fix of one item in tasks bug
                                  if (tasks.length <= 2) {
                                    return GestureDetector(
                                      key: ValueKey(item),
                                      onLongPress:
                                          () {}, // removes ability to move task, and fixes the bug
                                      child: TaskWidget(
                                        editingCallback:
                                            showEditingTaskBottomSheet,
                                        context: context,
                                        sectionIndex: sectionIndex,
                                        taskIndex: tasks.indexOf(item),
                                        task: Task(
                                          title: item['title'],
                                          description: item['description'],
                                          priority: item['priority'],
                                          dueDate: item['due_date'] != null
                                              ? dateFormat
                                                  .parse(item['due_date'])
                                              : null,
                                          assignedTo: item['assigned_to'],
                                        ),
                                      ),
                                    );
                                  }
                                  return TaskWidget(
                                    key: ValueKey(item),
                                    editingCallback: showEditingTaskBottomSheet,
                                    context: context,
                                    sectionIndex: sectionIndex,
                                    taskIndex: tasks.indexOf(item),
                                    task: Task(
                                      title: item['title'],
                                      description: item['description'],
                                      priority: item['priority'],
                                      dueDate: item['due_date'] != null
                                          ? dateFormat.parse(item['due_date'])
                                          : null,
                                      assignedTo: item['assigned_to'],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          Card(
                            child: Container(
                              width: width,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xff000000)
                                              .withOpacity(0.15),
                                          blurRadius: 12,
                                          spreadRadius: 6,
                                          offset: const Offset(0, 8),
                                        ),
                                        BoxShadow(
                                          color: const Color(0xff000000)
                                              .withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                    : [],
                                color: Theme.of(context)
                                    .colorScheme
                                    .onInverseSurface,
                              ),
                              child: TextButton(
                                style: ButtonStyle(
                                  overlayColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.purple.shade50,
                                  ),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.add_rounded,
                                          color: Colors.deepPurple, size: 30),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: Text(
                                          "Add task",
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                onPressed: () {
                                  showNewTaskBottomSheet(context, sectionIndex);
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: Column(
                      children: [
                        SizedBox(
                          width: width - 16,
                          height: 60,
                          child: OutlinedButton.icon(
                            style: ButtonStyle(
                              alignment: Alignment.centerLeft,
                              overlayColor: MaterialStateColor.resolveWith(
                                (states) => Colors.purple.shade50,
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            icon: Icon(
                              Icons.add,
                              size: 30,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            label: Text(
                              "Add section",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                              ),
                            ),
                            onPressed: () {
                              showNewSectionBottomSheet(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
