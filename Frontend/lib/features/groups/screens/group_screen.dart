import 'package:flutter/material.dart';

class GroupScreen extends StatelessWidget {
  final String groupName;
  const GroupScreen({super.key, required this.groupName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
      ),
      body: Center(
        child: Text(
          "Group Created: $groupName",
          style: TextStyle(fontSize: 20),
        )
      )
    );
  }
}