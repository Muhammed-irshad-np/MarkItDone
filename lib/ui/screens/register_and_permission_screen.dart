import 'package:flutter/material.dart';
import 'package:markitdone/providers/view_models/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class RegisterAndPermissionScreen extends StatefulWidget {
  const RegisterAndPermissionScreen({super.key});

  @override
  State<RegisterAndPermissionScreen> createState() =>
      _RegisterAndPermissionScreenState();
}

class _RegisterAndPermissionScreenState
    extends State<RegisterAndPermissionScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    final res =
        await viewModel.updateUserNameAndStatus(name, viewModel.documentId!);

    if (res) {
      Navigator.pushReplacementNamed(context, '/task');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update user name and status')),
      );
    }
    // TODO: Handle the submit action
    print('Submitted name: $name');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Enter your name',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
