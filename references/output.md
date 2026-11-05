# Writing a usable DESIGN.md

Use this structure for a new document; adapt it to the project and preserve a useful existing format. Omit irrelevant sections instead of filling them with invented detail. Keep the document portable Markdown; this skill defines no required external schema or linter.

```markdown
# Design language: <project>

Status: <Draft / Proposed / Approved, with the scope of any approval>

## Context
<Purpose, audience, main visitor task. Attribute assumptions.>

## Thesis
<One sentence describing the experience this project should create.>

## Vocabulary
### <Term>
<Observable definition.>
- Evidence: <reference and inspected behavior, user statement, or proposal.>
- Apply: <a decision in this project's content or interface.>
- Dial: <what more and less would visibly change, while preserving usability.>

## Application
<How the terms affect hierarchy, type, spacing/density, color roles,
imagery, and relevant components. Distinguish existing decisions,
observed reference values, and proposed project values.>

## References and evidence
| Source | Evidence status | Contributes | Limits |
| --- | --- | --- | --- |
| <URL or supplied filename> | <Observed date and view / user-stated> | <terms or behaviors> | <what was not inspected> |

## Constraints
<Known stack, brand, accessibility, devices, motion, performance,
or discoverability requirements relevant to the project. Label proposals.>

## Ruled out
- <Rejected quality and reason>. Prefer <positive alternative>.

## Decisions and open questions
<What the user approved, what is proposed, what remains unknown.
Keep existing decisions; add rationale when a decision changes.>

## Using this language
<A concrete example of steering a page or component by its terms.>
```

## Quality check before handing it over

- **Grounded:** each term traces to observed evidence, the user's words, or a labeled proposal. Uninspected sites and invented values do not masquerade as observations.
- **Distinct:** the thesis and terms make choices specific to this audience and content. Terms are not synonyms for “good,” and tensions have a clear area of application.
- **Actionable:** explain how the language changes decisions on a relevant page or component. Written application guidance is sufficient for a document-only request; an implementation request needs the requested artifact. A subsequent agent can tell what “more” or “less” means.
- **Portable:** the document contains the context needed to use it. It requires no private tool, plugin, session memory, temporary file, or vendor-specific invocation.
- **Honest:** draft and approval status are explicit. Missing motion, mobile, accessibility, and measurement checks remain visible where they matter.
- **Scoped:** preserve existing decisions and the requested deliverable. Proposed tokens are justified rather than exhaustively generated. Public-facing discoverability needs belong here only when relevant to the brief.

Do not claim that Markdown alone guarantees consistent implementation or that accessibility has passed without checking the built interface.
