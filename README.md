# zfolio

A terminal portfolio for engineers who live in the shell.  
No dependencies. Pure bash.

---

## Requirements

- **bash 4.0+** — macOS ships bash 3.2; install a newer one via Homebrew
- A terminal with 256-color support (`TERM=xterm-256color` or equivalent)
- Recommended minimum width: **100 columns** for menu mode

```bash
# macOS — upgrade bash first
brew install bash
```

---

## Install

```bash
git clone https://github.com/shiloenix/zfolio
cd zfolio
./install.sh
```

The installer will:
- Detect your OS and pick the right install directory (`/usr/local/bin` or `/opt/homebrew/bin` on MacOS)
- Request `sudo` only if needed
- Verify the binary landed correctly
- Warn you if the install directory isn't in your `$PATH`

To uninstall:

```bash
./install.sh uninstall
```

---

# Run

```bash
# If installed system-wide
zfolio
 
# Or directly from the repo
./zfolio
```

---

## Modes
Zfolio is an interactive terminal-style portfolio that combines a traditional shell experience with a modern navigable menu system:
* Shell mode
* Browser mode
