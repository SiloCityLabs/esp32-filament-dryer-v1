.PHONY: help
SHELL := /bin/bash

CONFIG_PATH = config.yaml

# The default target will display help
help:
	@echo "Available targets:"
	@echo
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo

setup: ## Setup the environment
	rm -rf .venv && \
	python3 -m venv .venv && \
	source .venv/bin/activate && \
	pip install esphome

config: ## Generate the configuration
	source .venv/bin/activate && \
	esphome config $(CONFIG_PATH)

build: ## Build the firmware
	source .venv/bin/activate && \
	esphome compile $(CONFIG_PATH)

	# Dynamically get the correct build path from ESPHome
	BUILD_DIR=$$(find .esphome/build/ -maxdepth 1 -type d | grep -v "^.esphome/build/$$" | head -n 1); \
	echo "Detected build directory: $$BUILD_DIR"; \
	cp $$BUILD_DIR/.pioenvs/*/firmware.factory.bin firmware.bin

flash: ## Flash the firmware to test device
	source .venv/bin/activate && \
	esphome upload $(CONFIG_PATH) --device /dev/ttyACM0
