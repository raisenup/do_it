import 'dart:async';
import 'package:do_it/ui/screens/home_page/remove_member_page.dart';
import 'package:do_it/ui/screens/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_it/core/kanban_board.dart';
import 'package:do_it/ui/screens/home_page/create_board_page.dart';
import 'package:do_it/ui/screens/home_page/kanban_board_page.dart';
import 'package:do_it/ui/screens/home_page/add_members_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  KanbanBoard? currentBoard = const KanbanBoard(name: '');

  void changeBoard(item) {
    setState(() {
      currentBoard = KanbanBoard(
        uuid: item['uuid'],
        name: item['name'],
        members: item['members'],
        iconColor: item['icon_color'],
        sections: item['sections'],
      );
    });
    Navigator.pop(context);
  }

  void deleteBoard() async {
    await FirebaseFirestore.instance
        .collection('boards')
        .doc(currentBoard?.uuid)
        .delete()
        .then(
          (value) => debugPrint("Board deleted successfully."),
        )
        .catchError(
      (e) {
        debugPrint("Failed to delete board: $e");
      },
    );
  }

  void leaveBoard() async {
    currentBoard!.members!.removeWhere(
        (element) => element == FirebaseAuth.instance.currentUser!.email!);
    await FirebaseFirestore.instance
        .collection('boards')
        .doc(currentBoard?.uuid)
        .set({'members': currentBoard!.members!}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final Stream<QuerySnapshot> userStream = FirebaseFirestore.instance
        .collection('boards')
        .where('members', arrayContains: '${user?.email}')
        .snapshots();
    String appBarTitle = currentBoard!.name!;

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
        centerTitle: true,
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        actions: [
          if (appBarTitle != '')
            IconButton(
              icon: const Icon(Icons.person_add_alt_1_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddMembersPage(board: currentBoard),
                  ),
                );
              },
            ),
          if (appBarTitle != '')
            PopupMenuButton(
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    value: 0,
                    child: Text("Delete board"),
                  ),
                  const PopupMenuItem(
                    value: 1,
                    child: Text("Remove member"),
                  ),
                  const PopupMenuItem(
                    value: 2,
                    child: Text("Leave board"),
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
                          "Are you sure you want to delete \"${currentBoard?.name}\"?",
                          textAlign: TextAlign.center,
                        ),
                        content: SizedBox(
                          width: 500,
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FilledButton.icon(
                                onPressed: () {
                                  deleteBoard();
                                  Navigator.pop(context);
                                  setState(() {
                                    currentBoard = const KanbanBoard(name: '');
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.red),
                                ),
                                icon: Icon(
                                  Icons.delete_forever,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                label: Text(
                                  "Delete",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.close,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                label: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (value == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RemoveMemberPage(
                        board: currentBoard,
                      ),
                    ),
                  );
                } else if (value == 2) {
                  leaveBoard();
                  if(currentBoard!.members!.isEmpty) {
                    deleteBoard();
                  }
                  setState(() {
                    currentBoard = const KanbanBoard(name: '');
                  });
                }
              },
            )
        ],
      ),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
        ),
        child: StreamBuilder(
          stream: userStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              List<dynamic> boards = snapshot.data!.docs;

              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.only(top: 30, left: 28, bottom: 18),
                    child: Text(
                      "Menu",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.only(top: 18, left: 28, bottom: 18),
                    child: Text(
                      "Kanban boards",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                  ...boards.map(
                    (item) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        child: ListTile(
                          minLeadingWidth: 4,
                          leading: const Icon(Icons.circle),
                          iconColor: Color(item['icon_color']),
                          title: Text(item['name']),
                          onTap: () {
                            changeBoard(item);
                          },
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: ListTile(
                      minLeadingWidth: 4,
                      leading: const Icon(
                        Icons.add,
                      ),
                      title: const Text("Create new board"),
                      onTap: () {
                        if (boards.length < 10) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateBoardPage(),
                            ),
                          );
                        } else {
                          final scaffoldMessenger =
                              ScaffoldMessenger.of(context);
                          scaffoldMessenger.clearSnackBars();
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Your limit of 10 boards is reached"),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.only(top: 18, left: 28, bottom: 18),
                    child: Text(
                      "Other",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: ListTile(
                      minLeadingWidth: 4,
                      leading: const Icon(
                        Icons.settings_rounded,
                      ),
                      title: const Text("Settings"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: ListTile(
                      minLeadingWidth: 4,
                      leading: const Icon(
                        Icons.keyboard_return_rounded,
                      ),
                      title: const Text("Logout"),
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                      },
                    ),
                  ),
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xff6750a4)),
              );
            }
          },
        ),
      ),
      body: appBarTitle == ''
          ? const Center(
              child: Text(
                'Choose or create board in menu',
                style: TextStyle(
                  color: Color(0xff7d7d7d),
                ),
              ),
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('boards')
                  .doc(currentBoard!.uuid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Text('Loading...'));
                }

                if (snapshot.hasData) {
                  var data = snapshot.data!.data();
                  return KanbanBoardPage(
                    board: KanbanBoard(
                      uuid: data?['uuid'],
                      name: data?['name'],
                      members: data?['members'],
                      iconColor: data?['icon_color'],
                      sections: data?['sections'],
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
    );
  }
}
