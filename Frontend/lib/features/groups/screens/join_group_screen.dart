import 'package:flutter/material.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../services/api_service.dart';
import 'group_details_screen.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() =>
      _JoinGroupScreenState();
}

class _JoinGroupScreenState
    extends State<JoinGroupScreen> {
  final _nameController =
      TextEditingController();

  final _codeController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedUserName();
  }

  Future<void> _loadSavedUserName() async {
    final savedName = await StorageService.getUserName();
    if (savedName != null && savedName.isNotEmpty && mounted) {
      _nameController.text = savedName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinGroup() async {
    final memberName =
        _nameController.text.trim();

    final groupCode =
        _codeController.text.trim();

    if (memberName.isEmpty ||
        groupCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter your name and group code.",
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final group =
          await ApiService.joinGroup(
        groupCode: groupCode,
        memberName: memberName,
      );

      // Save to local storage
      await StorageService.saveUserName(memberName);
      await StorageService.saveGroup(group);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              GroupDetailsScreen(
            group: group,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              "Exception: ",
              "",
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Join Group"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),

            const Icon(
              Icons.group_add,
              size: 80,
            ),

            const SizedBox(height: 20),

            const Text(
              "Join Existing Group",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            AppTextField(
              controller: _nameController,
              hintText: "Enter your name",
              labelText: "Your Name",
              prefixIcon: Icons.person,
            ),

            const SizedBox(height: 20),

            AppTextField(
              controller: _codeController,
              hintText: "ABC123",
              labelText: "Group Code",
              prefixIcon: Icons.qr_code,
            ),

            const SizedBox(height: 30),

            AppButton(
              text: "Join Group",
              icon: Icons.login,
              isLoading: _isLoading,
              onPressed: _joinGroup,
            ),
          ],
        ),
      ),
    );
  }
}