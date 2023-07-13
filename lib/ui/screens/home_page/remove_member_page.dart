import 'package:do_it/core/kanban_board.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RemoveMemberPage extends StatefulWidget {
  final KanbanBoard? board;
  const RemoveMemberPage({
    required this.board,
    super.key,
  });

  @override
  State<RemoveMemberPage> createState() => _RemoveMemberPageState();
}

class _RemoveMemberPageState extends State<RemoveMemberPage> {
  List<dynamic> toRemove = [];

  void removeMember(List<dynamic> toRemove) async {
    final db = FirebaseFirestore.instance;
    final uuid = widget.board!.uuid!;
    final ref = db.collection('boards').doc(uuid);
    widget.board!.members!.removeWhere((element) => toRemove.contains(element));
    await ref.set({'members': widget.board!.members!}, SetOptions(merge: true));
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

  @override
  Widget build(BuildContext context) {
    final members = widget.board!.members!;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Remove member"),
        centerTitle: true,
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          final photoURL = getPhotoURL(member);

          void itemChange(String itemValue, bool isSelected) {
            setState(() {
              if (isSelected) {
                if (!toRemove.contains(member)) {
                  toRemove.add(member);
                }
              } else {
                toRemove.remove(member);
              }
            });
          }

          if (member != FirebaseAuth.instance.currentUser!.email!) {
            return FutureBuilder(
              future: photoURL,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          value: toRemove.contains(member.toString()),
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
                          controlAffinity: ListTileControlAffinity.leading,
                          value: toRemove.contains(member.toString()),
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
                              backgroundImage: NetworkImage(snapshot.data),
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
          } else {
            return Container();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          removeMember(toRemove);
          Navigator.pop(context);
        },
        backgroundColor: Colors.red,
        shape: const CircleBorder(),
        child: const Icon(Icons.delete_forever),
      ),
    );
  }
}
