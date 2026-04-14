SKILLS_DIR := $(HOME)/.claude/skills
RULES_DIR := $(HOME)/.claude/rules
SKILLS := c4-analyze c4-diagram debug add-tests respond-to-review review-pr fix-issue security-check
RULES := $(wildcard claude-rules/*.md)

.PHONY: install uninstall list

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
