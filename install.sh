#!/usr/bin/env bash

# Symlink every script in bin/ into a directory on PATH (default
# ~/.local/bin), so Git finds `git-<name>` as `git <name>` and hook commands
# can name the scripts without a path.
#
# Usage: ./install.sh [--uninstall] [DIR]
#
# Safe to rerun. Links that already point into this repository's bin/ are
# replaced, and links to scripts that no longer exist are removed. Anything
# else at a target path is left alone and reported, and the script exits 1.

set -euo pipefail

usage() {
	echo >&2 "usage: $0 [--uninstall] [DIR]"
	exit 2
}

uninstall=false
dir=

for arg; do
	case "$arg" in
		--uninstall) uninstall=true ;;
		-*) usage ;;
		*) [[ -z $dir ]] || usage; dir=$arg ;;
	esac
done

src=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/bin
dir=${dir:-${HOME}/.local/bin}
status=0

# Remove links in $dir that point into $src: all of them when uninstalling,
# otherwise only those whose script is gone.
for link in "${dir}"/*; do
	[[ -L $link ]] || continue
	target=$(readlink "$link")
	[[ $target == "${src}/"* ]] || continue
	if $uninstall || [[ ! -e $target ]]; then
		rm "$link"
		echo "removed ${link}"
	fi
done

$uninstall && exit 0

mkdir -p "$dir"

for script in "${src}"/*; do
	link="${dir}/$(basename "$script")"
	if [[ -e $link || -L $link ]] && [[ $(readlink "$link") != "${src}/"* ]]; then
		echo >&2 "skipped ${link}: already exists and isn't a link into ${src}"
		status=1
		continue
	fi
	ln -sfn "$script" "$link"
	echo "linked ${link}"
done

case ":${PATH}:" in
	*":${dir}:"*) ;;
	*) echo >&2 "warning: ${dir} isn't on PATH" ;;
esac

exit $status
