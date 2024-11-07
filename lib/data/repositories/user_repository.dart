import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> registerorloginuser(String mobileNumber) async {
    // Query Firestore to check if phone number exists
    QuerySnapshot userQuery = await _firestore
        .collection('users')
        .where('phoneNumber', isEqualTo: mobileNumber)
        .get();

    if (userQuery.docs.isEmpty) {
      // Create a new user document
      DocumentReference docRef = await _firestore.collection('users').add({
        'phoneNumber': mobileNumber,
        'isFirstTimeUser': true,
        'createdAt': FieldValue.serverTimestamp(),
        'assignedTasks': []
      });

      // Return the new document ID
      return {'isFirstTimeUser': true, 'documentId': docRef.id};
      // No existing user found with this phone number
    } else {
      // User exists, get their isFirstTimeUser status and document ID
      DocumentSnapshot userDoc = userQuery.docs.first;
      return {
        'isFirstTimeUser': userDoc.get('isFirstTimeUser') ?? false,
        'documentId': userDoc.id
      };
    }
  }

  Future<bool> updateUserNameAndStatus(String name, String documentId) async {
    await _firestore.collection('users').doc(documentId).update({
      'name': name,
      'isFirstTimeUser': false,
    });
    try {
      await _firestore.collection('users').doc(documentId).update({
        'name': name,
        'isFirstTimeUser': false,
      });
      return true;
    } catch (e) {
      return false;
    }
    // No need to return anything since this is a Future<void> method
  }

  // Send OTP to the given phone number
  Future<void> sendOTP(String phoneNumber, Function(String) onCodeSent) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification scenario
        await _auth.signInWithCredential(credential);
        await _checkAndCreateUser();
      },
      verificationFailed: (FirebaseAuthException e) {
        throw Exception('Verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId); // Call the provided callback
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Handle auto-retrieval timeout if necessary
      },
    );
  }

  // Verify the OTP entered by the user and return the user
  Future<User?> verifyOTP(String verificationId, String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    try {
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      await _checkAndCreateUser();
      return userCredential.user;
    } catch (e) {
      throw Exception('Verification failed: ${e.toString()}');
    }
  }

  // Check if the user exists in Firestore and create a new profile if not
  Future<void> _checkAndCreateUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        // Create new user document in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'phoneNumber': user.phoneNumber,
          'name': '', // Initial empty name; you can update it later
          'createdAt': FieldValue.serverTimestamp(),
          'isFirstTimeUser': true,
          'assignedTasks': []
        });
      }
      // Optionally, you can update the user profile here if needed
    }
  }

  // Check if a phone number already exists
  Future<bool> isPhoneNumberExists(String phoneNumber) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get();

    return snapshot.docs.isNotEmpty; // Return true if phone number exists
  }
}
