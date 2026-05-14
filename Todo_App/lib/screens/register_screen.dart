import 'package:flutter/material.dart';

import '../services/api_service.dart';

class RegisterScreen
    extends StatefulWidget {
  const RegisterScreen({
    super.key,
  });

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final usernameController =
  TextEditingController();

  final passwordController =
  TextEditingController();

  final confirmPasswordController =
  TextEditingController();

  bool isLoading = false;

  String errorMessage = '';

  Future<void> register() async {
    if (passwordController.text !=
        confirmPasswordController
            .text) {
      setState(() {
        errorMessage =
        'Passwords do not match';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    bool success =
    await ApiService.register(
      usernameController.text.trim(),
      passwordController.text.trim(),
      confirmPasswordController.text
          .trim(),
    );

    setState(() {
      isLoading = false;
    });

    if (success) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
          Text('Registration Success'),
        ),
      );

      Navigator.pop(context);
    } else {
      setState(() {
        errorMessage =
        'Registration Failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text('Create Account'),
      ),
      body: Padding(
        padding:
        const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            TextField(
              controller:
              usernameController,
              decoration:
              const InputDecoration(
                labelText: 'Username',
                prefixIcon:
                Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller:
              passwordController,
              obscureText: true,
              decoration:
              const InputDecoration(
                labelText: 'Password',
                prefixIcon:
                Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller:
              confirmPasswordController,
              obscureText: true,
              decoration:
              const InputDecoration(
                labelText:
                'Confirm Password',
                prefixIcon:
                Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 20),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style:
                const TextStyle(
                  color: Colors.red,
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  Colors.deepPurple,
                ),
                onPressed: isLoading
                    ? null
                    : register,
                child: isLoading
                    ? const CircularProgressIndicator(
                  color:
                  Colors.white,
                )
                    : const Text(
                  'Register',
                  style: TextStyle(
                    color:
                    Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}