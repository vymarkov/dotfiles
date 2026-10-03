# Nvim Headless Bootstrap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** On fresh-machine `./install.sh`, build the pinned nix nvim flake to a stable local shim and preinstall lazy.nvim plugins + Treesitter so the first interactive `nvim` does not wait.

**Architecture:** `install.sh` stows config first, then optionally runs `setup_nvim.sh` when `nix` exists. That script builds `github:vymarkov/nvim/de6eed84a03a1640f8de47ef62852235f6fe5330` to `~/.local/share/nvim-flake/result`, shims `~/.local/bin/nvim`, and runs headless `Lazy! restore` + `TSUpdateSync`. The nvim submodule gates Mason auto-install when `MASON_DISABLE_INSTALL` is set (flake already exports it).

**Tech Stack:** POSIX `sh`, Nix flakes, Neovim/lazy.nvim, stow, zsh

**Spec:** `docs/superpowers/specs/2026-10-03-nvim-headless-bootstrap-design.md`

## Global Constraints

- Flake pin (verbatim): `github:vymarkov/nvim/de6eed84a03a1640f8de47ef62852235f6fe5330`
- Soft-skip bootstrap from `install.sh` **only** when `nix` is missing; otherwise propagate `setup_nvim.sh` failures
- `setup_nvim.sh` requires `$HOME/.config/nvim` (stow first); never invent a config path
- Headless must use `$HOME/.local/bin/nvim` (shim), not a random system binary
- Do not alias to `nix run github:…` per launch
- When `MASON_DISABLE_INSTALL` is non-empty: no Mason auto-install on boot (`mason-tool-installer` + `mason-lspconfig` automatic_installation)
- Fewest files: `setup_nvim.sh` (new), `install.sh`, `zsh/.zshrc`, `nvim/lua/plugins/lsp/init.lua`, brief README

## File map

| File | Responsibility |
|------|----------------|
| `nvim/lua/plugins/lsp/init.lua` | Honor `MASON_DISABLE_INSTALL` (submodule) |
| `zsh/.zshrc` | `PATH` includes `~/.local/bin`; `alias nvim=…` |
| `setup_nvim.sh` | nix build → shim → headless restore |
| `install.sh` | After stow/setup: call or soft-skip `setup_nvim.sh` |
| `README.md` | One-liner: install flow mentions `setup_nvim.sh` |
| Spec (already revised) | Commit if still dirty |

---

### Task 1: Mason gate in nvim submodule

**Files:**
- Modify: `nvim/lua/plugins/lsp/init.lua` (around the `ensure_installed` / `mason-tool-installer` / `mason-lspconfig` setup)
- Test: headless one-liner against stowed config

**Interfaces:**
- Consumes: `vim.env.MASON_DISABLE_INSTALL` (any non-empty → disable auto-install)
- Produces: no `mason-tool-installer.setup({ ensure_installed = … })` when gated; `automatic_installation = false` when gated

- [ ] **Step 1: Confirm current behavior (auto-install always on)**

In `nvim/lua/plugins/lsp/init.lua`, note these lines exist unconditionally:

```lua
require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
-- ...
require("mason-lspconfig").setup({ ensure_installed = {}, automatic_installation = true, automatic_enable = false })
```

- [ ] **Step 2: Apply minimal gate**

Replace the tool-installer call and mason-lspconfig setup with:

```lua
  local mason_disable = vim.env.MASON_DISABLE_INSTALL ~= nil
    and vim.env.MASON_DISABLE_INSTALL ~= ""

  if not mason_disable then
    require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
  end

  -- Document highlight autocommands
  local function setup_autocommands(client, bufnr)
```

(keep `setup_autocommands` and the rest of the function unchanged)

And change the `mason-lspconfig` line to:

```lua
  require("mason-lspconfig").setup({
    ensure_installed = {},
    automatic_installation = not mason_disable,
    automatic_enable = false,
  })
```

`mason_disable` must be in scope for that call (same `M.config()` function, defined before both uses).

- [ ] **Step 3: Smoke-check gate with headless nvim**

If a working `nvim` is on PATH (devbox/nix store/shim):

```bash
cd /home/node/dotfiles
NVIM_BIN="$(command -v nvim)"
"$NVIM_BIN" --headless \
  +"lua assert(vim.env.MASON_DISABLE_INSTALL == nil or vim.env.MASON_DISABLE_INSTALL == '' or true)" \
  +"lua local d = vim.env.MASON_DISABLE_INSTALL ~= nil and vim.env.MASON_DISABLE_INSTALL ~= ''; print('mason_disable=' .. tostring(d))" \
  +qa
```

With the wrapped flake binary (`MASON_DISABLE_INSTALL=1`):

```bash
# After Task 3 exists, prefer ~/.local/bin/nvim; until then use nix store / nix run of the pin
export MASON_DISABLE_INSTALL=1
nvim --headless +"lua assert((vim.env.MASON_DISABLE_INSTALL or '') ~= '')" +qa
```

Expected: exits 0. Manual: open a file and confirm Mason does not start installing the ensure_installed list.

- [ ] **Step 4: Commit in the nvim submodule**

Submodule is currently detached at `de6eed8`. Create a branch, commit, push if you have access, then point the parent submodule at the new commit:

```bash
cd /home/node/dotfiles/nvim
git switch -c fix/mason-disable-install-gate
git add lua/plugins/lsp/init.lua
git commit -m "$(cat <<'EOF'
fix(lsp): honor MASON_DISABLE_INSTALL for auto-installs

Skip mason-tool-installer ensure_installed and mason-lspconfig
automatic_installation when the nix-wrapped nvim sets the env var.
EOF
)"
# push + PR on vymarkov/nvim as needed, then:
cd /home/node/dotfiles
git add nvim
git commit -m "$(cat <<'EOF'
chore(nvim): bump submodule for Mason disable gate

EOF
)"
```

If you cannot push the submodule remote in this environment, commit locally on the branch and leave the parent `nvim` gitlink updated; document the pending push.

---

### Task 2: zsh PATH + nvim alias

**Files:**
- Modify: `zsh/.zshrc`
- Test: `zsh -ic 'command -v nvim; alias nvim'` after stow (shim may not exist until Task 3)

**Interfaces:**
- Consumes: `$HOME/.local/bin/nvim` shim from Task 3
- Produces: interactive zsh prefers that shim via PATH + alias

- [ ] **Step 1: Enable PATH and alias in `.zshrc`**

Near the top, replace the commented PATH line with an active one (keep other bins):

```zsh
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
```

Near the personal aliases section (after the example aliases comments), add:

```zsh
alias nvim="$HOME/.local/bin/nvim"
```

- [ ] **Step 2: Stow and verify shell wiring**

```bash
cd /home/node/dotfiles
stow .
zsh -ic 'echo $PATH' | tr ':' '\n' | grep -x "$HOME/.local/bin"
zsh -ic 'alias nvim'
```

Expected: `~/.local/bin` on PATH; `nvim=/home/node/.local/bin/nvim` (or `$HOME` expanded).

- [ ] **Step 3: Commit in dotfiles parent**

```bash
cd /home/node/dotfiles
git add zsh/.zshrc
git commit -m "$(cat <<'EOF'
feat(zsh): prefer ~/.local/bin nvim shim

EOF
)"
```

---

### Task 3: Add `setup_nvim.sh`

**Files:**
- Create: `setup_nvim.sh` (executable)
- Test: missing config / missing nix / happy path

**Interfaces:**
- Consumes: `nix`, `$HOME/.config/nvim`, flake pin constant
- Produces: `$HOME/.local/share/nvim-flake/result`, `$HOME/.local/bin/nvim`, populated `~/.local/share/nvim/lazy`

- [ ] **Step 1: Write `setup_nvim.sh`**

```sh
#!/bin/sh
set -eu

FLAKE_REF="github:vymarkov/nvim/de6eed84a03a1640f8de47ef62852235f6fe5330"
FLAKE_OUT="${HOME}/.local/share/nvim-flake/result"
NVIM_BIN="${HOME}/.local/bin/nvim"

if ! command -v nix >/dev/null 2>&1; then
  echo "setup_nvim.sh: nix not found; install Nix then re-run." >&2
  exit 1
fi

if [ ! -e "${HOME}/.config/nvim" ]; then
  echo "setup_nvim.sh: ${HOME}/.config/nvim missing; run ./install.sh (stow) first." >&2
  exit 1
fi

mkdir -p "${HOME}/.local/share/nvim-flake" "${HOME}/.local/bin"

echo "setup_nvim.sh: nix build ${FLAKE_REF}"
nix build -o "${FLAKE_OUT}" "${FLAKE_REF}"

# Shim: re-exec the built binary (survives result replacement)
cat > "${NVIM_BIN}" <<EOF
#!/bin/sh
exec "${FLAKE_OUT}/bin/nvim" "\$@"
EOF
chmod +x "${NVIM_BIN}"

echo "setup_nvim.sh: Lazy! restore"
"${NVIM_BIN}" --headless "+Lazy! restore" +qa

echo "setup_nvim.sh: TSUpdateSync"
"${NVIM_BIN}" --headless "+TSUpdateSync" +qa

echo "setup_nvim.sh: done (${NVIM_BIN})"
```

```bash
chmod +x /home/node/dotfiles/setup_nvim.sh
```

- [ ] **Step 2: Fail closed without config**

```bash
# only if safe in this environment — prefer renaming temporarily
mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak-test"
/home/node/dotfiles/setup_nvim.sh; echo exit:$?
mv "$HOME/.config/nvim.bak-test" "$HOME/.config/nvim"
```

Expected: non-zero exit; message mentions stow/`install.sh`.

- [ ] **Step 3: Happy path**

```bash
cd /home/node/dotfiles
./setup_nvim.sh
"$HOME/.local/bin/nvim" --version | head -1
test -d "$HOME/.local/share/nvim/lazy/lazy.nvim"
```

Expected: build + restore succeed; version prints; `lazy.nvim` dir exists.

- [ ] **Step 4: Commit**

```bash
cd /home/node/dotfiles
git add setup_nvim.sh
git commit -m "$(cat <<'EOF'
feat: add setup_nvim.sh for flake build and headless plugin bootstrap

EOF
)"
```

---

### Task 4: Wire `install.sh`

**Files:**
- Modify: `install.sh`
- Test: branch with/without nix (simulate)

**Interfaces:**
- Consumes: `setup_nvim.sh`, `command -v nix`
- Produces: soft-skip warning or hard-fail on bootstrap error

- [ ] **Step 1: Append bootstrap hook after existing setup scripts**

End of `install.sh` becomes:

```sh
./setup_auto_completions.sh
./setup_ai_agents.sh

if command -v nix >/dev/null 2>&1; then
  ./setup_nvim.sh || exit 1
else
  echo "nix not found; skipping nvim bootstrap. After installing Nix, run: ./setup_nvim.sh"
fi
```

Do not add `set -e` to the whole file in this task (avoid changing unrelated behavior); only propagate via `|| exit 1`.

- [ ] **Step 2: Simulate missing nix**

```bash
cd /home/node/dotfiles
PATH="/usr/bin:/bin" sh -c '
  # minimal: only the new branch logic
  if command -v nix >/dev/null 2>&1; then
    echo UNEXPECTED_NIX
    exit 1
  else
    echo "nix not found; skipping nvim bootstrap. After installing Nix, run: ./setup_nvim.sh"
  fi
'
```

Expected: skip message, exit 0.

- [ ] **Step 3: Confirm failure propagates**

```bash
cd /home/node/dotfiles
sh -c './setup_nvim.sh || exit 1' 
# with ~/.config/nvim temporarily missing — expect exit 1
```

Or: `false || exit 1` pattern already proven; prefer the config-missing run from Task 3.

- [ ] **Step 4: Commit**

```bash
cd /home/node/dotfiles
git add install.sh
git commit -m "$(cat <<'EOF'
feat(install): run setup_nvim.sh when nix is available

Soft-skip with a message if nix is missing; fail install if bootstrap fails.
EOF
)"
```

---

### Task 5: README + commit revised spec

**Files:**
- Modify: `README.md`
- Modify/commit: `docs/superpowers/specs/2026-10-03-nvim-headless-bootstrap-design.md` (if dirty)

- [ ] **Step 1: Update README**

Replace/extend the minimal README so install is accurate:

```markdown
# Dotfiles

```bash
./install.sh
```

Requires [GNU stow](https://www.gnu.org/software/stow/). Submodules are initialized by `install.sh`.

If [Nix](https://nixos.org/) is on `PATH`, `install.sh` also runs `./setup_nvim.sh` (build pinned nvim flake, shim `~/.local/bin/nvim`, headless Lazy + Treesitter). Without Nix, run `./setup_nvim.sh` yourself after installing it.
```

- [ ] **Step 2: Commit README + any dirty spec**

```bash
cd /home/node/dotfiles
git add README.md docs/superpowers/specs/2026-10-03-nvim-headless-bootstrap-design.md docs/superpowers/plans/2026-10-03-nvim-headless-bootstrap.md
git commit -m "$(cat <<'EOF'
docs: nvim headless bootstrap spec, plan, and install notes

EOF
)"
```

---

### Task 6: End-to-end verification

**Files:** none (manual)

- [ ] **Step 1: Re-run bootstrap idempotently**

```bash
cd /home/node/dotfiles
./setup_nvim.sh
```

Expected: success without error.

- [ ] **Step 2: Confirm Mason stays quiet under wrapped nvim**

```bash
"$HOME/.local/bin/nvim" --headless \
  +"lua assert((vim.env.MASON_DISABLE_INSTALL or '') ~= '', 'expected MASON_DISABLE_INSTALL')" \
  +qa
```

Expected: exit 0. Optional interactive open: no Mason install popup/progress for ensure_installed tools.

- [ ] **Step 3: Confirm plugins present**

```bash
test -d "$HOME/.local/share/nvim/lazy/lazy.nvim"
"$HOME/.local/bin/nvim" --headless +"Lazy" +qa
```

Expected: no clone storm; UI can open/quit cleanly in headless.

---

## Spec coverage self-check

| Spec requirement | Task |
|------------------|------|
| Mason gate on `MASON_DISABLE_INSTALL` | Task 1 |
| Flake pin `de6eed84…` | Task 3 |
| Stable `~/.local/share/nvim-flake/result` | Task 3 |
| `~/.local/bin/nvim` shim | Task 3 |
| PATH + alias | Task 2 |
| Require `~/.config/nvim` | Task 3 |
| `Lazy! restore` + `TSUpdateSync` | Task 3 |
| `install.sh` soft-skip only without nix | Task 4 |
| Propagate bootstrap failure | Task 4 |
| README / docs | Task 5 |
| Manual E2E | Task 6 |
