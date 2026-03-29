SKILLS_DIR := $(HOME)/.claude/skills
SKILLS := c4-analyze c4-diagram

.PHONY: install uninstall list

install:
	@mkdir -p $(SKILLS_DIR)
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
	@echo "done"

uninstall:
	@for skill in $(SKILLS); do \
		if [ -L "$(SKILLS_DIR)/$$skill" ]; then \
			rm "$(SKILLS_DIR)/$$skill"; \
			echo "  rm    $$skill"; \
		else \
			echo "  skip  $$skill (not a symlink)"; \
		fi \
	done
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
