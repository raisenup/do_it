import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_it/core/kanban_board.dart';
import 'package:flutter/material.dart';
import 'package:do_it/core/email_validator.dart';

class AddMembersPage extends StatefulWidget {
  final KanbanBoard? board;
  const AddMembersPage({
    required this.board,
    super.key,
  });

  @override
  State<AddMembersPage> createState() => _AddMembersPageState();
}

class _AddMembersPageState extends State<AddMembersPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  void _submitForm() async {
    final db = FirebaseFirestore.instance;
    final uuid = widget.board?.uuid.toString();

    debugPrint(uuid);
    final ref = db.collection('boards').doc(uuid);

    ref.update({'members' : FieldValue.arrayUnion([_controller.text])});
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add members",
          style: TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
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
              padding: const EdgeInsets.all(20),
              child: TextFormField(
                controller: _controller,
                autofocus: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(style: BorderStyle.solid)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                    color: Color(0xff6750a4),
                    width: 2,
                  )),
                  floatingLabelStyle: TextStyle(color: Color(0xff6750a4)),
                  labelText: "Email",
                ),
                validator: (value) =>
                    value!.isValidEmail() ? null : 'Wrong input.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
