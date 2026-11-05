# Building from the language

Use this guide when the user requests a website or interface, including a request phrased mainly through references: “Build me something with this feeling.” The design language is the bridge to the artifact, not the final substitute for it.

## Translate the direction into a page

Read the project's stack, entry points, existing components, assets, and build commands. Preserve established conventions and approved brand decisions. For a new project with no chosen stack, use a simple approach suited to the requested behavior; a visual reference is not a reason to introduce a framework or animation library.

Map the page's real content and main task before styling. For each major area, name the two or three vocabulary terms it carries and the resulting decisions: what leads, how densely information is grouped, how actions are distinguished, and what imagery earns its space. Adapt composition to the content. A reference can contribute a quality without donating its hero, navigation, or section order.

Make a coherent set of project decisions for type hierarchy, spacing, color roles, shape, imagery, and relevant states. Reuse existing tokens where available; introduce only the values the build needs. Record new values as project decisions rather than retroactively calling them reference measurements.

When several plausible interpretations would produce materially different sites, show a small visual comparison or ask a focused question. If the user asked you to choose, make a reasoned choice and proceed. They can react to something concrete without knowing design terminology.

## Implement the requested experience

Build the actual page or interface, using supplied content and assets. If real content is missing, use clearly identified draft copy or sample data, and keep claims grounded. Choose visuals that explain the subject; do not invent customer proof, product capabilities, or business details to make a composition seem complete.

Include the states relevant to the task: hover and visible keyboard focus for controls, loading or empty states for data interfaces, validation and completion for forms. Keep touch and narrow layouts functional. Let motion explain state or emphasis where it serves the language; preserve content and functionality with reduced motion.

Work within the requested functionality. A static prototype can demonstrate a booking form, but must disclose that it does not submit bookings. A request for a working form needs the relevant behavior or a clear account of the missing dependency. Never pass a simulated action off as a connected service.

## Inspect, revise, hand over

Run the project's relevant build and checks. If a renderer is available, inspect representative wide and narrow layouts and the important interaction states. Verify that real text fits, content remains readable, media loads, and controls have a useful response. Repair visible failures and inspect the affected area again.

Review the result against the language, not just a generic polish checklist:

- Where is each term visible, and what design decision expresses it?
- Does the composition serve this content and task?
- Did implementation introduce a generic pattern that weakens the user's direction?
- Do constraints such as readable contrast, focus, touch, and reduced motion survive the treatment?

Use the user's actual reactions and kept/rejected examples to judge the direction. A successful build, a complete vocabulary, or an agent's favorable review establishes neither the user's taste nor their approval. Compare the composition and behavior with the reference evidence, then let concrete feedback change the work.

Report checks actually performed. If rendered inspection or a functional dependency is unavailable, deliver the useful work and name the unverified part. Source review does not establish visual quality, and a screenshot does not prove a working integration.

Update `DESIGN.md` with the implemented decisions and any new evidence. Keep the distinction between an agent's proposed implementation and a user-approved direction. When the user gives feedback, translate vague reactions into specific revisions, apply them, and retain the decisions that still hold.

Finish with the artifact location, how to run or view it, and any material remaining limitation. Publish or deploy only within the user's authorization.
