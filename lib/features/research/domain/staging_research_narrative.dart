import 'dart:convert';

const String researchNarrativeSidecarSchemaV1 =
    'PAL_EYES_RESEARCH_NARRATIVE_SIDECAR_V1';

enum ResearchNarrativeBlockStyle {
  title,
  subtitle,
  heading1,
  heading2,
  heading3,
  normal,
}

class ResearchNarrativeBlock {
  const ResearchNarrativeBlock({required this.style, required this.text});

  factory ResearchNarrativeBlock.fromJson(Map<String, Object?> json) {
    final rawStyle = (json['style'] as String? ?? 'NORMAL_TEXT').trim();
    final text = (json['text'] as String? ?? '').trim();
    if (text.isEmpty) {
      throw const FormatException('Narrative block text must not be empty.');
    }
    return ResearchNarrativeBlock(
      style: _blockStyleFromNamedStyle(rawStyle),
      text: text,
    );
  }

  final ResearchNarrativeBlockStyle style;
  final String text;
}

class ResearchNarrativeDocument {
  const ResearchNarrativeDocument({
    required this.packageId,
    required this.censusRecordId,
    required this.catalogSiteId,
    required this.sourceDocumentId,
    required this.sourceRevisionId,
    required this.sourceTitle,
    required this.contentSha256,
    required this.blocks,
  });

  factory ResearchNarrativeDocument.fromJson(Map<String, Object?> json) {
    String requiredString(String key) {
      final value = (json[key] as String? ?? '').trim();
      if (value.isEmpty) {
        throw FormatException(
          'Narrative document field $key must not be empty.',
        );
      }
      return value;
    }

    final rawBlocks = json['blocks'];
    if (rawBlocks is! List<Object?> || rawBlocks.isEmpty) {
      throw const FormatException(
        'Narrative document blocks must not be empty.',
      );
    }

    return ResearchNarrativeDocument(
      packageId: requiredString('packageId'),
      censusRecordId: requiredString('censusRecordId'),
      catalogSiteId: requiredString('catalogSiteId'),
      sourceDocumentId: requiredString('sourceDocumentId'),
      sourceRevisionId: requiredString('sourceRevisionId'),
      sourceTitle: requiredString('sourceTitle'),
      contentSha256: requiredString('contentSha256'),
      blocks: rawBlocks
          .map(
            (block) => ResearchNarrativeBlock.fromJson(
              Map<String, Object?>.from(block! as Map),
            ),
          )
          .toList(growable: false),
    );
  }

  final String packageId;
  final String censusRecordId;
  final String catalogSiteId;
  final String sourceDocumentId;
  final String sourceRevisionId;
  final String sourceTitle;
  final String contentSha256;
  final List<ResearchNarrativeBlock> blocks;
}

class ResearchNarrativeSidecar {
  const ResearchNarrativeSidecar({required this.documents});
  factory ResearchNarrativeSidecar.fromJsonString(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Narrative sidecar root must be an object.');
    }
    if (decoded['schema'] != researchNarrativeSidecarSchemaV1) {
      throw const FormatException('Unsupported narrative sidecar schema.');
    }
    final rawDocuments = decoded['documents'];
    if (rawDocuments is! List<Object?>) {
      throw const FormatException(
        'Narrative sidecar documents must be a list.',
      );
    }
    final documents = rawDocuments
        .map(
          (item) => ResearchNarrativeDocument.fromJson(
            Map<String, Object?>.from(item! as Map),
          ),
        )
        .toList(growable: false);
    final siteIds = documents.map((item) => item.catalogSiteId).toSet();
    if (siteIds.length != documents.length) {
      throw const FormatException(
        'Narrative sidecar contains duplicate site ids.',
      );
    }
    return ResearchNarrativeSidecar(documents: documents);
  }

  final List<ResearchNarrativeDocument> documents;

  ResearchNarrativeDocument? bySiteId(String siteId) {
    for (final document in documents) {
      if (document.catalogSiteId == siteId) return document;
    }
    return null;
  }
}

ResearchNarrativeBlockStyle _blockStyleFromNamedStyle(String rawStyle) {
  switch (rawStyle.toUpperCase()) {
    case 'TITLE':
      return ResearchNarrativeBlockStyle.title;
    case 'SUBTITLE':
      return ResearchNarrativeBlockStyle.subtitle;
    case 'HEADING_1':
      return ResearchNarrativeBlockStyle.heading1;
    case 'HEADING_2':
      return ResearchNarrativeBlockStyle.heading2;
    case 'HEADING_3':
      return ResearchNarrativeBlockStyle.heading3;
    default:
      return ResearchNarrativeBlockStyle.normal;
  }
}
