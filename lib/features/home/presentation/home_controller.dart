import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final selectedIndex = 0.obs;

  void setIndex(int index) {
    selectedIndex.value = index;
  }

  final recentTransactions = <Map<String, dynamic>>[
    {
      'title': 'Amazon Purchase',
      'subtitle': 'Shopping • Yesterday',
      'amount': '-₹560',
      'color': Colors.indigo,
    },
    {
      'title': 'Swiggy Order',
      'subtitle': 'Food • Today',
      'amount': '-₹420',
      'color': Colors.orange,
    },
    {
      'title': 'Fuel',
      'subtitle': 'Transport • Today',
      'amount': '-₹900',
      'color': Colors.teal,
    },
  ];

  final quickActions = <Map<String, dynamic>>[
    {'icon': Icons.add_chart, 'label': 'Expense'},
    {'icon': Icons.arrow_downward, 'label': 'Income'},
    {'icon': Icons.camera_alt, 'label': 'Scan'},
    {'icon': Icons.mic, 'label': 'Voice'},
  ];
}
