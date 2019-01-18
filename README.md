# Git Template

A small collection of `githooks` which are useful in most repositories.

## Install

Copy the `hooks` directory to the `init.templateDir` specified in your
`.gitconfig`. If you don't have such an entry, add one. 

```bash
mkdir ~/.git-template
git config --add init.templateDir ~/.git-template
```

```ini
[init]
	templateDir = ~/.git-template

```

# Usage

Whenever you create a new repository (by `git init` or `git clone`) the
contents of `init.templateDir` will be copied to the `.git` directory. This
allows you to get all your hooks (or other files) configured in each repo
right away.
