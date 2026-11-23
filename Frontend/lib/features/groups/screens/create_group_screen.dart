import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';
import '../models/group_model.dart';
import '../services/api_service.dart';
import 'group_details_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _creatorNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedUserName();
  }

  Future<void> _loadSavedUserName() async {
    final savedName = await StorageService.getUserName();
    if (savedName != null && savedName.isNotEmpty && mounted) {
      _creatorNameController.text = savedName;
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _creatorNameController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    final String groupName = _groupNameController.text.trim();
    final String creatorName = _creatorNameController.text.trim();

    // Validate input
    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a group name"),
        ),
      );
      return;
    }

    if (creatorName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your name"),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call API
      Group group = await ApiService.createGroup(groupName, creatorName);

      // Save to local persistence
      await StorageService.saveUserName(creatorName);
      await StorageService.saveGroup(group);

      if (!mounted) return;

      // Navigate to Group Details Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GroupDetailsScreen(group: group),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
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
        title: const Text("Create Group"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Icon(
              Icons.group_work_outlined,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              "Start a New Group",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Create a group and invite your friends to split expenses easily.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: "Group Name",
                hintText: "e.g. Goa Trip, Flat 302, Dinner Party",
                prefixIcon: Icon(Icons.group),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _creatorNameController,
              decoration: const InputDecoration(
                labelText: "Your Name",
                hintText: "Enter your name",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _isLoading ? null : _createGroup,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      "Create Group",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}