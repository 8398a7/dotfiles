.DEFAULT_GOAL := help
.PHONY: help install clean check install-extensions export-extensions
help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ environment
install: ## install dotfiles with backups
	./scripts/install.sh
clean: ## remove owned links and restore backups
	./scripts/clean.sh
check: ## validate configuration and isolated behavior
	python3 scripts/check.py

##@ vscode
install-extensions: ## install vscode extensions
	./scripts/install-vscode-extensions.sh
export-extensions: ## export vscode extensions atomically
	./scripts/export-vscode-extensions.sh
