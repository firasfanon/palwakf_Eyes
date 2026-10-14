# PAL_EYES governed research normalization

This offline-only utility converts the canonical 79-site and 79-source seed files into an **unpublished review graph**:
47 narratives, their sections and paragraphs, 79 draft research-package references, and source–site mention links.

Run (from the repository root):

```powershell
python tools/research_normalization/test_normalize.py
python tools/research_normalization/normalize.py --out "<authorized local runtime cache>/normalized_review_only.json"
```

The output is **not** publication data and must not be deployed to the anonymous public site or committed as bulk research text. Its links are explicitly `UNVERIFIED_SOURCE_MENTION` with `PENDING_HUMAN_REVIEW` status, not proof of historical attribution. Sources lacking a site slug are recorded under `sources_pending_site_linkage`, with no invented assignments. Each narrative retains the canonical source Git blob and source path. Fingerprints of the exact two input files appear in the output. All publication controls remain blocked.

For the 11 currently unlinked source records, a separate human-review register is generated locally (never committed with research contents):

```powershell
python tools/research_normalization/review_linkage.py --out "<authorized local runtime cache>/pending_source_linkage_review.csv"
```

The register retains source IDs, original source metadata, blank candidate-site and evidence fields, and a PENDING_HUMAN_LINKAGE decision. No automatic matching or public exposure is permitted.

An authorized researcher can prepare a proposed, **still unverified** candidate in the local register. Allowed states are PENDING_HUMAN_LINKAGE (all review fields blank), EVIDENCE_SUBMITTED (canonical site ID, exact evidence locator, named reviewer), and INDEPENDENT_REVIEW_RECORDED (second distinct reviewer, decision and notes). The validator rejects metadata tampering, invalid site IDs, missing evidence and attempted publication/verification. Recorded independent review is not itself historical source verification or an authorization to write Supabase.

```powershell
python tools/research_normalization/test_review_acceptance.py
python tools/research_normalization/review_acceptance.py --register "<cache>/pending_source_linkage_review_v2.csv" --out "<cache>/editorial_evidence_validation_v2.json"
python tools/research_normalization/test_independent_audit.py
python tools/research_normalization/independent_audit.py --artifact "<cache>/normalized_review_only.json" --out "<cache>/independent_acceptance_audit_v1.json"
```

The independent read-only audit reconstructs original section text, source relationships and Git blob hashes from the two canonical seed files. It is an engineering source-integrity check, **not an independent human scholarly decision**. Research-data records and review packets remain only in the approved local cache; commit only implementation, tests and non-sensitive aggregate evidence.

This tool does not connect to Supabase, change shared schema, apply SQL migrations, alter release gates, or complete live acceptance. Its counts describe the current seed snapshot only, not verified research or staging database state. Any future database insertion requires a separate approved migration/ingestion decision and a transactionally auditable readback.
