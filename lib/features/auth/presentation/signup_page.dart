import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth_controller.dart';
import '../../../core/utils/validators.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Obx(() {
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full name'), validator: Validators.validateName),
                    const SizedBox(height: 12),
                    TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email'), validator: Validators.validateEmail),
                    const SizedBox(height: 12),
                    TextFormField(controller: _pwdCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password'), validator: Validators.validatePassword),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Confirm password'),
                      validator: (v) => Validators.validateConfirm(_pwdCtrl.text, v),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: ctrl.loading.value
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) return;
                                await ctrl.signUp(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _pwdCtrl.text.trim());
                                if (ctrl.user.value != null) {
                                  Get.offAllNamed('/notes');
                                } else if (ctrl.error.value != null) {
                                  Get.snackbar('Sign up error', ctrl.error.value!, snackPosition: SnackPosition.BOTTOM);
                                }
                              },
                        child: ctrl.loading.value ? const CircularProgressIndicator() : const Text('Sign up'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
