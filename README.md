# Git Hooks

A small collection of [githooks](https://git-scm.com/docs/githooks) to pick
from and turn on in whichever repositories they suit.

Nothing is copied into a repository. Each hook is enabled through Git's
config-based hooks (`hook.<name>.command` and `hook.<name>.event`), which run
the script straight from this checkout. That means:

- Edits to a hook here take effect everywhere it's enabled, with no reinstall.
- Hooks can be enabled for one repository, every repository in a directory, or
  every repository you have, including ones cloned long ago.
- They run alongside a repository's own `.git/hooks` scripts (and tools such as
  `pre-commit` or `husky` that install there) instead of replacing them.
  Config-based hooks run first.

## Hooks

| Script | Event | What it does |
| --- | --- | --- |
| `hooks/prepare-commit-msg` | `prepare-commit-msg` | Pre-fills an empty commit message with the issue key from the branch name. |
| `hooks/commit-msg` | `commit-msg` | Rejects empty messages and messages that start with a comment; adds the issue key from the branch name if the subject doesn't already start with it. |
| `hooks/ctags` | any (e.g. `post-checkout`, `post-merge`, `post-commit`) | Regenerates `.git/tags` with `ctags`. |

The issue key is the first `LETTERS-DIGITS` match in the branch name, so all of
these work:

```text
ACME-1234-a-short-description
ACME-1234/slashes-are-fine-too
prefix/ACME-5678-a-different-description
hotfix/user/ACME-5678/multiple-slashes-and-prefixes
```

## Setup

Clone this repository somewhere stable; the examples below assume
`~/src/git-template`. Each hook gets a name of your choosing, an `event` that
triggers it, and a `command` that runs it. A hook can list `event` more than
once to run on several events.

### One repository

From inside the repository:

```sh
git config hook.issue-prepare-commit-msg.event prepare-commit-msg
git config hook.issue-prepare-commit-msg.command ~/src/git-template/hooks/prepare-commit-msg

git config hook.issue-commit-msg.event commit-msg
git config hook.issue-commit-msg.command ~/src/git-template/hooks/commit-msg
```

### Every repository in a directory

Use `includeIf` to load a separate config file only for repositories under a
directory. For example, to enable the issue-key hooks for every repository in
`~/src/ACME/`, add this to `~/.gitconfig`:

```ini
[includeIf "gitdir:~/src/ACME/"]
	path = ~/.gitconfig-acme
```

and put the hooks in `~/.gitconfig-acme`:

```ini
[hook "issue-prepare-commit-msg"]
	event = prepare-commit-msg
	command = ~/src/git-template/hooks/prepare-commit-msg

[hook "issue-commit-msg"]
	event = commit-msg
	command = ~/src/git-template/hooks/commit-msg
```

The trailing slash in `gitdir:~/src/ACME/` matters: it matches every repository
below that directory. Repositories (or worktrees) that live elsewhere won't
pick up these hooks.

### Every repository

Add the same `[hook "…"]` sections to `~/.gitconfig`, or use `git config
--global`:

```sh
git config --global hook.ctags.event post-checkout
git config --global --add hook.ctags.event post-merge
git config --global --add hook.ctags.event post-commit
git config --global hook.ctags.command ~/src/git-template/hooks/ctags
```

## Checking and disabling hooks

List the hooks that will run for an event in the current repository:

```sh
git hook list commit-msg
```

Turn off a hook in one repository without touching the shared config:

```sh
git config hook.issue-commit-msg.enabled false
```

Remove a hook entirely by deleting its section:

```sh
git config --global --remove-section hook.ctags
```

To skip `pre-commit` and `commit-msg` hooks for a single commit, use
`git commit --no-verify`.
