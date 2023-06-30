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

  void _submitForm() async {}

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
            TextFormField(
              controller: _controller,
              autofocus: true,
              validator: (value) =>
                  value!.isValidEmail() ? null : 'Non-valid email.',
            ),
          ],
        ),
      ),
    );
  }
}
