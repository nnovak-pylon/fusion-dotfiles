# Dotfiles

My configuration files for the various tools that I use

# Usage

To create the necessary symlinks, use the `nli` command-line tool:

* `nli sync` To link everything
* `nli sync --desync` To clean up all the links

## Arch:

```
sudo pacman -S python-pynvim wl-clipboard rust-analyzer
paru -S google-java-format java-language-server-git
```

```
sudo systemctl start reflector
```
