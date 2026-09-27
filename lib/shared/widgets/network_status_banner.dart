import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// شريط "غير متصل" واضح عند الانقطاع (بند 9).
/// ⚠️ قرار تبسيط موثَّق: يعرض حالتين فقط (متصل/منقطع) عبر connectivity_plus
/// (يكتشف نوع الاتصال: wifi/mobile/none، لا جودته). التدرّج الكامل
/// (ممتاز/جيد/ضعيف/منقطع) المذكور بالمواصفة يتطلب قياس زمن استجابة فعلي
/// (latency probing) — إضافة لاحقة ممكنة دون تغيير بنية هذا الودجت.
class NetworkStatusBanner extends StatelessWidget {
  const NetworkStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final results = snapshot.data ?? [ConnectivityResult.none];
        final isOffline = results.every((r) => r == ConnectivityResult.none);
        if (!isOffline) return const SizedBox.shrink();

        return Material(
          color: AppColors.error,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text('غير متصل بالإنترنت', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
