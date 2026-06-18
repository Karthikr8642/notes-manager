import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../domain/entities/note.dart';

class NotesController extends GetxController {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;

  final notes = <Note>[].obs;
  final loading = false.obs;
  final error = RxnString();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  void subscribe(String uid) {
    _sub?.cancel();

    _sub = _fire
        .collection('notes')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen(
      (snap) {

        notes.value = snap.docs.map((d) {
          final data = d.data();

          return Note(
            id: d.id,
            title: data['title'] ?? '',
            description: data['description'] ?? '',
            userId: data['userId'] ?? '',
            createdAt:
                (data['createdAt'] as Timestamp?)?.toDate(),
            updatedAt:
                (data['updatedAt'] as Timestamp?)?.toDate(),
          );
        }).toList();

      },
      onError: (e) {
        print('SUBSCRIBE ERROR');
        print(e);
        error.value = e.toString();
      },
    );
  }

  Future<void> addNote({
    required String title,
    required String description,
    required String uid,
  }) async {
    loading.value = true;
    error.value = null;

    print('========================');
    print('UID: $uid');
    print('TITLE: $title');
    print('DESCRIPTION: $description');
    print('========================');

    try {
      final docRef = await _fire.collection('notes').add({
        'title': title,
        'description': description,
        'userId': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('DOC ID: ${docRef.id}');
    } catch (e) {
      print(e);
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<void> updateNote({
    required String id,
    required String title,
    required String description,
  }) async {
    loading.value = true;
    error.value = null;

    try {
      await _fire.collection('notes').doc(id).update({
        'title': title,
        'description': description,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _fire.collection('notes').doc(id).delete();
    } catch (e) {
      error.value = e.toString();
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}