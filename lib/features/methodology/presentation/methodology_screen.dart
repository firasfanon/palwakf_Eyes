import 'package:flutter/material.dart';
import 'package:pal_eyes/app/theme/app_colors.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_visual_system.dart';

class MethodologyScreen extends StatelessWidget {
  const MethodologyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const steps = <(IconData, String, String)>[
      (
        Icons.find_in_page_outlined,
        'اكتشاف المصدر',
        'تسجيل المرجع أو المادة الأصلية قبل استخدامها.',
      ),
      (
        Icons.format_list_bulleted_rounded,
        'تفكيك الادعاءات',
        'تحويل النص إلى ادعاءات واضحة قابلة للتحقق.',
      ),
      (
        Icons.link_rounded,
        'ربط الدليل',
        'ربط المصدر والصفحة أو المقطع بكل ادعاء.',
      ),
      (
        Icons.fact_check_outlined,
        'التدقيق التاريخي',
        'مقارنة المصادر وفحص الزمن والمصطلحات والسياق.',
      ),
      (
        Icons.rate_review_outlined,
        'المراجعة التحريرية',
        'تحسين السرد والفصل بين الدليل والتفسير.',
      ),
      (
        Icons.gavel_outlined,
        'مراجعة الحقوق',
        'فحص الاقتباسات والصور والتسجيلات والموافقات.',
      ),
      (
        Icons.verified_outlined,
        'الاعتماد والنشر',
        'قرار بشري مسجل؛ لا اعتماد أو نشر تلقائي.',
      ),
    ];

    return PalEyesPage(
      title: 'كيف ننتقل من المسودة إلى المادة المعتمدة؟',
      subtitle:
          'منهجية مرئية تبين المسار من المصدر الأول إلى رواية فلسطينية موثقة وقابلة للمراجعة.',
      icon: Icons.fact_check_outlined,
      eyebrow: 'الثقة والمنهجية',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              gradient: AppColors.sovereignGradient,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Stack(
              children: <Widget>[
                Positioned.fill(child: PalEyesPattern(opacity: 0.04)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.verified_user_outlined,
                      color: AppColors.softGold,
                      size: 44,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'لا تتحول المسودة إلى مادة منشورة لمجرد اكتمال النص؛ يجب أن يكون كل ادعاء قابلاً للتتبع إلى مصدر ودليل وحالة مراجعة.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          height: 1.7,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 34),
          const PalEyesSectionHeader(
            eyebrow: 'دورة التوثيق',
            icon: Icons.account_tree_outlined,
            title: 'سبع محطات واضحة من المصدر إلى الاعتماد',
            subtitle:
                'الزائر يرى المنهجية باختصار، بينما تبقى التفاصيل التشغيلية وسجلات القرارات في مساحة العمل.',
          ),
          const SizedBox(height: 20),
          ...steps.asMap().entries.map(
                (entry) => _MethodStep(
                  number: entry.key + 1,
                  icon: entry.value.$1,
                  title: entry.value.$2,
                  description: entry.value.$3,
                  last: entry.key == steps.length - 1,
                ),
              ),
          const SizedBox(height: 34),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth >= 760
                  ? (constraints.maxWidth - 16) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: <Widget>[
                  SizedBox(
                    width: width,
                    height: 230,
                    child: const PalEyesVisualCard(
                      icon: Icons.library_books_outlined,
                      title: 'المصدر ليس مجرد اسم',
                      description:
                          'نحتاج النسخة الأصلية أو الرقمية، بيانات النشر، الصفحة أو المقطع، وحالة الحقوق.',
                      label: 'تتبع ببليوغرافي',
                    ),
                  ),
                  SizedBox(
                    width: width,
                    height: 230,
                    child: const PalEyesVisualCard(
                      icon: Icons.balance_outlined,
                      title: 'التعارض لا يُخفى',
                      description:
                          'عند اختلاف المصادر نعرض موضع الاختلاف ونفصل بين الدليل والترجيح التحريري.',
                      label: 'شفافية المراجعة',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MethodStep extends StatelessWidget {
  const _MethodStep({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
    required this.last,
  });

  final int number;
  final IconData icon;
  final String title;
  final String description;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 58,
          child: Column(
            children: <Widget>[
              CircleAvatar(
                radius: 22,
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                child: Text(
                  '$number',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              if (!last)
                Container(
                  width: 2,
                  height: 92,
                  color: scheme.primary.withValues(alpha: 0.20),
                ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: scheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: scheme.onSecondaryContainer),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 6),
                          Text(description),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
