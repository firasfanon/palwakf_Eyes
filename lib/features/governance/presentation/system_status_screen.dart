import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/core/config/app_environment.dart';
import 'package:pal_eyes/core/supabase/supabase_bootstrap.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';

class SystemStatusScreen extends ConsumerWidget {
  const SystemStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environment = ref.watch(appEnvironmentProvider);
    final supabase = ref.watch(supabaseBootstrapResultProvider);

    final rows = <(String, String, IconData)>[
      ('البيئة', environment.environmentName, Icons.layers_outlined),
      (
        'Supabase',
        supabase.isEnabled ? 'مهيأ' : 'غير متصل',
        Icons.cloud_outlined,
      ),
      ('قاعدة البيانات', 'لا كتابة حية', Icons.storage_outlined),
      ('النشر العام', 'غير مفعل', Icons.public_off_outlined),
      (
        'كتالوج المسودة',
        '79 موقعاً • 47 رواية موسعة',
        Icons.account_balance_outlined,
      ),
      ('سجل المصادر', '79 مدخلاً غير متحقق', Icons.library_books_outlined),
      ('الإحداثيات', '3 متاحة • 76 فجوة', Icons.location_off_outlined),
      ('Baseline', 'Full Draft Catalog R3.0.0', Icons.verified_outlined),
    ];

    return PalEyesPage(
      title: 'حالة النظام',
      subtitle: 'المعلومات التقنية نُقلت إلى هنا ولم تعد تظهر للزائر العام.',
      child: Column(
        children: rows
            .map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(18),
                    leading: CircleAvatar(child: Icon(row.$3)),
                    title: Text(row.$1),
                    subtitle: Text(row.$2),
                  ),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}
