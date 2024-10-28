import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:markitdone/data/repositories/user_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  String _phoneNumber = '';
  String _verificationId = '';
  bool _isOTPSent = false;
  String? documentId = '';

  bool get isOTPSent => _isOTPSent;

  AuthViewModel(this._userRepository);

  void setPhoneNumber(String number) {
    _phoneNumber = "+91$number";
    notifyListeners();
  }

  // Method to verify the phone number
  Future<void> verifyPhoneNumber() async {
    await _userRepository.sendOTP(_phoneNumber, (String verificationId) {
      _verificationId =
          verificationId; // Store the verification ID for later use
      _isOTPSent = true; // OTP has been sent successfully
      notifyListeners();
    });
  }

  // Method to sign in with the OTP
  Future<User?> signInWithOTP(String otp) async {
    return await _userRepository.verifyOTP(_verificationId, otp);
  }

  Future<Map<String, dynamic>> registerorloginuser(BuildContext context) async {
    if (_phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a phone number'),
        ),
      );

      return {'isFirstTimeUser': false, 'documentId': null};
    }

    final res = await _userRepository.registerorloginuser(_phoneNumber);
    documentId = res['documentId'] ?? "";
    notifyListeners();
    return res;
  }

  Future<bool> updateUserNameAndStatus(String name, String documentId) async {
    return await _userRepository.updateUserNameAndStatus(name, documentId);
  }
}
