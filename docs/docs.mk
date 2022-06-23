SHELL = /usr/bin/env bash

DOCS_IMAGE   = grafana/docs-base:latest
DOCS_PROJECT = writers-toolkit
DOCS_DIR     = sources

# This allows ports and base URL to be overridden, so services like ngrok.io can
# be used to share a local running docs instances.
DOCS_HOST_PORT    = 3002
DOCS_LISTEN_PORT  = 3002
DOCS_BASE_URL    ?= "localhost:$(DOCS_HOST_PORT)"

DOCS_VERSION = next

HUGO_REFLINKSERRORLEVEL ?= WARNING
DOCS_DOCKER_CONTAINER = $(DOCS_PROJECT)-docs

.PHONY: docs-docker-rm
docs-docker-rm:
	docker rm -f $(DOCS_DOCKER_CONTAINER)

.PHONY: docs-pull
docs-pull:
	docker pull $(DOCS_IMAGE)

.PHONY: docs
docs: ## Serve documentation locally.
docs: docs-pull
	@echo "Documentation will be served at:"
	@echo "http://$(DOCS_BASE_URL)/docs/$(DOCS_PROJECT)/$(DOCS_VERSION)/"
	@echo ""
	@if [[ -z $${NON_INTERACTIVE} ]]; then \
		read -p "Press a key to continue"; \
	fi
	docker run -it --name $(DOCS_DOCKER_CONTAINER) \
		-v $(CURDIR)/$(DOCS_DIR):/hugo/content/docs/$(DOCS_PROJECT)/$(DOCS_VERSION):ro,z \
		-e HUGO_REFLINKSERRORLEVEL=$(HUGO_REFLINKSERRORLEVEL) \
		-p $(DOCS_HOST_PORT):$(DOCS_LISTEN_PORT) \
		--rm $(DOCS_IMAGE) \
		make server
