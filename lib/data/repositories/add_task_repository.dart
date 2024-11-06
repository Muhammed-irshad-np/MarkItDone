import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTaskRepository {
  // ... existing initialization ...
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add new task
  Future<bool> addTask({
    required String title,
    required String assignedTo,
    required DateTime scheduledTime,
    String state = 'inprogress',
    bool isPostponed = false,
    required String createdBy,
  }) async {
    try {
      // ... existing validation ...

      await _firestore.collection('alltasks').add({
        // Updated collection name
        'title': title,
        'assignedTo': assignedTo,
        'createdBy': createdBy,
        'scheduledTime': Timestamp.fromDate(scheduledTime),
        'state': state,
        'isPostponed': isPostponed,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error adding task: $e');
      return false;
    }
  }

  // Update existing task
  Future<bool> updateTask({
    required String taskId,
    String? title,
    String? assignedTo,
    DateTime? scheduledTime,
    String? state,
    bool? isPostponed,
  }) async {
    try {
      // ... existing update logic ...
      await _firestore
          .collection('alltasks')
          .doc(taskId)
          .update({}); // Updated collection name
      return true;
    } catch (e) {
      print('Error updating task: $e');
      return false;
    }
  }

  // Delete task
  Future<bool> deleteTask(String taskId) async {
    try {
      await _firestore
          .collection('alltasks')
          .doc(taskId)
          .delete(); // Updated collection name
      return true;
    } catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }

  // Fetch tasks by user
  Stream<QuerySnapshot> getTasksByUser({bool asCreator = false}) {
    final String? userId = _auth.currentUser?.uid;

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return _firestore
        .collection('alltasks') // Updated collection name
        .where(asCreator ? 'createdBy' : 'assignedTo', isEqualTo: userId)
        .orderBy('scheduledTime', descending: true)
        .snapshots();
  }

  // Get single task by ID
  Future<DocumentSnapshot?> getTaskById(String taskId) async {
    try {
      return await _firestore
          .collection('alltasks')
          .doc(taskId)
          .get(); // Updated collection name
    } catch (e) {
      print('Error fetching task: $e');
      return null;
    }
  }
}
