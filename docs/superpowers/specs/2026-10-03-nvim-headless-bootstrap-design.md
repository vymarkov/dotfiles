# Nvim headless bootstrap on fresh-machine dotfiles install

Date: 2026-10-03  
Status: approved design  
Repo: personal dotfiles (`install.sh` / `setup_nvim.sh`)

## Goal

When dotfiles are installed on a fresh machine, Neovim must be usable immediately on first open: no waiting for lazy.nvim clones, plugin builds, or Treesitter parser installs.

## Non-goals

- Migrating plugin management into pure Nix (plugins stay runtime-managed by lazy.nvim).
- Installing Mason packages when using the nix-wrapped `nvim` (flake sets `MASON_DISABLE_INSTALL=1` and puts LSPs/formatters on PATH).
- Changing the LazyVim distro (this config uses lazy.nvim, not LazyVim).

## Flake pin

```
github:vymarkov/nvim/de6eed84a03a1640f8de47ef62852235f6fe5330
```

Same revision already used by the homelab `devbox.json` nvim package.

## Flow

1. User clones dotfiles and runs `./install.sh`.
2. `install.sh` performs existing steps (submodules, stow, cursor symlink, completions, AI agents).
3. If `nix` is on `PATH`, `install.sh` runs `./setup_nvim.sh`.
4. Otherwise `install.sh` prints that `./setup_nvim.sh` should be run after Nix (and thus a buildable flake) is available.
5. `setup_nvim.sh` builds the flake to a stable local path, wires `nvim` to that binary, then runs headless plugin/Treesitter bootstrap.
6. Interactive `nvim` afterward starts without install waits.

## Components

### `setup_nvim.sh` (new)

Owns the full nvim readiness path:

1. Require `nix` (exit non-zero if missing when invoked directly).
2. `nix build` the pinned flake into `$HOME/.local/share/nvim-flake/result`  
   (`nix build -o "$HOME/.local/share/nvim-flake/result" '<flake-ref>'`).
3. Install a shim at `$HOME/.local/bin/nvim` that execs  
   `$HOME/.local/share/nvim-flake/result/bin/nvim`  
   (create `$HOME/.local/bin` if needed).
4. Ensure `$HOME/.local/bin` is on `PATH` in stowed zsh config (uncomment/add the existing PATH line if needed), and add  
   `alias nvim="$HOME/.local/bin/nvim"` so interactive shells prefer the shim even if another `nvim` is earlier on `PATH`.
5. Headless bootstrap using `$HOME/.local/bin/nvim` only (never a random system neovim).

### `install.sh` (update)

After existing setup scripts:

- If `command -v nix` succeeds → run `./setup_nvim.sh`.
- Else → warn: run `./setup_nvim.sh` later once Nix is installed.

Stow remains responsible for `~/.config/nvim` (submodule). The flake does not replace config.

### Stable binary wiring

| Mechanism | Purpose |
|-----------|---------|
| `~/.local/share/nvim-flake/result` | Idempotent `nix build` output; survives re-runs |
| `~/.local/bin/nvim` shim | Works for scripts, headless, and non-interactive callers |
| zsh `alias nvim=…` | Interactive convenience aligned with the shim |

Do **not** alias to `nix run github:…` on every launch (extra overhead). Build once; run the local result.

## Headless bootstrap steps

Run in order with the built binary:

1. `"$NVIM_BIN" --headless "+Lazy! restore" +qa`  
   Restores plugins from `lazy-lock.json` and runs plugin `build` steps (e.g. LuaSnip jsregexp, markdown-preview yarn).
2. `"$NVIM_BIN" --headless "+TSUpdateSync" +qa`  
   Installs/updates Treesitter parsers synchronously.

Mason: skipped. Tooling comes from the flake-wrapped PATH.

## Error handling

| Condition | Behavior |
|-----------|----------|
| `setup_nvim.sh` and no `nix` | Exit non-zero with clear message |
| `install.sh` and no `nix` | Soft-skip; print “run ./setup_nvim.sh later” |
| `nix build` fails | Exit non-zero; surface nix error |
| Headless Lazy/TS step fails | Exit non-zero; do not claim ready |
| Re-run | Safe/idempotent: rebuild symlink output + re-restore |

## Success criteria

- After `./setup_nvim.sh`, `~/.local/bin/nvim --version` works offline against the store/result.
- `~/.local/share/nvim/lazy/lazy.nvim` exists and lockfile plugins are present.
- Opening `nvim` does not block on first-time plugin installation.
- `install.sh` without `nix` still completes stow/other setup and only warns about nvim bootstrap.

## Testing (manual)

1. Fresh (or cleaned) `~/.local/share/nvim` + missing shim: run `./setup_nvim.sh`, then open `nvim`.
2. Re-run `./setup_nvim.sh` — succeeds without error.
3. `install.sh` with `nix` missing — warns, does not fail the whole install.
4. Confirm Mason is not required for LSP/formatters when using the wrapped binary.
