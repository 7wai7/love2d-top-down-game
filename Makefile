.PHONY: lint

lint:
	@find . -name '*.lua' -not -path './.git/*' -exec luajit -b {} /dev/null \;
	@echo "Lua syntax OK"
