GODOT ?= godot

TESTS := \
	test_movement_direction.gd \
	test_keyboard_input.gd \
	test_item_lifecycle.gd \
	test_courtyard.gd \
	test_street_scene.gd

.PHONY: lint format import test export-web check

lint:
	gdformat --check game
	gdlint game

format:
	gdformat game

import:
	"$(GODOT)" --headless --path game --import --quit

test:
	@for test in $(TESTS); do \
		"$(GODOT)" --headless --path game --script "res://tests/$$test" || exit $$?; \
	done

export-web:
	mkdir -p build/web
	"$(GODOT)" --headless --path game --export-release Web ../build/web/index.html
	test -f build/web/index.html
	test -f build/web/index.wasm
	test -f build/web/index.pck

check: lint import test export-web
