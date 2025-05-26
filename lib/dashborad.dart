import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> allUsers = [];
  bool isFetchingUsers = false;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() => isFetchingUsers = true);
    final url = Uri.parse('https://devtechtop.com/store/public/api/all_user');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': widget.userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            allUsers = List<Map<String, dynamic>>.from(data['data']);
            allUsers.removeWhere((user) => user['id'].toString() == widget.userId);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Failed to fetch users')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() => isFetchingUsers = false);
    }
  }

  void _showSendRequestDialog({required String receiverId, required String receiverName}) {
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Send Request to $receiverName",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          content: TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: "Description",
              labelStyle: const TextStyle(color: Colors.black54),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.black54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade400,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                if (descriptionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a description.", style: TextStyle(color: Colors.black))),
                  );
                  return;
                }
                Navigator.pop(context);
                _sendFriendRequest(
                  senderId: widget.userId,
                  receiverId: receiverId,
                  description: descriptionController.text.trim(),
                );
              },
              child: const Text("Send", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendFriendRequest({
    required String senderId,
    required String receiverId,
    required String description,
  }) async {
    final url = Uri.parse('https://devtechtop.com/store/public/api/scholar_request/insert');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sender_id': senderId,
          'receiver_id': receiverId,
          'description': description,
        }),
      );

      final data = jsonDecode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Request sent')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.teal.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: isFetchingUsers
            ? const Center(child: CircularProgressIndicator(color: Colors.teal))
            : allUsers.isEmpty
            ? const Center(
          child: Text(
            "No users found",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        )
            : ListView.builder(
          itemCount: allUsers.length,
          itemBuilder: (context, index) {
            final user = allUsers[index];
            final userId = user['id'].toString();
            final userName = user['name'] ?? 'Unknown';

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 2,
              shadowColor: Colors.teal.withOpacity(0.3),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal.shade200,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  userName,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              //  subtitle: Text('ID: $userId', style: const TextStyle(color: Colors.black54)),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    elevation: 0,
                  ),
                  onPressed: () {
                    _showSendRequestDialog(receiverId: userId, receiverName: userName);
                  },
                  child: const Text(
                    'Send Request',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      backgroundColor: Colors.grey.shade50,
    );
  }
}
