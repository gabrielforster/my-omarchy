## MY-OMARCHY

Scripts to take a fresh [Omarchy](https://omarchy.org/) install and turn it into
my working setup — the Arch/Hyprland counterpart to
[`dev`](https://github.com/gabrielforster/dev), which does the same for
Debian/Ubuntu + i3.

The guiding rule: **use what Omarchy already ships wherever it is a good
substitute, and only bring over the things it does not cover.** Omarchy is an
opinionated distro; fighting it means losing its theming, its menus and its
update path. A large part of the old `dev` repo turned out to be unnecessary
here — see [What Omarchy already provides](#what-omarchy-already-provides).

## Layout

- `scripts/` — base installers (packages, terminal, AUR, docker, shell). Run first.
- `after/` — things that depend on `scripts/` (fonts, configs, git, runtimes, CLIs, Hyprland). Run after.
- `files/` — config files deployed by `after/02-configs` and `after/06-hypr`.
- `run` — orchestrator that iterates over `scripts/` then `after/`.

Both directories are numbered because `run` executes in sorted order and some
steps genuinely depend on earlier ones (`05-cli-tools` needs the Rust toolchain
that `04-mise` installs). The numbers are the dependency order, not decoration.

## Usage

Run everything:

```sh
./run
```

### Parameters

Same flags as `dev/run` — it is the same script.

| Arg                    | Effect                                                                 |
|------------------------|------------------------------------------------------------------------|
| `--dry`                | Dry run. Prints what would execute, prefixed with `[DRY_RUN]:`. No changes made. |
| `--filter <list>`      | Comma separated substrings. Only scripts whose path matches at least one are executed. |
| `--filter-out <list>`  | Comma separated substrings. Scripts whose path matches any of them are skipped. |
| `<filter>`             | Any other positional arg is treated as `--filter`. |

```sh
./run --dry                    # preview the whole run
./run hypr                     # just the Hyprland config
./run --filter mise,cli-tools  # runtimes and the CLIs that need them
./run --filter-out after       # base installs only
```

### Prerequisites

`after/02-configs` clones `zsh` and `nvim` over SSH, so a working SSH key must
be registered on GitHub before running it:

```sh
ssh-keygen -t ed25519 -C "rochafrgabriel@gmail.com" -f ~/.ssh/id_ed25519 -N ""
wl-copy < ~/.ssh/id_ed25519.pub    # paste at https://github.com/settings/ssh/new
ssh -T git@github.com              # expect "Hi gabrielforster!"
```

Add the same key a **second** time as a *Signing Key*. Authentication and
signing are separate entries on GitHub, and commits will not show as Verified
without it even though `after/03-git` configures signing correctly.

## What Omarchy already provides

These were all steps in `dev` and are simply gone here. Omarchy's versions are
Wayland-native, themed, and updated with the system.

| `dev` installed | Omarchy equivalent |
|---|---|
| `rofi` | omarchy-menu (`SUPER+SPACE`, rebound to `SUPER+D` — it is also the app launcher) |
| `dunst` | omarchy-shell notifications |
| `flameshot` | `omarchy capture screenshot/region`, with an editor |
| `copyq` | Omarchy clipboard history (`SUPER+CTRL+V`) |
| `picom`, `feh`, `arandr`, `lxappearance`, `nm-applet`, `xss-lock`, `dex` | Hyprland + omarchy-shell natively |
| `i3`, `i3blocks`, `i3status` | Hyprland + the Omarchy bar |
| `asdf` (+ Go, to build it) | `mise`, already installed and used by Omarchy itself |
| `starship`, `eza`, `bat`, `fd`, `ripgrep`, `fzf`, `zoxide`, `tmux`, `neovim`, `docker`, `gh`, `jq` | preinstalled |
| Nerd Fonts from GitHub zips | packaged: `ttf-ubuntu-nerd`, `ttf-ubuntu-mono-nerd`, `ttf-firacode-nerd`, `otf-firamono-nerd`, `ttf-adwaitamono-nerd` |
| neovim built from source | packaged `neovim` is current (0.12.5, the latest stable tag). On Ubuntu the source build existed because apt's was ancient; that reason does not apply here. |
| `xclip` | `wl-clipboard` (`wl-copy` / `wl-paste`) |

Only **IoskeleyMonoTerm** still needs a manual download (`after/01-fonts`) —
it is the ghostty font and is not in any repo.

## Decisions

Where my setup and Omarchy's disagreed, and which won.

| Area | Choice | Why |
|---|---|---|
| Terminal | **ghostty** over Omarchy's foot | Kept my config. Installed via `omarchy install terminal ghostty`, which also sets it as the `xdg-terminal-exec` default — that is why `SUPER+Return` needs no keybinding override. |
| Shell | **zsh** over Omarchy's bash | Kept my modular config. Omarchy's bash config is untouched. |
| Runtimes | **mise** over my asdf | Already installed and driving Omarchy's own tooling. asdf-compatible (reads `.tool-versions`). Running both would mean two sets of shims fighting over `PATH`. |
| Neovim | **my config**, Omarchy's **binary** | `~/.config/nvim` is my repo; the packaged nvim stays and updates with the system. |
| Launcher / notifications / screenshots | **Omarchy's** | Wayland-native and themed. rofi/dunst/flameshot are X11 and behave badly under Hyprland. |
| tmux | **my config** over Omarchy's | Trade-off taken knowingly: loses theme-following colours and the `omarchy menu tmux-keybindings` popup, keeps my prefix and bindings. |
| herdr | **my config** over Omarchy's | Consistency with the tmux choice — mine is `ctrl+b`, Omarchy's mirrors its own `ctrl+space` tmux. |
| starship | **my config** | `STARSHIP_CONFIG` points at `~/.config/zsh/starship.toml`, so zsh uses mine and Omarchy's bash keeps `~/.config/starship.toml`. No conflict. |
| ghostty theme | **Omarchy's dynamic theme** over my static Vesper | Terminal follows `omarchy theme set`. My font/padding/decoration settings layered on top. |
| Commit signing | **SSH** over GPG | The GPG private key is not on this machine, and the SSH key already exists for auth. |
| Global node | **Omarchy's 26.7.0** | Omarchy's `claude`/`codex` run through mise. My versions are installed and selected per-project. |

## i3 → Hyprland keybindings

`files/hypr/bindings.lua` carries this mapping with the reasoning inline. Summary:

**Already identical — nothing bound.** `SUPER+Return`, `SUPER+F` (fullscreen),
`SUPER+arrows` (focus), `SUPER+Shift+arrows` (move), `SUPER+1..0` and
`SUPER+Shift+1..0` (workspaces), and every `XF86` media/brightness key.

**Rebound, displacing an Omarchy default:**

| Key | Now | Was, and where it went |
|---|---|---|
| `SUPER+SPACE` | focus tiling/floating toggle | Omarchy menu → moved to `SUPER+D` |
| `SUPER+D` | Omarchy menu | *(was unbound)* |
| `SUPER+P` | screenshot region | Pseudo window → **dropped** |
| `SUPER+Shift+SPACE` | float toggle | toggle top bar → moved to `SUPER+T` |
| `SUPER+T` | toggle top bar | float toggle → moved to `SUPER+Shift+SPACE` |
| `SUPER+Shift+C` / `+R` | reload config | Calendar webapp → **dropped** |
| `SUPER+Shift+E` | system menu (exit) | Email webapp → **dropped** |
| `SUPER+Shift+X` | lock | X webapp → **dropped** |
| `SUPER+Shift+O` | OBS | Obsidian webapp → **dropped** |

**Added on free keys:** `SUPER+Shift+Q` (close), `SUPER+N` (file manager),
`SUPER+E` (toggle split), `SUPER+Shift+H`/`+V` (dwindle preselect), `SUPER+R`
(resize submap, same `j`/`k`/`l`/`ç` keys as i3).

**Not ported:**

- `$mod+a` focus parent — dwindle has no focusable parent container.
- `$mod+s` stacking, `$mod+w` tabbed — dwindle has no such layouts. The real
  equivalent is window groups: `SUPER+G` toggles grouping and draws a tab bar,
  `SUPER+CTRL+←/→` moves within the group.

i3 had separate reload (`$mod+Shift+c`) and restart (`$mod+Shift+r`); in
Hyprland these are one operation, so both keys are bound to it.

## Caveats

**`files/ghostty/config` is a merge snapshot, not an overlay.** It is Omarchy's
config with my font, padding, `window-decoration = none` and
`mouse-hide-while-typing` edited in. If Omarchy changes its ghostty defaults,
those changes will not appear here — re-merge against
`/usr/share/omarchy/config/ghostty/config` when that happens. The same applies
to `files/tmux/tmux.conf` and `files/herdr/config.toml`, which replace
Omarchy's outright.

`files/hypr/bindings.lua` and `autostart.lua` are safe to replace wholesale —
Omarchy ships those as empty user-override templates. `input.lua`,
`hyprland.lua` and `looknfeel.lua` are *appended to* by `after/06-hypr` for
exactly this reason, guarded so re-running does not duplicate the block.

**Everything replaced is backed up** as `<name>.omarchy-backup-<timestamp>`
next to the original.

## Scripts in `files/scripts/`

Deployed to `~/.config/scripts/`.

| Script | Purpose |
|---|---|
| `tmux-sessionizer.sh` | fzf project picker → tmux session. Scans `~/Work`, `~/Work/*`, `~/Projects`, `~/.config`. |
| `herdr-sessionizer.sh` | Same picker → herdr workspace. Focuses by `label` if it exists, else creates with `--cwd --label --focus`. |
| `herdr-focus-blocked.sh` | Cycles focus through agents with `agent_status == "blocked"`. Bound to `prefix+shift+o`. |
| `hypr-focus-mode-toggle.sh` | i3's `focus mode_toggle` — Hyprland has no equivalent, so this walks the client list. Bound to `SUPER+SPACE`. |

## Notes on Omarchy defaults worth knowing

**Unfocused windows are slightly transparent out of the box.** Omarchy tags
every window `default-opacity` and applies `opacity = "0.985 0.96"` (active,
inactive) in `/usr/share/omarchy/default/hypr/windows.lua`. It is a *window
rule*, not a global setting — `decoration:inactive_opacity` reads `1.0`, so
checking that option suggests nothing is transparent. `files/hypr/looknfeel.snippet.lua`
re-applies the rule as `"1.0 1.0"` to turn it off. `SUPER+BACKSPACE` toggles it
per window without any config change.

## TODO

- Omarchy plugin setup (`omarchy plugin clone`, bar widgets, `shell.json`).
