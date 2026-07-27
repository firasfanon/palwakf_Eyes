import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/core/widgets/public_shell.dart';
import 'package:pal_eyes/core/widgets/workspace_shell.dart';
import 'package:pal_eyes/features/common/presentation/not_found_screen.dart';
import 'package:pal_eyes/features/contributions/presentation/contribute_screen.dart';
import 'package:pal_eyes/features/discovery/presentation/discovery_screen.dart';
import 'package:pal_eyes/features/governance/presentation/governance_overview_screen.dart';
import 'package:pal_eyes/features/governance/presentation/system_status_screen.dart';
import 'package:pal_eyes/features/governorates/presentation/governorates_screen.dart';
import 'package:pal_eyes/features/home/presentation/home_screen.dart';
import 'package:pal_eyes/features/map/presentation/map_screen.dart';
import 'package:pal_eyes/features/methodology/presentation/methodology_screen.dart';
import 'package:pal_eyes/features/places/presentation/place_detail_screen.dart';
import 'package:pal_eyes/features/places/presentation/places_screen.dart';
import 'package:pal_eyes/features/sources/presentation/sources_screen.dart';
import 'package:pal_eyes/features/stories/presentation/stories_screen.dart';
import 'package:pal_eyes/features/stories/presentation/story_detail_screen.dart';
import 'package:pal_eyes/features/timeline/presentation/timeline_screen.dart';
import 'package:pal_eyes/features/workspace/presentation/audit_log_screen.dart';
import 'package:pal_eyes/features/workspace/presentation/claim_workspace_screen.dart';
import 'package:pal_eyes/features/workspace/presentation/gis_review_screen.dart';
import 'package:pal_eyes/features/workspace/presentation/media_rights_screen.dart';
import 'package:pal_eyes/features/workspace/presentation/new_place_draft_screen.dart';
import 'package:pal_eyes/features/workspace/presentation/relationships_workspace_screen.dart';
import 'package:pal_eyes/features/workspace/presentation/release_control_screen.dart';
import 'package:pal_eyes/features/workspace/presentation/review_queue_screen.dart';
import 'package:pal_eyes/features/workspace/presentation/site_editor_screen.dart';
import 'package:pal_eyes/features/workspace/presentation/source_registry_workspace_screen.dart';
import 'package:pal_eyes/features/workspace/presentation/workspace_dashboard_screen.dart';
import 'package:pal_eyes/features/workspace/presentation/workspace_places_screen.dart';
import 'package:pal_eyes/features/workspace/presentation/workspace_section_screen.dart';
import 'package:pal_eyes/features/workspace/presentation/workspace_today_screen.dart';

final appRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: RoutePaths.home,
    errorBuilder: (context, state) => NotFoundScreen(
      message: state.error?.toString() ?? 'المسار المطلوب غير مسجل.',
    ),
    routes: <RouteBase>[
      ShellRoute(
        builder: (context, state, child) =>
            PublicShell(location: state.uri.path, child: child),
        routes: <RouteBase>[
          GoRoute(
            path: RoutePaths.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: RoutePaths.discover,
            builder: (context, state) => const DiscoveryScreen(),
          ),
          GoRoute(
            path: RoutePaths.places,
            builder: (context, state) => const PlacesScreen(),
          ),
          GoRoute(
            path: RoutePaths.placeDetail,
            builder: (context, state) =>
                PlaceDetailScreen(slug: state.pathParameters['slug'] ?? ''),
          ),
          GoRoute(
            path: RoutePaths.map,
            builder: (context, state) => const MapScreen(),
          ),
          GoRoute(
            path: RoutePaths.timeline,
            builder: (context, state) => const TimelineScreen(),
          ),
          GoRoute(
            path: RoutePaths.governorates,
            builder: (context, state) => const GovernoratesScreen(),
          ),
          GoRoute(
            path: RoutePaths.stories,
            builder: (context, state) => const StoriesScreen(),
          ),
          GoRoute(
            path: RoutePaths.storyDetail,
            builder: (context, state) =>
                StoryDetailScreen(slug: state.pathParameters['slug'] ?? ''),
          ),
          GoRoute(
            path: RoutePaths.sources,
            builder: (context, state) => const SourcesScreen(),
          ),
          GoRoute(
            path: RoutePaths.contribute,
            builder: (context, state) => const ContributeScreen(),
          ),
          GoRoute(
            path: RoutePaths.methodology,
            builder: (context, state) => const MethodologyScreen(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) =>
            WorkspaceShell(location: state.uri.path, child: child),
        routes: <RouteBase>[
          GoRoute(
            path: RoutePaths.workspace,
            builder: (context, state) => const WorkspaceDashboardScreen(),
          ),
          GoRoute(
            path: RoutePaths.workspaceToday,
            builder: (context, state) => const WorkspaceTodayScreen(),
          ),
          GoRoute(
            path: RoutePaths.workspaceTasks,
            builder: (context, state) => const WorkspaceSectionScreen(
              title: 'مهامي والإشعارات',
              subtitle:
                  'متابعة المهام المسندة والتنبيهات دون خلطها بإعدادات النظام.',
              icon: Icons.task_alt_outlined,
              items: <String>[
                'مراجعة مسودة برك سليمان',
                'استكمال مصادر سبسطية',
                'تدقيق حقبة تل السلطان',
                'متابعة مساهمة مجتمعية جديدة',
              ],
            ),
          ),
          GoRoute(
            path: RoutePaths.workspacePlaces,
            builder: (context, state) => const WorkspacePlacesScreen(),
          ),
          GoRoute(
            path: RoutePaths.workspaceSiteEditor,
            builder: (context, state) => const SiteEditorScreen(),
          ),
          GoRoute(
            path: RoutePaths.workspaceNewPlace,
            builder: (context, state) => const NewPlaceDraftScreen(),
          ),
          GoRoute(
            path: RoutePaths.workspaceNarratives,
            builder: (context, state) => const WorkspaceSectionScreen(
              title: 'الوثائق التاريخية',
              subtitle: 'تحرير الفصول والمسودات الظاهرة في صفحات المواقع.',
              icon: Icons.description_outlined,
              items: <String>[
                '47 موقعاً تحمل روايات موسعة مسودة',
                '32 موقعاً تحمل بطاقات فهرسة أولية',
                'كل الفصول تحتاج تدقيق الادعاءات والمصادر',
                'لا توجد رواية معتمدة أو منشورة',
              ],
            ),
          ),
          GoRoute(
            path: RoutePaths.workspaceClaims,
            builder: (context, state) => const ClaimWorkspaceScreen(),
          ),
          GoRoute(
            path: '/workspace/claims-legacy',
            builder: (context, state) => const WorkspaceSectionScreen(
              title: 'الادعاءات والاستشهادات',
              subtitle:
                  'تفكيك النصوص إلى ادعاءات وربط كل ادعاء بدليل قابل للتحقق.',
              icon: Icons.fact_check_outlined,
              items: <String>[
                'تفكيك روايات 47 موقعاً إلى ادعاءات',
                'ربط الادعاءات بصفحات ومقاطع أصلية',
                'عرض الروايات المتعارضة بصياغة متوازنة',
                'الادعاءات الموثقة على مستوى السجل الحالي: 0',
              ],
            ),
          ),
          GoRoute(
            path: RoutePaths.workspaceSourceRegistry,
            builder: (context, state) => const SourceRegistryWorkspaceScreen(),
          ),
          GoRoute(
            path: RoutePaths.workspaceSources,
            builder: (context, state) => const SourceRegistryWorkspaceScreen(),
          ),
          GoRoute(
            path: '/workspace/sources-legacy',
            builder: (context, state) => const WorkspaceSectionScreen(
              title: 'المصادر والأدلة',
              subtitle: 'تسجيل المراجع والحقوق ومواضع الاستشهاد قبل الاعتماد.',
              icon: Icons.library_books_outlined,
              items: <String>[
                '79 مدخلاً في سجل المصادر المسودة',
                'مطابقة العنوان والمؤلف والطبعة والصفحات',
                'الحصول على النسخ الأصلية أو الرقمية',
                'مراجعة الحقوق والتراخيص قبل الاستخدام',
              ],
            ),
          ),
          GoRoute(
            path: RoutePaths.workspaceMedia,
            builder: (context, state) => const MediaRightsScreen(),
          ),
          GoRoute(
            path: '/workspace/media-legacy',
            builder: (context, state) => const WorkspaceSectionScreen(
              title: 'الوسائط',
              subtitle:
                  'الصور والخرائط والتسجيلات المرتبطة بالمواقع ومسوداتها.',
              icon: Icons.perm_media_outlined,
              items: <String>[
                'صور حالية',
                'خرائط تاريخية',
                'تسجيلات صوتية',
                'مواد تحتاج مراجعة حقوق',
              ],
            ),
          ),
          GoRoute(
            path: RoutePaths.workspaceOralHistory,
            builder: (context, state) => const WorkspaceSectionScreen(
              title: 'الذاكرة الشفوية',
              subtitle: 'المقابلات والتفريغ والموافقات والربط بالموقع والفترة.',
              icon: Icons.record_voice_over_outlined,
              items: <String>[
                'روايات أهالي أرطاس — مسودة',
                'شهادات من سبسطية — تحتاج موافقات',
                'قائمة مقابلات مقترحة',
              ],
            ),
          ),
          GoRoute(
            path: RoutePaths.workspaceMapEditor,
            builder: (context, state) => const GisReviewScreen(),
          ),
          GoRoute(
            path: RoutePaths.workspaceRelationships,
            builder: (context, state) => const RelationshipsWorkspaceScreen(),
          ),
          GoRoute(
            path: '/workspace/map-editor-legacy',
            builder: (context, state) => const WorkspaceSectionScreen(
              title: 'محرر الخريطة',
              subtitle:
                  'مراجعة الإحداثيات والهندسات والطبقات دون كتابة حية حالياً.',
              icon: Icons.edit_location_alt_outlined,
              items: <String>[
                '3 مواقع لها إحداثيات قابلة للمراجعة',
                '76 موقعاً في سجل فجوات الإحداثيات',
                'عدم إنشاء أي موضع جغرافي بالتخمين',
                'مراجعة المحافظة والبلدة قبل اعتماد النقطة',
              ],
            ),
          ),
          GoRoute(
            path: RoutePaths.workspaceGeography,
            builder: (context, state) => const WorkspaceSectionScreen(
              title: 'المحافظات والأسماء',
              subtitle: 'المرجع المكاني للأسماء الحالية والتاريخية والمحلية.',
              icon: Icons.location_city_outlined,
              items: <String>[
                '16 محافظة في سجل التغطية',
                'شمال غزة ودير البلح: فجوتا استخراج معلنتان',
                'المدن والبلدات والأسماء التاريخية',
                'العلاقات المكانية تحتاج مراجعة جغرافية',
              ],
            ),
          ),
          GoRoute(
            path: RoutePaths.workspaceContributions,
            builder: (context, state) => const WorkspaceSectionScreen(
              title: 'المساهمات والبلاغات',
              subtitle: 'فرز الاقتراحات والصور والتصحيحات وبلاغات الأضرار.',
              icon: Icons.volunteer_activism_outlined,
              items: <String>[
                'اقتراح موقع جديد',
                'تصحيح اسم تاريخي',
                'صورة تحتاج مراجعة حقوق',
                'بلاغ ضرر ميداني',
              ],
            ),
          ),
          GoRoute(
            path: RoutePaths.workspaceReviews,
            builder: (context, state) => const ReviewQueueScreen(),
          ),
          GoRoute(
            path: '/workspace/reviews-legacy',
            builder: (context, state) => const WorkspaceSectionScreen(
              title: 'قائمة المراجعة',
              subtitle: 'التدقيق التاريخي والتحريري ومراجعة المصادر والحقوق.',
              icon: Icons.rate_review_outlined,
              items: <String>[
                'مسودة برك سليمان — تدقيق تاريخي',
                'سبسطية — مراجعة مصادر',
                'تل السلطان — مراجعة تحريرية',
              ],
            ),
          ),
          GoRoute(
            path: RoutePaths.workspaceReleaseControl,
            builder: (context, state) => const ReleaseControlScreen(),
          ),
          GoRoute(
            path: RoutePaths.workspaceAudit,
            builder: (context, state) => const AuditLogScreen(),
          ),
          GoRoute(
            path: RoutePaths.workspacePublication,
            builder: (context, state) => const ReleaseControlScreen(),
          ),
          GoRoute(
            path: '/workspace/publication-legacy',
            builder: (context, state) => const WorkspaceSectionScreen(
              title: 'النشر والجودة',
              subtitle:
                  'بوابة داخلية؛ لا نشر تلقائياً قبل اكتمال جميع المراجعات.',
              icon: Icons.publish_outlined,
              items: <String>[
                'جاهزية الادعاءات',
                'جاهزية الحقوق',
                'جاهزية الخريطة',
                'قرار الاعتماد',
              ],
            ),
          ),
          GoRoute(
            path: RoutePaths.workspaceReports,
            builder: (context, state) => const WorkspaceSectionScreen(
              title: 'التقارير وفجوات التوثيق',
              subtitle: 'قياس اكتمال الفصول والمصادر والوسائط والمراجعات.',
              icon: Icons.analytics_outlined,
              items: <String>[
                '76 موقعاً تحتاج إحداثيات',
                '79 مدخل مصدر يحتاج تحققاً ببليوغرافياً',
                '32 موقعاً بلا رواية موسعة',
                'محافظتان بلا صفوف مواقع مستخرجة',
                '79 موقعاً تحتاج تقييماً ميدانياً للحفظ',
              ],
            ),
          ),
          GoRoute(
            path: RoutePaths.governance,
            builder: (context, state) => const GovernanceOverviewScreen(),
          ),
          GoRoute(
            path: RoutePaths.governanceWorkflows,
            builder: (context, state) => const WorkspaceSectionScreen(
              title: 'سياسات سير العمل',
              subtitle:
                  'حالات المسودة والتدقيق والاعتماد والنشر في صفحة فرعية.',
              icon: Icons.account_tree_outlined,
              items: <String>[
                'مسودة',
                'مراجعة المصادر',
                'تدقيق تاريخي',
                'مراجعة تحريرية',
                'مراجعة الحقوق',
                'اعتماد',
                'نشر',
              ],
            ),
          ),
          GoRoute(
            path: RoutePaths.governanceRights,
            builder: (context, state) => const WorkspaceSectionScreen(
              title: 'الحقوق والتراخيص',
              subtitle: 'قواعد الملفات والصور والتسجيلات والاقتباسات المقيدة.',
              icon: Icons.gavel_outlined,
              items: <String>[
                'ملكية عامة',
                'ترخيص مفتوح',
                'استخدام داخلي',
                'إذن ممنوح',
                'مقيد',
              ],
            ),
          ),
          GoRoute(
            path: RoutePaths.governanceAudit,
            builder: (context, state) => const WorkspaceSectionScreen(
              title: 'سجل التدقيق',
              subtitle:
                  'سجل داخلي للإصدارات والقرارات؛ غير ظاهر في الموقع العام.',
              icon: Icons.history_outlined,
              items: <String>[
                'إنشاء المسودة',
                'ربط مصدر',
                'قرار مراجعة',
                'تغيير حالة',
                'اعتماد إصدار',
              ],
            ),
          ),
          GoRoute(
            path: RoutePaths.governanceSystemStatus,
            builder: (context, state) => const SystemStatusScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.legacyResearch,
        redirect: (context, state) => RoutePaths.workspace,
      ),
      GoRoute(
        path: RoutePaths.legacyAdmin,
        redirect: (context, state) => RoutePaths.governance,
      ),
    ],
  ),
);
