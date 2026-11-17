# Skills

Two skills that work as a pair. `jira-ticket-creator` writes a ticket and files it as a GitHub issue, `zapierdalasz` implements the ticket and opens a pull request

## jira-ticket-creator

```
/jira-ticket-creator [--disco] [--type=feature|improvement|bug|task|spike] <ticket description>
```

The skill interviews you one question at a time. With `--disco` it also reads the code so the ticket names the files and tests the change touches

Every ticket gets acceptance criteria that define when the work is done. If the work is too big for one ticket, the skill proposes an epic with sub-tickets. You see the ticket in the chat before the skill files it and adds it to the project board. Tell the skill if you want the ticket to stay in the chat

## zapierdalasz

```
/zapierdalasz <issue number or URL> [--no-review]
```

Before it changes anything, the skill checks every acceptance criterion against the code and asks all its questions in one message. Then it assigns the ticket to you and moves it to `In progress`. Each criterion that isn't met yet gets a failing test first and then the fix

You get a pull request that lists the evidence for every criterion. Code review (the `code-review` skill) has already run on it and the fixes are committed, unless you passed `--no-review`. The ticket moves to `In review`. Nothing gets merged

## Setup

Both skills call the `gh` CLI, so log in first. They look for these lines in the project passport, a file named like `AI_PASSPORT.md` in the repo root or in `docs/`:

```
repo: https://github.com/<owner>/<repo>
https://github.com/users/<owner>/projects/<n>
status_field: Status
in_progress: In progress
review: In review
```

The last three lines are optional and show the defaults. They name the board's status field and the two columns `zapierdalasz` moves the ticket to. Without a passport `jira-ticket-creator` asks where the ticket goes and saves your answer in `AI_PASSPORT.md`

`gh` needs the `project` scope for the board: `gh auth refresh -s project`

`zapierdalasz` needs `gh` 2.97 or newer
