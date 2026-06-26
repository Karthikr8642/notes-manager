import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auth/presentation/auth_controller.dart';
import '../domain/entities/expense.dart';
import 'expenses_controller.dart';

class AddEditExpensePage extends StatefulWidget {
  const AddEditExpensePage({super.key});

  @override
  State<AddEditExpensePage> createState() => _AddEditExpensePageState();
}

class _AddEditExpensePageState extends State<AddEditExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _merchantCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String paymentMode = 'UPI';
  DateTime selectedDate = DateTime.now();
  late final ExpensesController controller;
  late final AuthController authController;
  Expense? editing;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ExpensesController>();
    authController = Get.find<AuthController>();
    final arg = Get.arguments;
    if (arg is Expense) {
      editing = arg;
      _amountCtrl.text = arg.amount.toStringAsFixed(0);
      _merchantCtrl.text = arg.merchant;
      _categoryCtrl.text = arg.category;
      _noteCtrl.text = arg.note;
      paymentMode = arg.paymentMode;
      selectedDate = arg.date;
    }
    _merchantCtrl.addListener(_updateCategoryFromMerchant);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _merchantCtrl.dispose();
    _categoryCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _updateCategoryFromMerchant() {
    final merchant = _merchantCtrl.text.trim();
    if (merchant.isEmpty) return;
    final suggestion = controller.suggestCategory(merchant);
    if (_categoryCtrl.text.isEmpty || _categoryCtrl.text == 'Others') {
      _categoryCtrl.text = suggestion;
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    final merchant = _merchantCtrl.text.trim();
    final category = _categoryCtrl.text.trim().isEmpty ? 'Others' : _categoryCtrl.text.trim();
    final note = _noteCtrl.text.trim();

    final duplicates = controller.duplicatesFor(
      amount: amount,
      merchant: merchant,
      date: selectedDate,
    );
    if (duplicates.isNotEmpty && editing == null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Possible duplicate'),
          content: Text('A similar expense was found: ${duplicates.first.merchant} ₹${duplicates.first.amount.toStringAsFixed(0)} on ${duplicates.first.date.day}/${duplicates.first.date.month}/${duplicates.first.date.year}. Save anyway?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    if (editing == null) {
      final user = authController.user.value;
      if (user == null) return;
      await controller.addExpense(
        amount: amount,
        merchant: merchant,
        category: category,
        date: selectedDate,
        paymentMode: paymentMode,
        note: note,
        uid: user.uid,
      );
    } else {
      await controller.updateExpense(
        id: editing!.id,
        amount: amount,
        merchant: merchant,
        category: category,
        date: selectedDate,
        paymentMode: paymentMode,
        note: note,
      );
    }
    if (controller.error.value == null) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = editing != null;
    const paymentModes = ['UPI', 'Cash', 'Card', 'NetBanking', 'Wallet'];
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Expense' : 'Add Expense')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Amount is required';
                      }
                      if (double.tryParse(value.trim()) == null) {
                        return 'Enter a valid amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _merchantCtrl,
                    decoration: const InputDecoration(labelText: 'Merchant'),
                    validator: (value) => (value?.trim().isEmpty ?? true) ? 'Merchant is required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _categoryCtrl,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: paymentMode,
                    items: paymentModes.map((mode) => DropdownMenuItem(value: mode, child: Text(mode))).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => paymentMode = value);
                    },
                    decoration: const InputDecoration(labelText: 'Payment Mode'),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Date'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                          const Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _noteCtrl,
                    decoration: const InputDecoration(labelText: 'Note'),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: Text(isEditing ? 'Save Expense' : 'Add Expense'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
