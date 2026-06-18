import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> signIn(String email, String password) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> register(String email, String password) async {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> notesStream(String uid) {
    return _firestore.collection('notes').where('userId', isEqualTo: uid).snapshots();
  }

  Future<DocumentReference> addNote(Map<String, dynamic> data) async {
    return _firestore.collection('notes').add(data);
  }

  Future<void> updateNote(String id, Map<String, dynamic> data) async {
    await _firestore.collection('notes').doc(id).update(data);
  }

  Future<void> deleteNote(String id) async {
    await _firestore.collection('notes').doc(id).delete();
  }
}
