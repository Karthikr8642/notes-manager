import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? color;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    this.icon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (color ?? scheme.primary).withOpacity(0.12),
            (color ?? scheme.primary).withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withOpacity(0.06),
            blurRadius: 10,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          if (icon != null)
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (color ?? scheme.primary).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color ?? scheme.primary),
            ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelSmall),
              SizedBox(height: 6),
              Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ],
          )
        ],
      ),
    );
  }
}
