import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// شاشة نائبة مؤقتة — تُستبدل بالشاشات الفعلية تباعاً بكل مرحلة (بند 6-1).
/// وجودها الآن يثبت فقط أن هيكل التوجيه والمشروع يعمل فعلاً من المرحلة 0.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction_rounded, size: 48, color: AppColors.gold),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
