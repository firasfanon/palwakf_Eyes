import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return PalEyesPage(
      title: 'الصفحة غير موجودة',
      subtitle: message,
      child: Center(
        child: FilledButton.icon(
          onPressed: () => context.go(RoutePaths.home),
          icon: const Icon(Icons.home_outlined),
          label: const Text('العودة للرئيسية'),
        ),
      ),
    );
  }
}
