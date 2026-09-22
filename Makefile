.PHONY: lint test

lint:
	@find . -name '*.lua' -not -path './.git/*' -exec luajit -b {} /dev/null \;
	@echo "Lua syntax OK"

test:
	@luajit tests/world_test.lua
	@luajit tests/play_scene_test.lua
	@luajit tests/asset_manager_test.lua
	@luajit tests/sprite_sheet_loader_test.lua
	@luajit tests/engine_assets_test.lua
