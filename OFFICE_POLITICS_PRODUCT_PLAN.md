# Office Politics Product Plan

## Product position and safety boundary

Build a confidential workplace coaching app centered on defensive next-move prediction. Given a colleague’s email and a proposed reply, the app will simulate how that colleague may respond, how the situation may branch, what warning signals to watch for, and which reply best protects the user’s stated goals. Prediction is essential, but conditional rather than certain because the app cannot directly know another person’s private thoughts.

The core `next_move_simulator` will:
- Compare response choices such as reply A/B/C or “do not reply yet.”
- Use the colleague profile, directional relationships, past events, organizational context, current message, and relevant macro signals.
- Return two to four plausible response branches for each option: predicted reaction, rationale, early indicators, benefit, harm/risk, reversibility, and a safe follow-up.
- Label assumptions and confidence, show evidence that could change the prediction, and let the user record the actual outcome so future predictions can be evaluated and improved.
- Rank options against explicit user goals such as avoiding blame, preserving evidence, de-escalating, maintaining reputation, or seeking clarification.

The app will not recommend proactive harm, retaliation, sabotage, deception, threats, rumor campaigns, unlawful surveillance, or manufactured evidence. It may explain an adversarial possibility when needed for self-protection and recommend proportionate defensive action.

Success means helping users clarify facts, reduce avoidable conflict, prepare effective communication, document events, and recognize when HR, a union, counsel, a regulator, emergency support, or clinical support is appropriate.

## Research foundation

Create the library from available internet material after plan approval. An LLM can read permitted source material and produce original structured summaries, but summarization does not automatically make unauthorized acquisition or commercial reuse lawful. The ingestion process must respect paywalls, site terms, `robots.txt`, API rules, transcript availability, and licenses.

Library pipeline:
1. Discover sources through Perplexity/Search APIs, RSS feeds, scholarly indexes, regulator sites, approved YouTube metadata/transcripts, and manual editorial research.
2. Fetch only public, licensed, API-accessible, or otherwise permitted content; store source URL, author/publisher, date, access method, license/terms note, and content hash.
3. Use an LLM to extract events, actors, tactics, observable signals, possible motives, counter-explanations, outcomes, and lessons. Do not store or publish full source text.
4. Run a second-pass verifier against the source to detect invented facts, quote errors, and unsupported conclusions.
5. Store an original structured scenario summary with short quotations only when legally permitted and necessary.
6. Assign evidence tier, jurisdiction, culture, industry, source type, and review date; flag anecdotes as unverified.
7. Require editorial approval before a card becomes production-visible, and periodically refresh or retire stale cards.

Each scenario card will contain: pattern, actors, timeline, observable signals, alternative explanations, power dynamics, action/response branches, common mistakes, actual outcome, evidence-backed responses, escalation thresholds, jurisdiction caveats, citations, evidence tier, and review date. Target the first production corpus at approximately 100 scenario cards across the initial categories and 30 deeper documented case studies.

Initial coverage:
- Credit theft, information hoarding, exclusion, gossip, scapegoating, favoritism, coalition building, passive aggression, manager manipulation, promotion/reorg rivalry, performance reviews, hybrid-work proximity bias, layoffs, whistleblowing/retaliation, harassment/discrimination boundaries, and cross-cultural misunderstandings.
- Documented cases such as [Susan Fowler’s Uber account](https://www.susanjfowler.com/blog/2017/2/19/reflecting-on-one-very-strange-year-at-uber), the [Uber Holder report](https://s3.documentcloud.org/documents/3863782/The-Holder-Report-on-Uber.pdf), the [Trip.com hybrid-work randomized trial](https://www.nature.com/articles/s41586-024-07500-2), and regulator guidance from [EEOC](https://www.eeoc.gov/harassment), [Acas](https://www.acas.org.uk/bullying-at-work), and [OSHA](https://www.whistleblowers.gov/faq).
- Evidence anchors including the [organizational-politics meta-analysis](https://doi.org/10.5465/amj.2009.43670894), [psychological-safety research](https://www.hbs.edu/faculty/Pages/item.aspx?num=2959&t=research), and [NIST’s generative-AI risk profile](https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.600-1.pdf).
- Anecdotal sources such as Ask a Manager and Workplace Stack Exchange only for scenario diversity; label them unverified and never treat popularity as proof.
- Talks from [Amy Edmondson](https://www.youtube.com/watch?v=LhoLuui9gX8), [Margaret Heffernan](https://www.youtube.com/watch?v=PY_kd46RfVE), and [Jeffrey Pfeffer](https://www.youtube.com/watch?v=AozJ4AkgAMw) as practitioner material, clearly separated from peer-reviewed evidence.

Maintain the ingestion policy and source manifest under [knowledge/README.md](knowledge/README.md), source metadata under [knowledge/sources/](knowledge/sources/), reviewable scenario records under [knowledge/scenarios/](knowledge/scenarios/), and ingestion/evaluation jobs under [tools/knowledge_pipeline/](tools/knowledge_pipeline/). Publish only structured summaries and permitted short quotations, not copied articles or transcripts.

## Referenced motto library

Create approximately 60 multilingual motto cards under [knowledge/mottos/](knowledge/mottos/). Each card includes the original wording where a verified public-domain or licensed translation is available, author/work/chapter, source URL, translation/license, a plain-language interpretation, appropriate office context, misuse warning, and localized paraphrases.

Prioritize conflict-avoidance, preparation, self-knowledge, evidence, restraint, reputation, and giving others a face-saving exit. Sources can include verified public-domain translations of Sun Tzu, Machiavelli, Marcus Aurelius, Aesop, Shakespeare, and historical proverbs, plus short properly attributed quotations from modern research where licensing permits. Do not use quote-aggregation sites as the authority, and do not present aggressive historical advice without a modern defensive interpretation.

## Competitive direction

Closest products found are [Tough Day](https://tough.day/product) for confidential workplace advice, [Breakthru](https://thebreakthru.ai/) for persistent stakeholder profiles and roleplay, [OOFmode](https://www.oofmode.com/) for political-risk/email analysis, [StakeWise AI](https://www.stakewise.ai/) for relationship mapping, and [Peopling](https://www.peopling.app/) / [Yoodli](https://yoodli.ai/use-cases/crucial-conversations) for conversation rehearsal.

Differentiate by combining:
- Persistent person, relationship, event, claim, and evidence records.
- A visual office layout linked to characters and relationship context.
- A cartoon colleague face lab and a hyperactive arcade layer on a fictional office floor, with daily/weekly/monthly contests that can unlock a subscription pass.
- A counterfactual next-move simulator that compares the likely branches caused by different user replies.
- Evidence/uncertainty-aware scenario analysis rather than unsupported “hidden agenda” certainty.
- On-device OCR and short-form dictation, multilingual from launch.
- Roleplay personalized from the user’s records.
- Industry and macro-intelligence signals connected to likely internal pressure and behavior changes.
- A contextual, referenced motto library.
- Explicit retention, redaction, provenance, export, and deletion controls.

## MVP experience

1. Onboarding: choose English, Simplified Chinese, or Traditional Chinese; show the one-time sensitive-data warning and explain AI limitations; create an account; choose retention settings. Before the first third-party AI transmission, explicitly name the provider, explain what data will be sent and why, collect revocable consent, and then remember that choice.
2. Workspace setup: define the user’s role, organization context, goals, constraints, reporting structure, and preferred pseudonyms.
3. Character setup: collect display name/pseudonym, role/title, team, seniority, reporting line, decision authority, resource control, communication style, incentives/goals as perceived by the user, known constraints, trust history, interaction frequency, and neutral free-text notes. Include a parametric cartoon **face lab** (head, hair, brows, eyes, mouth, office accessories, signature expression) so the colleague can appear on the private map and in arcade games. Do not store a “hated” flag on the profile. The AI returns a concise editable summary and marks interpretations as user-reported.
4. Relationship setup: directional relationship for each relevant pair—not every mathematical pair by default—with work dependency, authority, influence channel, cooperation/conflict history, communication frequency, trust level, recent trend, key evidence, and user uncertainty. Avoid fixed “enemy/loyalty” scores.
5. Event journal: date/time, participants, location/channel, exact words/actions, business context, impact, witnesses, commitments, linked artifacts, user response, follow-up, and status. Preserve source and revisions separately from AI summaries.
6. Ask for advice: typed text, selected people/events, OCR import, or dictation. Return neutral restatement, observations, unknowns, alternative hypotheses, evidence for/against, likely next moves as scenarios, low-risk options, scripts, escalation considerations, and confidence rationale.
7. Office map: drag desks, partitions, doors, meeting rooms, labels, and character seats on a zoomable 2D canvas; tap a character to open their profile/timeline; optionally visualize selected relationships without turning the office into an “enemy board.”
8. Roleplay: select a person, goal, tone, and difficulty; practice a conversation; receive feedback on clarity, evidence, boundary-setting, and escalation risk.
9. Reply simulator: paste or OCR an incoming email, draft multiple replies, compare predicted colleague responses and harm/risk branches, choose one, and later record the real outcome.
10. Business outlook: define the employer’s industry, countries, business lines, competitors, and exposure factors; receive cited macro trend summaries and see which assumptions were used in advice.
11. Motto cards: show a sourced motto that matches the current lesson, with interpretation and an option to browse/save favorites.
12. Arcade contests: joystick movement on a fictional office floor; play Slap Desk plus Credit Chase, Rumour Flip, and 5pm Ghost; optional rewarded-ad continues; daily/weekly/monthly skill contests that can grant a time-limited premium pass.

Defer employer dashboards, coworker recording, passive monitoring, automatic email-account ingestion, cross-user social graphs, and organization-wide analytics.

## Arcade contests and hyperactive mini-games

The coaching product stays subscription-gated. Arcade contests are a separate public layer: play free, watch rewarded ads for in-game help, win a time-limited premium pass, or subscribe. Contests are skill-based, not lotteries.

Use a **fictional contest floor**, never the user’s real office layout, real names, private notes, or relationship scores. Cartoon avatars only. Photoreal photos, face-from-photo, and share cards that identify a real colleague are out of scope. Leaderboards show score and a generic office, not who was slapped or set against whom.

Arcade fantasy is not coaching. Advice, roleplay, and the reply simulator must never recommend slap, rumor-sparking, trapping colleagues, or skipping work as a real next move. After slap or fight animations, keep a short line that this is fiction.

Joystick: virtual stick to dash. Primary action button for slap / reclaim / confirm. One-finger swipe or flick for Rumour Flip. Hit-stop, squash-and-stretch faces, and high spawn rates. Daily 60–90s, weekly 5–8 min variant, monthly multi-floor rush.

Rewarded ads buy continues, a few extra seconds, slow-mo, or one reveal of a patrol/vision cone. Cap ads per run. Do not punish ad use on the leaderboard. Advertising SDKs are allowed only in this arcade module, never on case files, OCR, or advice screens.

### Slap Desk

Must-have catharsis mode. Dash on the floor and slap the session target’s cartoon head as it pops over cubicles, kitchen glass, and meeting-room doors. Wrong-person slaps break combo. Score from target slaps, max combo, and leftover time.

### Credit Chase

Colleagues wander an obstacle-filled area. Each carries stolen credit tokens (slides, ideas, numbers) floating above them. The user traces a thief, closes into tag range, and yanks the credit back with the action button (slap or grab). A reclaimed token flies to the user; if missed, another thief can snatch it. Score equals credits taken back, plus leftover time. Weekly variant: credits bounce between thieves; monthly: a vacuum boss that steals from the user unless stunned.

### Rumour Flip

Rumour speech bubbles spawn above walking pairs. The user dashes to a bubble and uses a flick/swipe gesture to peel the polite rumour and leave the **honest subtext** (cartoon “what they actually think of the listener”). The listener hears that line, gets mad, and the pair enters a short cartoon fight. Each fight scores. Hitting the wrong bubble, flipping onto an innocent, or letting a rumour reach the skip-level without a flip costs points. Honest lines and fights are generated arcade fiction, never the user’s private notes about real people.

### 5pm Ghost

A few colleagues wander slowly among desks, plants, and partitions. Each has a forward pie-slice vision cone (field of view). If the cone overlaps the user, the user is discovered and dragged into a 5pm “quick sync” (round fail or life lost). The user must stay out of cones, use obstacles as cover, and reach the exit. Score from successful escape, leftover time, and near-miss bonuses. Weekly: extra wanderers and moving doors. Monthly: lights dim and cones lengthen after 5pm.

| Contest | Length | Prize |
|---|---|---|
| Daily | 60–90s, one of the four modes | 24 hours of premium |
| Weekly | longer map, same mode all week | 7 days |
| Monthly | multi-floor mix of the four modes | 1 month |

## Architecture and storage

Use Flutter with feature-first modules under [lib/features/](lib/features/), Riverpod for state management, GoRouter for navigation, and immutable generated models. Use responsive layouts for iOS and Android and Flutter localization through ARB files in [lib/l10n/](lib/l10n/).

Because cloud accounts are required, use:
- Supabase Auth, PostgreSQL, Row Level Security, Storage, and `pgvector`.
- A thin backend/edge API for authentication, authorization, redaction, provider routing, token/cost limits, and API secrets. Never include DeepSeek or Perplexity keys in the app.
- Encrypted Drift/SQLite as a device cache/outbox for offline drafts and resilient sync; cloud PostgreSQL remains authoritative.
- UUIDs, version columns, tombstones, idempotent writes, and explicit conflict handling.
- Keychain/Keystore via `flutter_secure_storage`; TLS in transit; short-lived signed artifact URLs; tenant-scoped object paths.

Core tables defined through [supabase/migrations/](supabase/migrations/): `profiles`, `workspaces`, `people`, `relationships`, `events`, `event_participants`, `artifacts`, `claims`, `hypotheses`, `goals`, `advice_sessions`, `messages`, `predictions`, `prediction_branches`, `actual_outcomes`, `source_chunks`, `scenario_cards`, `motto_cards`, `industry_profiles`, `macro_sources`, `macro_signals`, `macro_reports`, `office_layouts`, `office_objects`, `consents`, and `audit_events`. Relationships are directional; events are append-only with linked corrections; claims have `reported/corroborated/disputed/unknown` status and provenance.

Apply RLS to every user table. Implement complete account export/deletion, retention jobs for raw artifacts, deletion of derived OCR/transcripts/embeddings, and minimal content-free operational logs. Advertising SDKs load only inside the arcade contest module, never on case files, OCR, or advice screens.

## OCR and voice

Use this in-app image-recognition path:
1. Capture with `camera`/`image_picker` or select an existing screenshot.
2. Crop, rotate, deskew, and improve contrast locally.
3. Run `google_mlkit_text_recognition` on-device with Latin and Chinese script support; retain line/word bounding boxes and confidence.
4. Reconstruct email headers, quoted replies, paragraphs, and reading order; let the user select the relevant region.
5. Show editable extracted text beside the image so the user can correct OCR mistakes and remove irrelevant content.
6. Send extracted text—not the original image—to the AI gateway by default. Upload the original only if a later vision model is explicitly selected and consented to.
7. Keep the original image only when the user explicitly chooses to save it.

Use `speech_to_text` over iOS Speech and Android SpeechRecognizer for short dictation, preferring on-device recognition where the OS supports the selected locale:
- Legacy `SFSpeechRecognizer` should be designed around approximately 60 seconds per recognition task. On iOS 26+, evaluate Apple `SpeechAnalyzer`, which supports long-form transcription but requires a native bridge and newer devices/OS.
- Android exposes no dependable universal second limit; the installed recognition service normally ends after silence and is explicitly not intended for continuous recognition. Device/vendor behavior varies.
- Set the MVP’s predictable UI cap to 55 seconds per note on both platforms, display a countdown, and allow immediate continuation into another segment.

Do not record meetings in the MVP. Evaluate Apple `SpeechAnalyzer`, on-device Whisper, or a cloud transcription service later if long-form transcription is required and model size, battery, heat, latency, consent, and cost are acceptable.

Required language QA covers UI, OCR, speech locale availability, AI output, Traditional/Simplified script consistency, and mixed English/Chinese office terminology.

## AI provider strategy and prompts

Use a provider-agnostic backend interface in [supabase/functions/ai-gateway/](supabase/functions/ai-gateway/):
- DeepSeek for high-volume structured extraction, summaries, counterfactual branch generation, drafting, and roleplay after the required first-transmission disclosure/consent.
- Perplexity for current web research, cited macro intelligence, source discovery, and research-library refreshes; do not send private case history when a de-identified industry query is sufficient.
- Keep model allowlists, context limits, prices, timeout policy, and kill switches in server configuration.

Use both initially, behind one interface, because their jobs differ—not because Perplexity is incapable of ordinary LLM work. Perplexity Sonar includes web grounding/citations but adds search/request cost and web material is unnecessary for most private-case turns. DeepSeek is suitable for lower-cost repeated summarization/simulation but has a materially different privacy posture. A Perplexity-only pilot remains possible: benchmark advice quality, latency, multilingual output, JSON reliability, privacy terms, and cost, then retain one or both providers based on measured results. Avoid coupling any product feature directly to one vendor.

DeepSeek’s hosted privacy policy says personal data may be stored in China and describes model optimization/training uses. Perplexity’s API advertises zero content retention, but user consent does not remove employer-policy or third-party privacy obligations. The onboarding warning will tell users not to upload confidential or sensitive material and to use fake colleague names. The app will trust that attestation and will not ask authorization on every image. However, it must still obtain explicit, revocable consent before the first transmission of personal data to each named AI provider because [Apple App Review Guideline 5.1.2](https://developer.apple.com/app-store/review/guidelines/) requires it. Credentials and obvious secrets should still trigger a local warning rather than be silently transmitted.

Version prompts in [supabase/functions/_shared/prompts/](supabase/functions/_shared/prompts/):
- `intake_extractor`: convert user input/OCR/transcript into observations, claims, people, dates, commitments, unknowns, and sensitive-data flags without inferring motives.
- `character_summarizer`: produce a short editable profile separating stated facts, user impressions, evidence, and unknowns.
- `case_compactor`: maintain durable facts, unresolved questions, goals, relationship changes, and provenance while never converting repetition into verification.
- `next_move_simulator`: compare draft replies; predict conditional response branches, likely organizational consequences, warning indicators, harm/risk, reversibility, and follow-up moves; optimize against the user’s goals without recommending proactive harm.
- `advisor`: synthesize simulator results into a recommended reply/action, alternatives, evidence for/against, and escalation guidance.
- `roleplay_actor` and `roleplay_coach`: simulate only traits grounded in the selected profile, then assess the user’s response.
- `safety_classifier`: detect credentials/secrets, covert surveillance, proactive harm/retaliation, threats, self-harm/harm, harassment/discrimination, legal deadlines, and fixed persecutory certainty; route to a safe response.
- `localizer`: preserve meaning and safety language across English, Simplified Chinese, and Traditional Chinese.

Require structured JSON outputs validated server-side. Store prompt version, model, selected record IDs, source provenance, and safety route for reproducibility without logging full prompt content.

## Macro business intelligence

Implement a scheduled backend pipeline under [supabase/functions/macro-intelligence/](supabase/functions/macro-intelligence/) instead of making the mobile app scrape arbitrary sites:
- Users define employer industry, operating countries, business model, major products, customer segments, competitors, regulation exposure, and optional public company/ticker.
- Daily source discovery and weekly synthesis use Perplexity/Search APIs, permitted RSS/API feeds, regulator/statistics sources, company filings, earnings releases, and reputable news metadata.
- Every signal stores source, publication date, geography, affected business factor, confidence, time horizon, and expiry date.
- The LLM converts trends into conditional internal-pressure hypotheses, such as “weaker travel demand may increase budget scrutiny,” never “this executive will definitely cut this team.”
- Advice receives only the most relevant, current signals. Users can inspect citations, disable a source, correct their industry profile, and see when macro context changed a prediction.
- Cache and deduplicate results by industry/region to control cost. Do not bypass paywalls or republish full articles.

## Token and retrieval policy

Do not send all records on every request. Build context in priority order:
1. Safety/system policy and response schema.
2. Current user question and explicit goal.
3. Selected people/events/artifacts.
4. Compact workspace and case summaries.
5. Top relevant event/source chunks from hybrid metadata plus vector retrieval.
6. A small number of applicable scenario cards.

Use a model registry to calculate exact limits. For normal advice, target a 16K-token request envelope even if a model supports much more: roughly 2K system/safety, 2K current request, 4K structured case state, 5K retrieved evidence/scenarios, 1K response instructions, and up to 2K output. Reserve at least 15% headroom; trim low-priority retrieval first; reject or summarize oversized OCR imports before advice generation. Rebuild compact summaries periodically from source records to reduce summary drift, and always retain provenance links to the original record.

## User-visible AI limitations

Explain these plainly during onboarding and keep a shorter version near advice:
- The model sees only what the user provides; an email or event may omit decisive context.
- It cannot read minds or guarantee what another person will do. Predictions are conditional scenarios, not facts.
- OCR and speech can misread names, numbers, negation, tone, speaker identity, and message boundaries; users must review extracted text.
- LLMs can hallucinate, misunderstand sarcasm/culture, overgeneralize, or produce inconsistent advice.
- Web and macro data can be stale, incorrect, regionally irrelevant, or based on reporting rather than confirmed facts.
- Summaries and token limits compress history and can omit details; source records remain available for review.
- Advice is not legal, HR, medical, mental-health, or emergency-professional advice, and local rules differ.
- Third-party AI processing creates privacy exposure described in the consent screen and privacy policy.

## Trust, legal, and release controls

- At first use, warn users not to upload confidential or sensitive material and recommend fake names/pseudonyms for colleagues.
- Before first use of each cloud AI provider, obtain the required provider-specific, revocable data-sharing consent; do not repeat the prompt for every upload unless the provider or purpose changes.
- Provide optional local redaction/editing before submission and a mandatory OCR correction preview. Trust the user’s attestation for ordinary workplace content, while warning on obvious credentials/secrets.
- Never promise legal outcomes or certainty about another person’s response.
- Present location-aware escalation resources, but launch content should undergo employment-law and privacy review for each distributed region.
- Use multiple hypotheses and counterevidence to avoid reinforcing paranoia; pause recursive “threat analysis” when it increases distress.
- Add threat, self-harm/harm, discrimination, retaliation, and whistleblowing flows with qualified-human escalation.
- Complete privacy impact assessment, threat model, abuse tests, prompt-injection tests on imported content, localization review, accessibility testing, App Store privacy labels, Google Play Data Safety, and account-deletion compliance before release.

## Delivery phases

1. Foundation: Flutter project, localization, design system, auth, RLS schema, encrypted cache/sync, settings, export/delete.
2. Case model: people, directional relationships, events, artifacts, claims, timelines, and search.
3. AI gateway and prediction engine: provider abstraction, structured prompts, counterfactual branch simulation, token budgeting, safety routing, telemetry, and cost controls.
4. Input tools: on-device OCR and short dictation with permissions, preview, correction, and retention controls.
5. Advice and roleplay: reply comparison, predicted response branches, scripts, citations/provenance, outcome feedback, and multilingual QA.
6. Office map: editable 2D floor plan, persisted geometry, character selection, cartoon face lab, accessibility alternative, and performance tests.
7. Arcade contests: fictional floor, joystick, Slap Desk, Credit Chase, Rumour Flip, 5pm Ghost, rewarded-ad continues, and contest pass grants.
8. Knowledge and motto corpus: run the permitted-source ingestion pipeline, verify summaries, complete editorial review, and ship the initial referenced cards.
9. Macro intelligence: industry profiles, scheduled source discovery, signal extraction, cited weekly reports, relevance/expiry, and prediction integration.
10. Evaluation: anonymized synthetic cases and expert scoring for branch plausibility, calibration, factual grounding, action safety, cultural sensitivity, and escalation accuracy; compare predictions against user-recorded outcomes without training on them unless separately consented.
11. Production readiness: security/privacy/legal review, provider contracts, abuse and load tests, store disclosures, observability, backups, disaster recovery, and staged beta.

## Acceptance criteria for MVP

- Users can create an account, set one of three languages, create/edit/delete/export a workspace, people, cartoon face-lab avatars, directional relationships, events, and an office layout.
- Arcade contests run on a fictional floor with joystick movement: Slap Desk, Credit Chase (score = reclaimed credits), Rumour Flip (score = cartoon fights after an honest-speech flick), and 5pm Ghost (dodge vision cones and exit). Coaching flows never treat those actions as recommended workplace moves.
- OCR and 55-second segmented dictation work without sending raw media to the AI provider; users review and correct extracted text first.
- The reply simulator compares at least two user options, returns two to four conditional colleague-response branches per option, explains evidence/assumptions, ranks defensive choices against user goals, and records actual outcomes.
- Advice references only selected/retrieved records and current cited macro signals, distinguishes facts from interpretations, includes uncertainty, and never exceeds configured token/cost limits.
- The initial reviewed knowledge base contains approximately 100 scenario cards, 30 deeper case studies, and 60 referenced motto cards without copied full articles/transcripts.
- Every cloud record is protected by tested RLS; API keys are server-side; account deletion removes originals and derived data according to the published retention schedule.
- English, Simplified Chinese, and Traditional Chinese pass functional, prediction, safety, OCR, speech, and localization QA on representative iOS and Android devices.
