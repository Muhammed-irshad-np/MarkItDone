import 'package:flutter/material.dart';
import 'package:markitdone/providers/view_models/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);
    String otp = '';

    return Scaffold(
      appBar: AppBar(title: Text('Login with Phone')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phone Number Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: viewModel.setPhoneNumber,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Trigger phone number verification
                    final res = await viewModel.registerorloginuser(context);
                    if (res['isFirstTimeUser']) {
                      Navigator.pushReplacementNamed(context, '/register');
                    } else {
                      Navigator.pushReplacementNamed(context, '/task');
                    }
                  },
                  child: Text('login'),
                ),
              ],
            ),
            //  const   SizedBox(height: 20),

            //     // OTP Input Field
            //     TextField(
            //       onChanged: (value) {
            //         otp = value;
            //       },
            //       decoration: InputDecoration(labelText: 'Enter OTP'),
            //       keyboardType: TextInputType.number,
            //     ),
            //  const   SizedBox(height: 20),

            //     // Submit OTP Button
            //     ElevatedButton(
            //       onPressed: () async {
            //         // Attempt to sign in with the OTP
            //         var user = await viewModel.signInWithOTP(otp);
            //         if (user != null) {
            //           // Navigate to Home Screen
            //           Navigator.pushReplacementNamed(context, '/home');
            //         } else {
            //           // Show error message
            //           print('Error signing in');
            //         }
            //       },
            //       child: Text('Submit'),
            //     ),
          ],
        ),
      ),
    );
  }
}
