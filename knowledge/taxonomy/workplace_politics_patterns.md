# Mandatory Workplace-Politics Pattern Taxonomy

Status: required product coverage  
Applies to: scenario cards, event journal, relationship evidence, advice, reply simulation, roleplay, and evaluations

## Classification rules

- Tags describe an event or recurring situation, never a permanent character trait.
- Keep observed facts separate from the user's interpretation and the consultant's hypothesis.
- A single record may have multiple tags.
- Every suggested tag requires supporting evidence, counter-evidence, alternatives, and confidence.
- Users can accept, reject, or edit consultant-suggested tags.
- Do not infer intent, family ties, friendships, diagnoses, or protected characteristics.
- Ordinary mistakes, disagreement, competition, and unpopular management decisions are not automatically office politics.

## Required patterns

### Coworker backstabbing

- Slug: `coworker_backstabbing`
- Role: harmful behavior pattern
- Include: concealed credit-taking, decisive information withholding, private undermining, reversal of promised support, sabotage, or blame shifting.
- Consider instead: misunderstanding, changing evidence, unclear ownership, memory failure, or legitimate confidential handling.
- Capture: promise or expectation, later action, channel, affected work, attribution evidence, witnesses, recurrence, and outcome.
- Defensive response: clarify ownership and commitments in writing, preserve evidence, ask neutral questions, reduce dependency, and escalate proportionately.

### Cronyism

- Slug: `cronyism`
- Role: unfair allocation or governance pattern
- Include: friendship- or loyalty-based preference in access, assignments, protection, evaluation, contracting, or promotion.
- Consider instead: relevant experience, trusted performance, role requirements, confidentiality, or unavailable selection evidence.
- Capture: relationship evidence, decision criteria, comparator cases, decision-maker, benefit, process deviation, and impact.
- Defensive response: request transparent criteria, document comparable results, use formal review channels, and avoid unsupported accusations.

### Interdepartmental or inter-team rivalry

- Slug: `interteam_rivalry`
- Source concept: workplace adaptation of `interservice_rivalry`
- Role: structural incentive and conflict pattern
- Include: competition over budget, headcount, ownership, information, status, metrics, or executive attention that harms shared outcomes.
- Consider instead: legitimate mandate boundaries, resource scarcity, healthy competition, or good-faith technical disagreement.
- Capture: team goals, incentives, contested resources, leadership messages, dependencies, blocked work, and organization-level impact.
- Defensive response: make shared goals and dependencies visible, establish decision rights, use joint metrics, and seek cross-team sponsorship.

### Gaming the system

- Slug: `gaming_the_system`
- Role: process or incentive exploitation pattern
- Include: manipulating metrics, loopholes, procedures, queues, reporting, or information asymmetry to gain an advantage while appearing compliant.
- Consider instead: permitted optimization, ambiguous policy, process improvement, or accidental data-quality problems.
- Context note: gaming a system can sometimes be benign resistance to a corrupt or oppressive process, so assess the goals and affected parties rather than assuming harm.
- Capture: relevant rule, observed action, metric change, beneficiary, affected party, process evidence, and repeated behavior.
- Defensive response: validate source data, expose incentive conflicts, recommend guardrails, and focus on process correction rather than retaliation.

### Nepotism

- Slug: `nepotism`
- Role: unfair allocation or governance pattern
- Include: preferential hiring, assignment, protection, evaluation, contracting, or promotion involving a verified family or kinship relationship.
- Consider instead: merit, disclosed conflict management, open competition, or an unverified assumed relationship.
- Capture: relationship provenance, disclosure, criteria, comparator cases, decision authority, benefit, and impact.
- Defensive response: use conflict-of-interest and transparent-review processes; do not speculate publicly about relationships.

### One-upmanship

- Slug: `one_upmanship`
- Role: status-competition pattern
- Include: topping, public correction, appropriation, comparison, interruption, intimidation, or diminishing behavior directed at gaining relative status or making another person feel inferior.
- Consider instead: playful competition, enthusiasm, expertise, necessary correction, cultural communication differences, or normal performance.
- Capture: repeated examples, setting, audience, relevance, impact, response, and whether behavior targets multiple people.
- Defensive response: redirect to shared outcomes, set meeting norms, claim contributions calmly, and discuss recurring impact privately when safe.

### Psychological manipulation

- Slug: `psychological_manipulation`
- Role: harmful influence pattern
- Include: documented coercive guilt, triangulation, baiting, false urgency, selective disclosure, contradictory demands, or repeated denial of verifiable events.
- Consider instead: memory differences, stress, ambiguity, changing requirements, poor communication, or ordinary persuasion.
- Capture: exact language, timeline, records, conflicting instructions, pressure, requested action, power imbalance, and impact.
- Defensive response: slow the interaction, verify in writing, ask for specific decisions, consult trusted support, and preserve boundaries.
- Safety boundary: describe behavior; never diagnose a person or state that the app knows their hidden intent.

### Workplace bullying

- Slug: `workplace_bullying`
- Role: safety and escalation pattern
- Include: repeated intimidation, humiliation, exclusion, threats, sabotage, hostile targeting, or abuse of power.
- Consider instead: proportionate performance management, isolated conflict, lawful direction, or a single rude interaction—while still acknowledging harm.
- Capture: recurrence, exact acts, dates, witnesses, power imbalance, policy, wellbeing or work impact, threats, and immediate safety.
- Defensive response: prioritize safety, documentation, trusted support, formal policy, union or professional advice, and jurisdiction-aware escalation.
- Safety boundary: never recommend retaliation, public shaming, entrapment, or escalating danger.

### Workplace democracy

- Slug: `workplace_democracy`
- Role: protective governance pattern
- Include: meaningful employee voice, consultation, representation, transparent decisions, shared governance, elected structures, and protected disagreement.
- Consider instead: symbolic consultation without influence, selective participation, opaque veto power, or retaliation after speaking.
- Capture: who participates, decision scope, information access, voting or consultation mechanism, dissent protection, accountability, and actual outcomes.
- Constructive response: strengthen safe participation, transparent criteria, representative input, feedback loops, and documented decision rights.
- Interpretation rule: this is not misconduct; assess whether it distributes power fairly and reduces political harm.

## Required product behavior

1. Event entry offers these as optional tags but never forces the user to choose one.
2. The politics consultant may suggest tags only after showing the observations that support them.
3. Advice displays alternatives and confidence before using a pattern name.
4. Character summaries aggregate linked event evidence without labeling a person as a “bully,” “manipulator,” “backstabber,” or similar identity.
5. Reply simulations use applicable patterns to construct conditional branches, not guaranteed predictions.
6. The research corpus includes at least eight reviewed scenario cards materially addressing each pattern, including ambiguous counterexamples.
7. Evaluations test false-positive resistance as well as correct recognition.
8. Workplace bullying routes to safety and escalation guidance; workplace democracy routes to constructive governance guidance.

## Initial source note

The linked topics on Wikipedia's Workplace politics page are discovery leads, not sufficient evidence by themselves. Scenario cards must retain stronger source metadata, evidence tier, jurisdiction, editorial review, and original citations under the project's knowledge-ingestion policy.
