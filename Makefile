.PHONY: lint test

lint:
	@find . -name '*.lua' -not -path './.git/*' -exec luajit -b {} /dev/null \;
	@echo "Lua syntax OK"

test:
	@luajit tests/world_test.lua
	@luajit tests/play_scene_test.lua
