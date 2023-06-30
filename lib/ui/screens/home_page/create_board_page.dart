import 'package:do_it/core/kanban_board.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter/material.dart';

class CreateBoardPage extends StatefulWidget {
  const CreateBoardPage({super.key});

  @override
  State<CreateBoardPage> createState() => _CreateBoardPageState();
}

class _CreateBoardPageState extends State<CreateBoardPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitForm() async {
    // process data here
    final db = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    final board =
        KanbanBoard(name: _controller.text, iconColor: currentColor.value , members: ['${user?.email}']);

    final ref =
        db.collection('${user?.uid}').doc('${board.name}').withConverter(
              fromFirestore: KanbanBoard.fromFirestore,
              toFirestore: (KanbanBoard board, _) => board.toFirestore(),
            );
    await ref.set(board);

    if (!context.mounted) return;
    Navigator.pop(context);
  }

  Color currentColor = Colors.amber;
  void changeColor(Color color) => setState(() => currentColor = color);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create new board",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: Theme.of(context).textTheme.titleLarge,
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  _submitForm();
                }
              },
              icon: const Icon(Icons.check_rounded)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(style: BorderStyle.solid)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                    color: Color(0xff6750a4),
                    width: 2,
                  )),
                  floatingLabelStyle: TextStyle(color: Color(0xff6750a4)),
                  labelText: "Name",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  } else if (value.length > 64) {
                    return 'Name is too long';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 10, right: 20),
              child: ListTile(
                leading: const Icon(Icons.color_lens, size: 35,),
                
                iconColor: currentColor,
                title: const Text(
                  "Color",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                ),
                subtitle: Text('#${(currentColor.value.toRadixString(16).padLeft(6, '0')).substring(2).toUpperCase()}'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Pick a color"),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: currentColor,
                            onColorChanged: changeColor,
                            paletteType: PaletteType.hueWheel,
                            labelTypes: const [],
                            enableAlpha: false,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
