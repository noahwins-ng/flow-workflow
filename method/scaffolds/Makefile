# Dev task runner. Targets map to workflow-profile.yaml (verify.*) so humans and the flow skills
# share one vocabulary. flow-init fills __PLACEHOLDERS__ from the profile.
.PHONY: help setup test lint format types check

help:  ## List targets
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | sed 's/:.*## /\t/'

setup:   ## First-time setup (deps + hooks)
	__SETUP_CMD__
	git config core.hooksPath .githooks

test:    ## Run the offline/fast test gate
	__TEST_CMD__

lint:    ## Lint
	__LINT_CMD__

format:  ## Auto-format
	__FORMAT_CMD__

types:   ## Type-check
	__TYPES_CMD__

check:   ## Everything CI runs, locally
	$(MAKE) lint format types test
