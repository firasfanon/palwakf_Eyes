import 'package:pal_eyes/features/places/domain/draft_content_profile.dart';
import 'package:pal_eyes/features/places/domain/historical_content.dart';

class OriginalHistoricalDraftLayer {
  const OriginalHistoricalDraftLayer({
    required this.referenceFileName,
    required this.referenceFileSha256,
    required this.referenceLineCount,
    required this.referenceSizeBytes,
    required this.summaryDraft,
    required this.periods,
    required this.narrativeSections,
    required this.sources,
    required this.timeline,
    required this.contentProfile,
    required this.sourceMentionCount,
    this.publicReleaseApproved = false,
  });

  final String referenceFileName;
  final String referenceFileSha256;
  final int referenceLineCount;
  final int referenceSizeBytes;
  final String summaryDraft;
  final List<String> periods;
  final List<HistoricalNarrativeSection> narrativeSections;
  final List<HistoricalSourceReference> sources;
  final List<HistoricalTimelineEntry> timeline;
  final DraftContentProfile contentProfile;
  final int sourceMentionCount;
  final bool publicReleaseApproved;

  bool get hasExpandedNarrative =>
      contentProfile == DraftContentProfile.expandedNarrative &&
      narrativeSections.isNotEmpty;
}
