import 'package:do_it/core/kanban_board.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(widget.board?.members.toString() ?? '')),
    );
  }
}
