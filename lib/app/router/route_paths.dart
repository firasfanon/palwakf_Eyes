abstract final class RoutePaths {
  static const String home = '/';
  static const String discover = '/discover';
  static const String places = '/places';
  static const String placeDetail = '/places/:slug';
  static const String map = '/map';
  static const String timeline = '/timeline';
  static const String governorates = '/governorates';
  static const String stories = '/stories';
  static const String storyDetail = '/stories/:slug';
  static const String research = '/research';
  static const String researchDetail = '/research/:slug';
  static const String sources = '/sources';
  static const String contribute = '/contribute';
  static const String methodology = '/methodology';

  static const String workspace = '/workspace';
  static const String workspaceToday = '/workspace/today';
  static const String workspaceTasks = '/workspace/tasks';
  static const String workspacePlaces = '/workspace/places';
  static const String workspaceNewPlace = '/workspace/places/new';
  static const String workspaceSiteEditor = '/workspace/places/editor';
  static const String workspaceNarratives = '/workspace/narratives';
  static const String workspaceResearch = '/workspace/research';
  static const String workspaceClaims = '/workspace/claims';
  static const String workspaceSources = '/workspace/sources';
  static const String workspaceSourceRegistry = '/workspace/source-registry';
  static const String workspaceMedia = '/workspace/media';
  static const String workspaceOralHistory = '/workspace/oral-history';
  static const String workspaceMapEditor = '/workspace/map-editor';
  static const String workspaceRelationships = '/workspace/relationships';
  static const String workspaceGeography = '/workspace/geography';
  static const String workspaceContributions = '/workspace/contributions';
  static const String workspaceReviews = '/workspace/reviews';
  static const String workspacePublication = '/workspace/publication';
  static const String workspaceReleaseControl = '/workspace/release-control';
  static const String workspaceAudit = '/workspace/audit';
  static const String workspaceReports = '/workspace/reports';

  static const String admin = '/admin';
  static const String governance = '/admin/governance';
  static const String governanceWorkflows = '/admin/governance/workflows';
  static const String governanceRights = '/admin/governance/rights';
  static const String governanceAudit = '/admin/governance/audit';
  static const String governanceSystemStatus =
      '/admin/governance/system-status';

  static String place(String slug) => '/places/$slug';
  static String story(String slug) => '/stories/$slug';
  static String researchItem(String slug) => '/research/$slug';

  static const List<String> publicRoutes = <String>[
    home,
    discover,
    places,
    map,
    timeline,
    governorates,
    stories,
    research,
    sources,
    contribute,
    methodology,
  ];

  static const List<String> workspaceRoutes = <String>[
    workspace,
    workspaceToday,
    workspaceTasks,
    workspacePlaces,
    workspaceNewPlace,
    workspaceSiteEditor,
    workspaceNarratives,
    workspaceResearch,
    workspaceClaims,
    workspaceSources,
    workspaceSourceRegistry,
    workspaceMedia,
    workspaceOralHistory,
    workspaceMapEditor,
    workspaceRelationships,
    workspaceGeography,
    workspaceContributions,
    workspaceReviews,
    workspacePublication,
    workspaceReleaseControl,
    workspaceAudit,
    workspaceReports,
  ];

  static const List<String> governanceRoutes = <String>[
    governance,
    governanceWorkflows,
    governanceRights,
    governanceAudit,
    governanceSystemStatus,
  ];
}
