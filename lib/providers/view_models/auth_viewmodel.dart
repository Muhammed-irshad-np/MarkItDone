import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:markitdone/config/theme.dart';
import 'package:markitdone/data/repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  String? _phoneNumber;
  String? _name;
  String _verificationId = '';
  bool _isOTPSent = false;
  String? documentId = '';
  bool isLoading = false;

  String get phoneNumber => _phoneNumber ?? '';
  String get name => _name ?? '';

  bool get isOTPSent => _isOTPSent;

  AuthViewModel(this._userRepository);

  void setUserData(String phone, {String? name}) {
    _phoneNumber = phone;
    _name = name;
    notifyListeners();
  }

  void setIsOTPSent(bool value) {
    _isOTPSent = value;
    notifyListeners();
  }

  Future<void> fetchUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();

      if (userDoc.exists) {
        _name = userDoc.data()?['name'];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  void setPhoneNumber(String number) {
    _phoneNumber = "+91$number";
    notifyListeners();
  }

  // Method to verify the phone number
  Future<void> verifyPhoneNumber() async {
    isLoading = true;
    notifyListeners();

    await _userRepository.sendOTP(_phoneNumber!, (String verificationId) {
      _verificationId =
          verificationId; // Store the verification ID for later use
      // _isOTPSent = true; // OTP has been sent successfully
    });
    _isOTPSent = true;
    notifyListeners();
  }

  Future<void> handleOtpSubmit(
    BuildContext context,
    String otp,
  ) async {
    isLoading = true;
    notifyListeners();
    try {
      final user = await signInWithOTP(otp);

      if (user != null) {
        final res = await registerorloginuser(context);
        if (res['documentId'] != null) {
          if (res['isFirstTimeUser']) {
            Navigator.pushReplacementNamed(context, '/register');
          } else {
            Navigator.pushReplacementNamed(context, '/main');
          }
        }
      }
    } catch (e) {
      isLoading = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication failed: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      // isLoading = false;
      notifyListeners();
    }
  }

  // Method to sign in with the OTP
  Future<User?> signInWithOTP(String otp) async {
    return await _userRepository.verifyOTP(_verificationId, otp);
  }

  Future<Map<String, dynamic>> registerorloginuser(BuildContext context) async {
    if (_phoneNumber?.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a phone number'),
        ),
      );

      return {'isFirstTimeUser': false, 'documentId': null};
    }

    final res = await _userRepository.registerorloginuser(_phoneNumber!);
    documentId = res['documentId'] ?? "";
    await fetchUserData();
    notifyListeners();
    return res;
  }

  Future<bool> updateUserNameAndStatus(String name, String documentId) async {
    return await _userRepository.updateUserNameAndStatus(name, documentId);
  }

  void reset() {
    _phoneNumber = null;
    _name = null;
    _verificationId = '';
    _isOTPSent = false;
    documentId = '';
    isLoading = false;
    notifyListeners();
  }
}
