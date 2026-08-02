import 'package:flutter/material.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_visual_system.dart';

class PalEyesPage extends StatelessWidget {
  const PalEyesPage({
    required this.title,
    required this.subtitle,
    required this.child,
    this.actions = const <Widget>[],
    this.header,
    this.maxWidth = 1240,
    this.icon,
    this.eyebrow,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget> actions;
  final Widget? header;
  final double maxWidth;
  final IconData? icon;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    final horizontal = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 28.0;
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: PalEyesPageHero(
            title: title,
            subtitle: subtitle,
            actions: actions,
            header: header,
            icon: icon ?? _iconForTitle(title),
            eyebrow: eyebrow ?? _eyebrowForTitle(title),
            maxWidth: maxWidth,
          ),
        ),
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  28,
                  horizontal,
                  64,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _iconForTitle(String value) {
    if (value.contains('مصدر') || value.contains('مراجع')) {
      return Icons.library_books_outlined;
    }
    if (value.contains('خريطة') || value.contains('جغراف')) {
      return Icons.map_outlined;
    }
    if (value.contains('محافظ')) {
      return Icons.location_city_outlined;
    }
    if (value.contains('زمني') || value.contains('فترة')) {
      return Icons.timeline_outlined;
    }
    if (value.contains('قصة') || value.contains('رواية')) {
      return Icons.auto_stories_outlined;
    }
    if (value.contains('ساهم') || value.contains('مساهمة')) {
      return Icons.volunteer_activism_outlined;
    }
    if (value.contains('منهج') || value.contains('توثيق')) {
      return Icons.fact_check_outlined;
    }
    if (value.contains('عمل') || value.contains('إدارة')) {
      return Icons.dashboard_customize_outlined;
    }
    if (value.contains('حوكمة') || value.contains('نظام')) {
      return Icons.admin_panel_settings_outlined;
    }
    return Icons.account_balance_outlined;
  }

  String _eyebrowForTitle(String value) {
    if (value.contains('عمل') || value.contains('إدارة')) {
      return 'مساحة العمل';
    }
    if (value.contains('حوكمة') || value.contains('نظام')) {
      return 'الحوكمة والضبط';
    }
    return 'المكان • الرواية • الدليل';
  }
}
