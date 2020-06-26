#!/usr/bin/env bash
# install unix shells.
#
# PLEASE NOTE:
#   run this script from this directory only!

# funcs
die() { echo "$1" >&2; exit "${2:-1}"; }
usage() { echo "usage: $0 <shell>"; exit 64; }

# check path
[[ -d .git ]] || die "must be in repo root directory"

# check deps
deps=(git)
for dep in "${deps[@]}"; do
    hash "$dep" 2>/dev/null || missing+=("$dep")
done
if [[ ${#missing[@]} -ne 0 ]]; then
    [[ ${#missing[@]} -gt 1 ]] && { s="s"; } 
    die "missing dep${s}: ${missing[*]}"
fi

# check args
shell="$1"
[[ -z "$shell" ]] && usage

# install shell
case "$shell" in
    zsh)

    # files
    dotfiles="$HOME/.dotfiles"
    zshrc="$HOME/.zshrc"
    theme="/usr/local/share/zsh/site-functions/prompt_spaceship_setup"

    # clear existing files (if found)
    files=(
        "$dotfiles"
        "$zshrc"
        "$theme"
    )
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            sudo rm -rf "$file" \
                || die "failed to remove $file"
        fi
    done

    # install dotfiles directory
    ln -s "$PWD" "$dotfiles" \
        || die "failed symlink for .dotfiles"

    # install .zshrc
    ln -s "$dotfiles/zsh/zshrc" "$zshrc" \
        || die "failed symlink for .zshrc"

    # download theme
    tmp="$HOME/spaceship-prompt"
    if [[ -d "$tmp" ]]; then
        rm -rf "$tmp" \
            || die "failed to remove $tmp"
    fi
    git clone "https://github.com/denysdovhan/spaceship-prompt.git" "$tmp" \
        || die "failed git clone to $"

    # install theme
    sudo ln -sf "$tmp/spaceship.zsh" "$theme" \
        || die "failed symlink for spaceship theme"

    ;;
    *) die "missing $shell implementation" ;;
esac

