# Makefile for PRISM - Policy Rigid Infrastructure for Secure Machines
# Simplifies common operations for deploying and managing PRISM

.PHONY: help install validate deploy deploy-tags syntax check test clean

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

# Default variables
INVENTORY ?= inventory.ini
CONFIG ?= config.yml
EXTRA_ARGS ?=

help: ## Show this help message
	@echo "$(GREEN)PRISM - Policy Rigid Infrastructure for Secure Machines$(NC)"
	@echo ""
	@echo "$(YELLOW)Available targets:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Examples:$(NC)"
	@echo "  make deploy                    # Deploy full hardening"
	@echo "  make deploy-tags TAGS=ssh      # Deploy only SSH hardening"
	@echo "  make validate                  # Validate before deployment"

install: ## Install Ansible dependencies (collections and roles)
	@echo "$(GREEN)Installing Ansible dependencies...$(NC)"
	ansible-galaxy install -r requirements.yml
	@echo "$(GREEN)Dependencies installed successfully$(NC)"

validate: ## Run pre-flight validation checks
	@echo "$(GREEN)Running PRISM validation...$(NC)"
	ansible-playbook -i $(INVENTORY) validate.yml -e "@$(CONFIG)" $(EXTRA_ARGS)

syntax: ## Check playbook syntax
	@echo "$(GREEN)Checking playbook syntax...$(NC)"
	ansible-playbook --syntax-check all.yml
	@echo "$(GREEN)Syntax check passed$(NC)"

check: syntax validate ## Run all checks (syntax + validation)

deploy: ## Deploy full PRISM hardening configuration
	@echo "$(GREEN)Deploying PRISM hardening...$(NC)"
	ansible-playbook -i $(INVENTORY) all.yml -e "@$(CONFIG)" $(EXTRA_ARGS)
	@echo "$(GREEN)Deployment complete$(NC)"

deploy-tags: ## Deploy specific components using tags (use TAGS=tag1,tag2)
ifndef TAGS
	@echo "$(RED)Error: TAGS variable not set$(NC)"
	@echo "Usage: make deploy-tags TAGS=ssh,firewall"
	@exit 1
endif
	@echo "$(GREEN)Deploying PRISM with tags: $(TAGS)$(NC)"
	ansible-playbook -i $(INVENTORY) all.yml -e "@$(CONFIG)" --tags $(TAGS) $(EXTRA_ARGS)

deploy-skip-tags: ## Deploy while skipping specific components (use SKIP_TAGS=tag1,tag2)
ifndef SKIP_TAGS
	@echo "$(RED)Error: SKIP_TAGS variable not set$(NC)"
	@echo "Usage: make deploy-skip-tags SKIP_TAGS=grub,users"
	@exit 1
endif
	@echo "$(GREEN)Deploying PRISM, skipping tags: $(SKIP_TAGS)$(NC)"
	ansible-playbook -i $(INVENTORY) all.yml -e "@$(CONFIG)" --skip-tags $(SKIP_TAGS) $(EXTRA_ARGS)

dry-run: ## Run deployment in check mode (no changes)
	@echo "$(GREEN)Running PRISM in dry-run mode...$(NC)"
	ansible-playbook -i $(INVENTORY) all.yml -e "@$(CONFIG)" --check --diff $(EXTRA_ARGS)

diff: ## Show what would change without applying
	@echo "$(GREEN)Showing PRISM changes...$(NC)"
	ansible-playbook -i $(INVENTORY) all.yml -e "@$(CONFIG)" --check --diff $(EXTRA_ARGS)

list-hosts: ## List all hosts in inventory
	@echo "$(GREEN)Listing hosts from inventory...$(NC)"
	ansible-playbook -i $(INVENTORY) all.yml --list-hosts

list-tasks: ## List all tasks that would be executed
	@echo "$(GREEN)Listing all tasks...$(NC)"
	ansible-playbook -i $(INVENTORY) all.yml -e "@$(CONFIG)" --list-tasks

list-tags: ## List all available tags
	@echo "$(GREEN)Available tags:$(NC)"
	@ansible-playbook -i $(INVENTORY) all.yml --list-tags

ping: ## Test connectivity to all hosts
	@echo "$(GREEN)Testing connectivity...$(NC)"
	ansible all -i $(INVENTORY) -m ping

clean: ## Clean up temporary files and caches
	@echo "$(GREEN)Cleaning up...$(NC)"
	rm -rf .ansible/
	rm -f *.retry
	rm -f ansible.log
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	@echo "$(GREEN)Cleanup complete$(NC)"

init-config: ## Create config.yml from example
	@if [ -f config.yml ]; then \
		echo "$(RED)config.yml already exists. Backup first or delete it.$(NC)"; \
		exit 1; \
	fi
	cp config.yml.example config.yml
	@echo "$(GREEN)Created config.yml from example. Edit it before deployment.$(NC)"

init-inventory: ## Create basic inventory.ini
	@if [ -f inventory.ini ]; then \
		echo "$(RED)inventory.ini already exists. Backup first or delete it.$(NC)"; \
		exit 1; \
	fi
	@echo "[staging]" > inventory.ini
	@echo "# Add your host IPs here" >> inventory.ini
	@echo "# 192.168.1.100" >> inventory.ini
	@echo "$(GREEN)Created inventory.ini. Add your hosts before deployment.$(NC)"

.DEFAULT_GOAL := help
