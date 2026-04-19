SKILLS_DIR := $(HOME)/.claude/skills
RULES_DIR := $(HOME)/.claude/rules
SKILLS := c4-analyze c4-diagram debug add-tests respond-to-review review-pr fix-issue security-check
RULES := $(wildcard claude-rules/*.md)
LANGUAGES := $(notdir $(wildcard languages/*))

.PHONY: help install uninstall list \
        install-lang list-languages install-elisp

help:
	@echo "rulesets — Claude Code skills, rules, and language bundles"
	@echo ""
	@echo "  Global install (symlinks into ~/.claude/):"
	@echo "    make install             - Install skills and rules globally"
	@echo "    make uninstall           - Remove the symlinks"
	@echo "    make list                - Show install status"
	@echo ""
	@echo "  Per-project language rulesets:"
	@echo "    make install-lang LANG=<lang> PROJECT=<path> [FORCE=1]"
	@echo "    make install-elisp PROJECT=<path> [FORCE=1]   (shortcut)"
	@echo "    make list-languages     - Show available language bundles"
	@echo ""
	@echo "  FORCE=1 overwrites an existing CLAUDE.md (other files always overwrite)."
	@echo ""
	@echo "Available languages: $(LANGUAGES)"

install:
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

uninstall:
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

list:
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

# --- Per-project language rulesets ---

list-languages:
	@echo "Available language rulesets (languages/):"
	@for lang in $(LANGUAGES); do echo "  - $$lang"; done

install-lang:
	@test -n "$(LANG)"    || { echo "ERROR: set LANG=<language> (try: make list-languages)"; exit 1; }
	@test -n "$(PROJECT)" || { echo "ERROR: set PROJECT=<path>"; exit 1; }
	@bash scripts/install-lang.sh "$(LANG)" "$(PROJECT)" "$(FORCE)"

install-elisp:
	@$(MAKE) install-lang LANG=elisp PROJECT="$(PROJECT)" FORCE="$(FORCE)"
