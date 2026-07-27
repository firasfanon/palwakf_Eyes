class GovernedResearchBacklogItem {
  const GovernedResearchBacklogItem({
    required this.id,
    required this.claimId,
    required this.siteId,
    required this.siteNameAr,
    required this.governorateAr,
    required this.claimText,
    required this.priorityTier,
    required this.priorityScore,
    required this.researchStatus,
    required this.categories,
    required this.requiredMethods,
    required this.requiresLiveWebRefresh,
    required this.requiresFieldEvidence,
  });

  final String id;
  final String claimId;
  final String siteId;
  final String siteNameAr;
  final String governorateAr;
  final String claimText;
  final String priorityTier;
  final int priorityScore;
  final String researchStatus;
  final List<String> categories;
  final List<String> requiredMethods;
  final bool requiresLiveWebRefresh;
  final bool requiresFieldEvidence;
}
