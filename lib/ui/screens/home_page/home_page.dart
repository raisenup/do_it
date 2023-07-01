import 'dart:async';
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
  KanbanBoard? currentBoard = KanbanBoard(name: '');

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final Stream<QuerySnapshot> userStream =
        FirebaseFirestore.instance.collection('boards').where('members.${user?.email}', isGreaterThan: null).snapshots();
    String appBarTitle = currentBoard!.name!;
    bool isBlankBoard = true;

    if (appBarTitle == '') {
      isBlankBoard = true;
    } else {
      isBlankBoard = false;
    }

    void changeBoard(item) {
      setState(() {
        currentBoard = KanbanBoard(
            uuid: item['uuid'],
            name: item['name'],
            members: item['members'],
            iconColor: item['icon_color'],
            sections: item['sections']);
        appBarTitle = currentBoard!.name!;
      });
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        titleTextStyle: const TextStyle(
            color: Colors.black, fontSize: 22, fontWeight: FontWeight.w500),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
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
            IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              onPressed: () {},
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
                    child: const Text(
                      "Menu",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Color(0xff49454f)),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.only(top: 18, left: 28, bottom: 18),
                    child: const Text(
                      "Kanban boards",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xff49454f)),
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
                        color: Colors.black,
                      ),
                      title: const Text("Create new board"),
                      onTap: () {
                        if (boards.length < 7) {
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
                                  Text("Your limit of 7 boards is reached"),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.only(top: 18, left: 28, bottom: 18),
                    child: const Text(
                      "Other",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xff49454f)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: ListTile(
                      minLeadingWidth: 4,
                      leading: const Icon(
                        Icons.settings_rounded,
                        color: Colors.black,
                      ),
                      title: const Text("Settings"),
                      onTap: () {},
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: ListTile(
                      minLeadingWidth: 4,
                      leading: const Icon(
                        Icons.keyboard_return_rounded,
                        color: Colors.black,
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
      body: isBlankBoard ? Container() : KanbanBoardPage(board: currentBoard),
    );
  }
}
