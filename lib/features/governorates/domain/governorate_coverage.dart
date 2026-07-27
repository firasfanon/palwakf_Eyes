class GovernorateCoverage {
  const GovernorateCoverage({
    required this.nameAr,
    required this.localities,
    required this.siteCount,
    required this.expandedNarrativeCount,
    required this.mappedSiteCount,
    required this.sourceMentionCount,
  });

  final String nameAr;
  final List<String> localities;
  final int siteCount;
  final int expandedNarrativeCount;
  final int mappedSiteCount;
  final int sourceMentionCount;

  bool get hasExtractedSites => siteCount > 0;
}
