import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../domain/entities/note.dart';
import 'notes_controller.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../../core/utils/validators.dart';

class AddEditNotePage extends StatefulWidget {
  const AddEditNotePage({super.key});

  @override
  State<AddEditNotePage> createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  late final NotesController ctrl;
  Note? editing;

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<NotesController>();
    final arg = Get.arguments;
    if (arg is Note) {
      editing = arg;
      _titleCtrl.text = editing!.title;
      _descCtrl.text = editing!.description;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    if (editing == null) {
      final user = Get.find<AuthController>().user.value;
      if (user == null) return Get.back();
      await ctrl.addNote(title: title, description: desc, uid: user.uid);
    } else {
      await ctrl.updateNote(id: editing!.id, title: title, description: desc);
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = editing != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Note' : 'Add Note')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title'), validator: Validators.validateTitle),
                  const SizedBox(height: 12),
                  TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 6),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(onPressed: _save, child: Text(isEditing ? 'Save' : 'Add')),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
