import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/router/route_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/mada_primary_button.dart';

class _Slide {
  const _Slide(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;
}

/// Onboarding — 3 شرائح عامة (بند 3-أ-1).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  final _slides = const [
    _Slide(Icons.local_taxi_rounded, 'اطلب رحلتك بضغطة واحدة', 'سائقون قريبون منك في محافظة درعا، جاهزون بأي وقت.'),
    _Slide(Icons.directions_car_filled_rounded, 'استأجر سيارة بسهولة', 'تصفح مكاتب التأجير الموثوقة واختر السيارة المناسبة لك.'),
    _Slide(Icons.local_shipping_rounded, 'وصّل طرودك بأمان', 'توصيل سريع وموثوق لطرودك عبر نفس شبكة السائقين.'),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (mounted) context.go(RoutePaths.terms);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(onPressed: _finish, child: const Text('تخطي')),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final s = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(s.icon, size: 96, color: AppColors.turquoise),
                        const SizedBox(height: 32),
                        Text(s.title, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Text(s.body, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _index ? AppColors.turquoise : AppColors.navyLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: MadaPrimaryButton(
                label: _index == _slides.length - 1 ? 'ابدأ الآن' : 'التالي',
                onPressed: () {
                  if (_index == _slides.length - 1) {
                    _finish();
                  } else {
                    _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
