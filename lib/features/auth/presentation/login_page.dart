import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth_controller.dart';
import '../../../core/utils/validators.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
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
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pwdCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: ctrl.loading.value
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) return;
                                await ctrl.signIn(_emailCtrl.text.trim(), _pwdCtrl.text.trim());
                                if (ctrl.user.value != null) {
                                  Get.offAllNamed('/notes');
                                } else if (ctrl.error.value != null) {
                                  Get.snackbar('Sign in error', ctrl.error.value!, snackPosition: SnackPosition.BOTTOM);
                                }
                              },
                        child: ctrl.loading.value ? const CircularProgressIndicator() : const Text('Sign in'),
                      ),
                    ),
                    TextButton(onPressed: () => Get.toNamed('/signup'), child: const Text('Create account')),
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
