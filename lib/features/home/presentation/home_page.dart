import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/quick_action_button.dart';
import '../../../core/widgets/stat_card.dart';
import 'home_controller.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Good Evening, Karthik 👋'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.primary.withOpacity(0.96),
              scheme.secondary.withOpacity(0.96),
              scheme.primaryContainer.withOpacity(0.96),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _buildSearchBar(context),
                const SizedBox(height: 24),
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Wallet Balance', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.onPrimaryContainer.withOpacity(0.88))),
                      const SizedBox(height: 12),
                      Text('₹54,280', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800, color: scheme.onPrimaryContainer)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMiniStat(context, 'Today', '₹1,240'),
                          _buildMiniStat(context, 'Budget Left', '₹18,760'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(child: StatCard(title: 'Spending', value: '₹12,400', icon: Icons.trending_up, color: Colors.deepPurple)),
                    const SizedBox(width: 12),
                    Expanded(child: StatCard(title: 'Saved', value: '₹4,200', icon: Icons.savings, color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: StatCard(title: 'AI Score', value: '92', icon: Icons.smart_toy, color: Colors.amber)),
                    const SizedBox(width: 12),
                    Expanded(child: StatCard(title: 'Expense', value: 'Today', icon: Icons.today, color: Colors.indigo)),
                  ],
                ),
                const SizedBox(height: 24),
                Text('AI Recommendation', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Don’t order food today.', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: scheme.onSurface)),
                      const SizedBox(height: 8),
                      Text('You already spent ₹3,200 this week on dining out.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurface.withOpacity(0.8))),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Recent Transactions', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ...controller.recentTransactions.map((tx) => _buildTransactionCard(context, tx)).toList(),
                const SizedBox(height: 24),
                Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.quickActions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final action = controller.quickActions[index];
                      return QuickActionButton(
                        icon: action['icon'],
                        label: action['label'],
                        onTap: () {},
                      );
                    },
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickActionSheet(context),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Obx(() {
        return BottomAppBar(
          color: Theme.of(context).scaffoldBackgroundColor,
          elevation: 16,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, Icons.home_filled, 'Home', 0),
                _buildNavItem(context, Icons.account_balance_wallet, 'Wallet', 1),
                const SizedBox(width: 56),
                _buildNavItem(context, Icons.smart_toy, 'AI', 2),
                _buildNavItem(context, Icons.bar_chart, 'Analytics', 3),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search expenses, insights, actions...',
        filled: true,
        fillColor: scheme.surface.withOpacity(0.92),
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildMiniStat(BuildContext context, String label, String amount) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: scheme.background.withOpacity(0.22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text(amount, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, Map<String, dynamic> data) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: (data['color'] as Color).withOpacity(0.16),
              child: Icon(Icons.shopping_bag, color: data['color']),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['title'], style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(data['subtitle'], style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
            Text(data['amount'], style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => controller.setIndex(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: controller.selectedIndex.value == index ? scheme.primary : Theme.of(context).iconTheme.color),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: controller.selectedIndex.value == index ? scheme.primary : scheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  void _showQuickActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quick Add', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: controller.quickActions.map((action) {
                  return QuickActionButton(
                    icon: action['icon'] as IconData,
                    label: action['label'] as String,
                    onTap: () => Navigator.pop(context),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
