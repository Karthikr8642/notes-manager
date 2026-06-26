import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/constants/app_routes.dart';
import 'core/constants/app_theme.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/signup_page.dart';
import 'features/notes/presentation/notes_page.dart';
import 'features/notes/presentation/add_edit_note_page.dart';
import 'features/expenses/presentation/expenses_page.dart';
import 'features/expenses/presentation/add_edit_expense_page.dart';
import 'injection.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/auth/presentation/splash_page.dart';
import 'features/notes/presentation/notes_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // If you run `flutterfire configure` it will generate a proper
  // firebase_options.dart that you can pass to initializeApp.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await configureDependencies();

  // Register controllers using GetX
  Get.put(AuthController());
  Get.put(NotesController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Notes Manager',
      theme: AppTheme.theme,
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashPage()),
        GetPage(name: AppRoutes.login, page: () => const LoginPage()),
        GetPage(name: '/signup', page: () => const SignupPage()),
        GetPage(name: AppRoutes.notes, page: () => const NotesPage()),
        GetPage(name: '/note', page: () => const AddEditNotePage()),
        GetPage(name: AppRoutes.expenses, page: () => const ExpensesPage()),
        GetPage(name: AppRoutes.expense, page: () => const AddEditExpensePage()),
      ],
    );
  }
}
 
