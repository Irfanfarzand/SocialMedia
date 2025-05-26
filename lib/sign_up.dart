import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cellNoController = TextEditingController();
  final _shiftController = TextEditingController();
  final _degreeController = TextEditingController();

  bool _isLoading = false;

  Future<void> signup() async {
    setState(() => _isLoading = true);

    final url = Uri.parse('https://devtechtop.com/store/public/insert_user');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'cell_no': _cellNoController.text,
        'shift': _shiftController.text,
        'degree': _degreeController.text,
      }),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup successful')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: ${response.body}')),
      );
    }
  }

  Widget buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal.shade700),
        filled: true,
        fillColor: Colors.teal.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: ListView(
          children: [
            const SizedBox(height: 12),
            buildTextField(
              label: 'Full Name',
              icon: Icons.person,
              controller: _nameController,
            ),
            const SizedBox(height: 18),
            buildTextField(
              label: 'Email',
              icon: Icons.email,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 18),
            buildTextField(
              label: 'Password',
              icon: Icons.lock,
              controller: _passwordController,
              isPassword: true,
            ),
            const SizedBox(height: 18),
            buildTextField(
              label: 'Cell No',
              icon: Icons.phone,
              controller: _cellNoController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 18),
            buildTextField(
              label: 'Shift (Morning/Evening)',
              icon: Icons.access_time,
              controller: _shiftController,
            ),
            const SizedBox(height: 18),
            buildTextField(
              label: 'Degree',
              icon: Icons.school,
              controller: _degreeController,
            ),
            const SizedBox(height: 36),
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                : SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  'Signup',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
