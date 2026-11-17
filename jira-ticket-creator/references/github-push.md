# GitHub push reference

Every `gh` command the skill uses, in execution order. `<owner>/<repo>` and the board come from
the passport (`SKILL.md`, Project passport) or from the user's answer in Step 5a. Never from a
guess.

## 1. Similar-issue search (board check and Step 5b)

Search open and closed issues by the two or three main nouns of the title (not the whole title;
exact-title search misses near-duplicates). Second run with synonyms if the board mixes languages
(export / eksport):

```bash
gh issue list --repo <owner>/<repo> --state all --search "<two or three key words>" --limit 10 --json number,title,state,url
```

A plausible match is the same feature or the same bug, even if worded differently. Show at most
five, most similar first.

### Link as related

When the user chose "link":

- the new issue body gets `Related: #<existing-number>` directly under the `Type:` line,
- after creation, comment on the existing issue (a closed one stays closed):
  ```bash
  gh issue comment <existing-number> --repo <owner>/<repo> --body "Related: <new-issue-url>"
  ```

## 2. Labels

Map `Type:` to a label: `feature`, `improvement`, `bug`, `task`, `spike`, `epic`. Check which exist:

```bash
gh label list --repo <owner>/<repo> --limit 200 --json name --jq '.[].name'
```

Pass only labels that exist. Never create labels; a missing label is skipped and mentioned in the
report in one line.

## 3. Create an issue

Title from the `Title:` line, in single quotes so the shell expands nothing in it (an embedded
`'` is written `'\''`). Body is the rest of the ticket without the `Title:` line (keep the
`Type:`, `Related:`, `Part of:` and `Depends on:` lines). Body goes through stdin:

```bash
gh issue create --repo <owner>/<repo> --title '<title>' --label <label> --body-file - <<'EOF'
<body>
EOF
```

Prints the issue URL; the number is its last path segment. Record both.

Split: one issue at a time, the Epic first, then every sub-ticket after the ones it depends on.
In a sub-ticket body the titles after `Part of:` and `Depends on:` become the numbers just
created (`Part of: #120`, `Depends on: #123`). A failed creation is reported by title and not
retried; the rest is still created and linked, and a line pointing at the failed one keeps its
title.

## 4. Project assignment (only if the passport names a board)

```bash
gh project item-add <board-number> --owner <board-owner> --url <issue-url>
```

Once per created issue. Failure (usually no `project` scope on the token; the fix is `gh auth
refresh -s project`, which the user runs, not you): continue, mention it in the report.

## 5. Relationships (splits only)

Sub-issues, every sub-ticket under its Epic:

```bash
gh issue edit <sub-number> --repo <owner>/<repo> --parent <epic-number>
```

Dependencies, one command per `Depends on:` line (the issue carrying it is blocked by the one it
names):

```bash
gh issue edit <blocked-number> --repo <owner>/<repo> --add-blocked-by <blocker-number>
```

All parents first, then all dependencies. Then verify and compare with the plan; add what is
missing once, verify again:

```bash
gh api repos/<owner>/<repo>/issues/<epic-number>/sub_issues --jq '.[].number'
gh api repos/<owner>/<repo>/issues/<blocked-number>/dependencies/blocked_by --jq '.[].number'
```

A command that fails (a `gh` too old for these flags, a repo without the feature, a token without
the scope): say so; the numbered `Part of:` and `Depends on:` lines in the bodies stand in.

## 6. Report

URLs only, as a tree for a split:

```
#120 Epic: Customer order history export <url>
  #123 Default-range export end to end <url>
  #124 Custom range with the 12-month limit <url>  (blocked by #123)
```

Plus one line per thing that did not happen (skipped label, Project add failed, relationships
unavailable). Nothing else.

## 7. Corrections after the push

The full corrected body through stdin, to the same issue; add `--title '<title>'` only when the
title changed:

```bash
gh issue edit <number> --repo <owner>/<repo> --body-file - <<'EOF'
<body>
EOF
```

Body as in section 3, the numbers in `Part of:` and `Depends on:` kept. One line with the issue
URL.
