import 'package:flutter/material.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PalEyesPage(
      title: 'لوحة الإدارة',
      subtitle:
          'واجهة تأسيسية غير متصلة بالمصادقة أو قاعدة البيانات. جميع الإجراءات الكتابية معطلة.',
      actions: const <Widget>[
        Chip(
          avatar: Icon(Icons.lock_outline_rounded, size: 18),
          label: Text('Read-only foundation'),
        ),
      ],
      child: const _AdminGrid(),
    );
  }
}

class _AdminGrid extends StatelessWidget {
  const _AdminGrid();

  @override
  Widget build(BuildContext context) {
    const items = <(IconData, String)>[
      (Icons.account_balance_outlined, 'إدارة المواقع'),
      (Icons.edit_note_outlined, 'محرر الروايات'),
      (Icons.fact_check_outlined, 'مراجعة الادعاءات'),
      (Icons.library_books_outlined, 'إدارة المصادر'),
      (Icons.photo_library_outlined, 'مكتبة الوسائط'),
      (Icons.map_outlined, 'إدارة الخرائط'),
      (Icons.people_outline, 'المستخدمون والصلاحيات'),
      (Icons.history_outlined, 'سجل التدقيق'),
    ];
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: items
          .map(
            (item) => SizedBox(
              width: 275,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: <Widget>[
                      Icon(item.$1),
                      const SizedBox(width: 12),
                      Expanded(child: Text(item.$2)),
                      const Icon(Icons.lock_outline_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
