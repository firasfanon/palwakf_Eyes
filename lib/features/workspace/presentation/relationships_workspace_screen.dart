import 'package:flutter/material.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_product_ux.dart';

class RelationshipsWorkspaceScreen extends StatelessWidget {
  const RelationshipsWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PalEyesTaskPage(
      title: 'علاقات المواقع والأسماء',
      subtitle:
          'إدارة الموقع الأم والمكوّنات والأسماء البديلة والروابط المكانية.',
      icon: Icons.hub_outlined,
      child: Column(
        children: const <Widget>[
          Card(
            child: PalEyesWorkflowStatus(
              label: 'الحرم القدسي الشريف',
              status: 'موقع أم • مكونات متعددة',
              icon: Icons.account_tree_outlined,
            ),
          ),
          Card(
            child: PalEyesWorkflowStatus(
              label: 'برك سليمان',
              status: 'منظومة مائية • مواقع مرتبطة',
              icon: Icons.water_outlined,
            ),
          ),
          Card(
            child: PalEyesWorkflowStatus(
              label: 'سبسطية',
              status: 'موقع/بلدة/طبقات زمنية',
              icon: Icons.layers_outlined,
            ),
          ),
          PalEyesEmptyState(
            title: 'علاقة جديدة',
            message: 'حدد نوع العلاقة والطرفين وأضف الدليل قبل اعتمادها.',
            actionLabel: 'اقتراح علاقة',
            onAction: _noop,
            icon: Icons.add_link_outlined,
          ),
        ],
      ),
    );
  }

  static void _noop() {}
}
