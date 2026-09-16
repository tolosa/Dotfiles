# Repository Guidelines

## Project Structure & Module Organization

This repository stores macOS dotfiles in GNU Stow packages:

- `zsh/`: shell startup configuration, an empty login-suppression file, and Oh My Zsh custom aliases.
- `git/`: Git user and push settings in `dot-gitconfig`.
- `ghostty/dot-config/ghostty/`: terminal configuration and the `Ghostty.icns` icon asset.
- `.stowrc`: enables `--dotfiles` and verbose output.

Package paths mirror their destinations under `$HOME`; Stow converts names such as `dot-zshrc` to `.zshrc`. Add new application configuration in a separate top-level package. There is no application source tree, build system, or test directory.

## Development & Validation Commands

Run these commands from the repository root:

- `stow --simulate --target="$HOME" zsh git ghostty`: preview symlinks and identify conflicts without changing files.
- `stow --target="$HOME" zsh git ghostty`: install the packages as symlinks after reviewing the preview.
- `stow --restow --target="$HOME" zsh`: refresh links after reorganizing shell files.
- `zsh -n zsh/dot-zshrc zsh/dot-oh-my-zsh/custom/aliases.zsh`: check shell syntax without executing startup commands.
- `git config --file git/dot-gitconfig --list`: verify that Git can parse its configuration.
- `git diff --check`: catch whitespace errors before committing.

## Coding Style & Naming Conventions

Preserve the style of each configuration file. Use two-space indentation in Zsh blocks, tabs for Git configuration entries, and `key = value` formatting for new Ghostty settings. Group aliases by tool with short comments; keep custom aliases in `zsh/dot-oh-my-zsh/custom/aliases.zsh`. Quote shell paths that may contain spaces. Preserve the `dot-` naming convention for Stow-managed hidden files and directories. If JavaScript tooling is introduced, prefer `pnpm` over `npm`.

## Configuration Precautions

Existing settings reference Homebrew and Oh My Zsh paths outside this repository. Check those dependencies before runtime testing. Avoid adding credentials or additional machine-specific absolute paths; prefer `$HOME` in shell configuration. Review Git identity settings before installing the Git package.
