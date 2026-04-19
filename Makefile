.DEFAULT_GOAL := help
SHELL := /bin/bash

SKILLS_DIR := $(HOME)/.claude/skills
RULES_DIR  := $(HOME)/.claude/rules
SKILLS     := c4-analyze c4-diagram debug add-tests respond-to-review review-pr fix-issue security-check \
              arch-design arch-decide arch-document arch-evaluate \
              brainstorm codify root-cause-trace five-whys prompt-engineering \
              playwright-js playwright-py frontend-design pairwise-tests
RULES      := $(wildcard claude-rules/*.md)
LANGUAGES  := $(notdir $(wildcard languages/*))

# Pick target project — use PROJECT= or interactive fzf over local .git dirs.
# Defined inline in each recipe (not via $(shell)) so fzf only runs when needed.
define pick_project_shell
	P="$(PROJECT)"; \
	if [ -z "$$P" ]; then \
		if ! command -v fzf >/dev/null 2>&1; then \
			echo "ERROR: PROJECT=<path> not set and fzf is not installed" >&2; \
			exit 1; \
		fi; \
		P=$$(find $$HOME -maxdepth 4 -name .git -type d 2>/dev/null \
			| sed 's|/\.git$$||' | sort \
			| fzf --prompt="Target project> " 2>/dev/null); \
		test -n "$$P" || { echo "No target selected." >&2; exit 1; }; \
	fi
endef

# Cross-platform package install helper (brew/apt/pacman)
define install_pkg
$(if $(shell command -v brew 2>/dev/null),brew install $(1),\
$(if $(shell command -v apt-get 2>/dev/null),sudo apt-get install -y $(1),\
$(if $(shell command -v pacman 2>/dev/null),sudo pacman -S --noconfirm $(1),\
$(error No supported package manager found (brew/apt-get/pacman)))))
endef

.PHONY: help install uninstall list \
        install-lang install-elisp install-python list-languages \
        diff lint deps

##@ General

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nrulesets — Claude Code skills, rules, and language bundles\n\nUsage: make \033[36m<target>\033[0m [PROJECT=<path>] [LANG=<lang>] [FORCE=1]\n"} \
		/^[a-zA-Z_-]+:.*##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } \
		/^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) }' $(MAKEFILE_LIST)
	@printf "\nAvailable languages: %s\n" "$(LANGUAGES)"

##@ Dependencies

deps: ## Install required tools (claude, node, jq, fzf, ripgrep, emacs, playwright)
	@echo "Checking dependencies..."
	@command -v claude >/dev/null 2>&1 && echo "  claude:     installed" || \
		{ echo "  claude:     installing via npm..."; npm install -g @anthropic-ai/claude-code; }
	@command -v node >/dev/null 2>&1 && echo "  node:       installed ($$(node --version))" || \
		{ echo "  node:       installing..."; $(call install_pkg,nodejs); }
	@command -v npm >/dev/null 2>&1 && echo "  npm:        installed" || \
		{ echo "  npm:        installing..."; $(call install_pkg,npm); }
	@command -v jq >/dev/null 2>&1 && echo "  jq:         installed" || \
		{ echo "  jq:         installing..."; $(call install_pkg,jq); }
	@command -v fzf >/dev/null 2>&1 && echo "  fzf:        installed" || \
		{ echo "  fzf:        installing..."; $(call install_pkg,fzf); }
	@command -v rg >/dev/null 2>&1 && echo "  ripgrep:    installed" || \
		{ echo "  ripgrep:    installing..."; $(call install_pkg,ripgrep); }
	@command -v emacs >/dev/null 2>&1 && echo "  emacs:      installed" || \
		{ echo "  emacs:      installing..."; $(call install_pkg,emacs); }
	@command -v uv >/dev/null 2>&1 && echo "  uv:         installed ($$(uv --version | awk '{print $$NF}'))" || \
		{ echo "  uv:         installing..."; $(call install_pkg,uv); }
	@if [ -d "$(CURDIR)/playwright-js" ]; then \
		if [ -d "$(CURDIR)/playwright-js/node_modules/playwright" ]; then \
			echo "  playwright (js):  installed (skill node_modules present)"; \
		else \
			echo "  playwright (js):  running skill setup (npm install + chromium download ~300 MB)..."; \
			(cd "$(CURDIR)/playwright-js" && npm run setup); \
		fi \
	else \
		echo "  playwright (js):  skipped (playwright-js/ not present)"; \
	fi
	@if [ -d "$(CURDIR)/playwright-py" ]; then \
		if command -v playwright >/dev/null 2>&1; then \
			echo "  playwright (py):  CLI installed ($$(playwright --version 2>&1 | head -1))"; \
		elif command -v uv >/dev/null 2>&1; then \
			echo "  playwright (py):  installing via uv tool (isolated venv)..."; \
			uv tool install playwright; \
			echo "                    (Chromium already cached by playwright-js step; no re-download.)"; \
		else \
			echo "  playwright (py):  skipped — install uv, then re-run 'make deps'."; \
		fi; \
		echo "                    Per-project library import: add 'playwright' to your project's venv"; \
		echo "                    (e.g. 'uv add playwright' or 'pip install playwright' inside .venv)."; \
	else \
		echo "  playwright (py):  skipped (playwright-py/ not present)"; \
	fi
	@echo "Done."

##@ Global install (symlinks into ~/.claude/)

install: ## Symlink skills and rules into ~/.claude/
	@mkdir -p $(SKILLS_DIR) $(RULES_DIR)
	@echo "Skills:"
	@for skill in $(SKILLS); do \
		if [ -L "$(SKILLS_DIR)/$$skill" ]; then \
			echo "  skip  $$skill (already linked)"; \
		elif [ -e "$(SKILLS_DIR)/$$skill" ]; then \
			echo "  WARN  $$skill exists and is not a symlink — skipping"; \
		else \
			ln -s "$(CURDIR)/$$skill" "$(SKILLS_DIR)/$$skill"; \
			echo "  link  $$skill → $(SKILLS_DIR)/$$skill"; \
		fi \
	done
	@echo ""
	@echo "Rules:"
	@for rule in $(RULES); do \
		name=$$(basename $$rule); \
		if [ -L "$(RULES_DIR)/$$name" ]; then \
			echo "  skip  $$name (already linked)"; \
		elif [ -e "$(RULES_DIR)/$$name" ]; then \
			echo "  WARN  $$name exists and is not a symlink — skipping"; \
		else \
			ln -s "$(CURDIR)/$$rule" "$(RULES_DIR)/$$name"; \
			echo "  link  $$name → $(RULES_DIR)/$$name"; \
		fi \
	done
	@echo ""
	@echo "done"

uninstall: ## Remove global symlinks from ~/.claude/
	@echo "Skills:"
	@for skill in $(SKILLS); do \
		if [ -L "$(SKILLS_DIR)/$$skill" ]; then \
			rm "$(SKILLS_DIR)/$$skill"; \
			echo "  rm    $$skill"; \
		else \
			echo "  skip  $$skill (not a symlink)"; \
		fi \
	done
	@echo ""
	@echo "Rules:"
	@for rule in $(RULES); do \
		name=$$(basename $$rule); \
		if [ -L "$(RULES_DIR)/$$name" ]; then \
			rm "$(RULES_DIR)/$$name"; \
			echo "  rm    $$name"; \
		else \
			echo "  skip  $$name (not a symlink)"; \
		fi \
	done
	@echo ""
	@echo "done"

list: ## Show global install status
	@echo "Skills:"
	@for skill in $(SKILLS); do \
		if [ -L "$(SKILLS_DIR)/$$skill" ]; then \
			echo "  ✓ $$skill (installed)"; \
		else \
			echo "  - $$skill"; \
		fi \
	done
	@echo ""
	@echo "Rules:"
	@for rule in $(RULES); do \
		name=$$(basename $$rule); \
		if [ -L "$(RULES_DIR)/$$name" ]; then \
			echo "  ✓ $$name (installed)"; \
		else \
			echo "  - $$name"; \
		fi \
	done

##@ Per-project language bundles

list-languages: ## List available language bundles
	@echo "Available language rulesets (languages/):"
	@for lang in $(LANGUAGES); do echo "  - $$lang"; done

install-lang: ## Install language ruleset (LANG=<lang> [PROJECT=<path>] [FORCE=1])
	@test -n "$(LANG)" || { echo "ERROR: set LANG=<language>"; exit 1; }
	@$(pick_project_shell); \
	bash scripts/install-lang.sh "$(LANG)" "$$P" "$(FORCE)"

install-elisp: ## Install Elisp bundle ([PROJECT=<path>] [FORCE=1])
	@$(MAKE) install-lang LANG=elisp PROJECT="$(PROJECT)" FORCE="$(FORCE)"

install-python: ## Install Python bundle ([PROJECT=<path>] [FORCE=1])
	@$(MAKE) install-lang LANG=python PROJECT="$(PROJECT)" FORCE="$(FORCE)"

##@ Compare & validate

diff: ## Show drift between installed ruleset and repo source (LANG=<lang> [PROJECT=<path>])
	@test -n "$(LANG)" || { echo "ERROR: set LANG=<language>"; exit 1; }
	@$(pick_project_shell); \
	bash scripts/diff-lang.sh "$(LANG)" "$$P"

lint: ## Validate ruleset structure (headings, Applies-to, shebangs, exec bits)
	@bash scripts/lint.sh
