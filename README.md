# Git Tools

A small collection of Git commands and [githooks](https://git-scm.com/docs/githooks)
to pick from and turn on wherever they suit.

Every script lives in `bin/` and is named `git-<name>`. Installing symlinks
them onto your `PATH`, which gives you two things:

- Git runs any `git-<name>` on `PATH` as `git <name>`, so the commands work
  like built-in ones, with no aliases to configure.
- Hooks are enabled through Git's config-based hooks (`hook.<name>.command` and
  `hook.<name>.event`), which can name a script without a path.

Nothing is copied: edits here take effect everywhere once pulled.

## Install

Clone this repository somewhere stable and run the installer:

```sh
./install.sh
```

It symlinks each script in `bin/` into `~/.local/bin`, or into the directory
you pass (`./install.sh ~/bin`), and warns if that directory isn't on `PATH`.
It's safe to rerun after pulling: links into this repository are refreshed,
links to scripts that no longer exist are removed, and anything else already at
a target path is left alone and reported.

Remove the links again with `./install.sh --uninstall`.

The installer only provides the scripts. Hooks are enabled separately, wherever
you want them; see [Enabling hooks](#enabling-hooks).

## Commands

| Command | What it does |
| --- | --- |
| `git cod` | Checks out the default branch (the one `origin/HEAD` points to). |
| `git bonsai [--no-fetch]` | Fetches and prunes every remote, then deletes local branches whose upstream is gone, such as branches squash-merged on the remote. Branches checked out in another worktree are left alone. |
| `git done` | Finishes with a branch: `git cod`, `git pull`, then `git bonsai`. |
| `git ctags` | Regenerates the `tags` file in the background; see below. Also works as a hook. |

`git ctags` writes `tags` to the worktree's Git directory: `.git/tags` in the
main worktree and `.git/worktrees/<name>/tags` in a linked one, with absolute
paths. Your editor may not look there; configure it to read that file, or
change where the script writes it.

## Hooks

| Script | Event | What it does |
| --- | --- | --- |
| `git-issue-prepare-commit-msg` | `prepare-commit-msg` | Pre-fills an empty commit message with the issue key from the branch name. |
| `git-issue-commit-msg` | `commit-msg` | Rejects empty messages and messages that start with a comment; adds the issue key from the branch name if the subject doesn't already start with it. |
| `git-bonsai-hook` | `post-merge` | After a pull on the default branch, runs `git bonsai --no-fetch`. |
| `git-ctags` | any (e.g. `post-checkout`, `post-merge`, `post-commit`) | Regenerates `tags`, as `git ctags` does. |

The issue key is the first `LETTERS-DIGITS` match in the branch name, so all of
these work:

```text
ACME-1234-a-short-description
ACME-1234/slashes-are-fine-too
prefix/ACME-5678-a-different-description
hotfix/user/ACME-5678/multiple-slashes-and-prefixes
```

`git-bonsai-hook` runs after a pull that merges or fast-forwards. It doesn't run
when the pull is already up to date, or when `pull.rebase` is set and the pull
actually rebases.

## Enabling hooks

Each hook gets a name of your choosing, an `event` that triggers it, and a
`command` that runs it. A hook can list `event` more than once to run on
several events.

Hook commands run with the `PATH` of whatever started Git. A GUI client
launched outside your shell may not have the install directory on its `PATH`;
use the script's full path in `command` if that's a problem.

### One repository

From inside the repository:

```sh
git config hook.issue-prepare-commit-msg.event prepare-commit-msg
git config hook.issue-prepare-commit-msg.command git-issue-prepare-commit-msg

git config hook.issue-commit-msg.event commit-msg
git config hook.issue-commit-msg.command git-issue-commit-msg
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
	command = git-issue-prepare-commit-msg

[hook "issue-commit-msg"]
	event = commit-msg
	command = git-issue-commit-msg
```

The trailing slash in `gitdir:~/src/ACME/` matters: it matches every repository
below that directory. Repositories (or worktrees) that live elsewhere won't
pick up these hooks.

### Every repository

Add the same `[hook "…"]` sections to `~/.gitconfig`, or use `git config
--global`:

```sh
git config --global hook.bonsai.event post-merge
git config --global hook.bonsai.command git-bonsai-hook

git config --global hook.ctags.event post-checkout
git config --global --add hook.ctags.event post-merge
git config --global --add hook.ctags.event post-commit
git config --global hook.ctags.command git-ctags
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
