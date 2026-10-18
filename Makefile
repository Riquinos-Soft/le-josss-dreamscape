GODOT ?= godot
PYTHON ?= python3

TESTS := \
	test_scandale.gd \
	test_v2_appearance.gd \
	test_v2_laboratory.gd \
	test_account_location.gd \
	test_touch_controls.gd \
	test_movement_direction.gd \
	test_keyboard_input.gd \
	test_item_lifecycle.gd \
	test_bag_inventory.gd \
	test_bag_ui.gd \
	test_bag_travel.gd \
	test_place_support.gd \
	test_courtyard.gd \
	test_camera_clearance.gd \
	test_home_exterior.gd \
	test_scan_movement.gd \
	test_connected_stairs.gd \
	test_lourizan_exterior.gd \
	test_lourizan_salon.gd \
	test_lourizan_dialogue.gd \
	test_location_travel.gd \
	test_street_character.gd \
	test_street_item.gd \
	test_street_scene.gd

.PHONY: lint format import test test-preview export-web check

lint:
	$(PYTHON) tools/check_docs.py
	gdformat --check game
	gdlint game

format:
	gdformat game

import:
	"$(GODOT)" --headless --path game --import --quit

test:
	@for test in $(TESTS); do \
		"$(GODOT)" --headless --resolution 1280x720 --path game --fixed-fps 60 --script "res://tests/$$test" || exit $$?; \
	done

export-web:
	mkdir -p build/web
	"$(GODOT)" --headless --path game --export-release Web ../build/web/index.html
	test -f build/web/index.html
	test -f build/web/index.wasm
	test -f build/web/index.pck

test-preview:
	"$(GODOT)" --headless --path game --script ../tools/export_appearance_fixture.gd
	node tools/test_appearance_preview.cjs

check: lint import test test-preview export-web
