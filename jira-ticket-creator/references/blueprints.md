# Ticket blueprint

One template, plus a thin one for split sub-tickets (Splits). Lines marked "(Bug only)" appear
only in a Bug, without the marker.

```
Title: {title}
Type: {Feature | Improvement | Bug | Task | Spike | Epic}
Related: #{number}               (after a "link" decision; else omit)

TL;DR:
{2-3 sentences, written last: what, why, main risk. Bug: what is broken, impact, suspected area}

Delivered value:
{1-2 sentences for a stakeholder outside the team, not the title again. Bug: what stops hurting}

Description:
{3-8 sentences: what changes, how it behaves, from the user's point of view. No implementation detail}

Environment:                     (Bug only)
{app version or build, browser/OS, prod/staging, account type, feature flags; "Unknown" where not known}

Steps to reproduce:              (Bug only)
1. {step}

Expected behavior:               (Bug only)
{expected}

Actual behavior:                 (Bug only)
{actual, with exact error text}

Business context:
{why now, what it costs not to do it, who asked}

Impact:
{named systems, users, processes; "various modules" is not an impact}

Out of scope:
* {adjacent work excluded, especially what discovery surfaced; "separate ticket" where valuable}

Acceptance Criteria (ACs):
- [ ] AC1: Given {state}, When {action}, Then {observable outcome}
- [ ] AC2: {non-behavioral criterion with a measurable target}
{rules: SKILL.md Step 3. Spike: Step 0. Epic: Splits}

Spikes:
* {unknown to resolve before implementation, including what the follow-up limit and the fresh-context review left open}

Potential complications:
* {concrete: "the export runs in the request thread and times out above ~5k rows", not "performance may be a concern"}

Dev Notes:
{snapshot line, see Header variants}
{facts, not instructions: files, functions, services, conventions, warnings. Without discovery: only what the user said or this conversation established}

Additional remarks:
{Topic 4 plus anything that fits nowhere else; no extra sections}

Suggested approach (advisory, discovery at {hash} on {branch}):
{direction and key decisions, no step sequence: conventions to reuse, the path that fits this codebase, what to avoid and why. Without discovery: the picture of the solution the user or this conversation gave, else "None identified."}

Note to implementer: this section is advisory and non-binding. Verify it against the current code before acting on it. The Acceptance Criteria define done, not this section.
```

## Splits

Propose an Epic plus 2-5 sub-tickets as a numbered list, one line each: title, blocked by, what it
delivers end to end. Ask one question: granularity and blockers right, anything to merge or split.

A sub-ticket is a vertical slice: a narrow but complete path through every layer the change
touches (schema, API, UI, tests), demoable on its own. Never one layer per ticket.

The Epic uses the template above with `Type: Epic`. Its ACs state the outcome once all sub-tickets
are done; its Description lists the sub-tickets by exact title, in order. It carries Business
context, Impact, Out of scope, Potential complications and the shared Dev Notes and Suggested
approach. A sub-ticket holds only what is its own:

```
Title: {title}
Type: {Feature | Improvement | Bug | Task}
Part of: {epic title}
Depends on: {ticket title}       (only where order matters; else omit)

What it delivers:
{2-3 sentences: the end-to-end behaviour this slice makes work, from the user's point of view}

Acceptance Criteria (ACs):
- [ ] AC1: Given {state}, When {action}, Then {observable outcome}

Spikes:
* {unknown specific to this slice, else "None identified."}

Dev Notes:
{snapshot line, see Header variants}
{facts specific to this slice; the Epic holds the rest}
```

`Part of:` and `Depends on:` carry exact titles in the chat; Step 5 turns them into issue numbers
and GitHub relationships. Steps 3-4 run per ticket, each returned as its own block, the Epic
first, then every sub-ticket after the ones it depends on; 4b runs once over the whole split.
Step 5 starts after every ticket is validated and presented.

## Header variants

First Dev Notes line and the Suggested approach header, by case:

- **with discovery**: `Discovery snapshot: {hash} on {branch}` and
  `Suggested approach (advisory, discovery at {hash} on {branch}):`
- **without discovery**: `Discovery not performed, ticket written from interview only.` and
  `Suggested approach (advisory):`
- **from conversation**: `Discovery not performed, code facts come from this conversation, unverified.`
  and `Suggested approach (advisory):`
- **snapshot unavailable**: `Discovery snapshot unavailable` and `Suggested approach (advisory):`
- **no codebase**: `No codebase available, discovery skipped` and `Suggested approach (advisory):`
