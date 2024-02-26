.PHONY: test lint docs

TESTS_DIR := tests/
PLUGIN_DIR := lua/

DOC_GEN_SCRIPT := ./scripts/docs.lua
MINIMAL_INIT := ./scripts/minimal_init.vim

test:
	echo "===> Testing..."
	nvim --headless --noplugin -u ${MINIMAL_INIT} \
		-c "PlenaryBustedDirectory ${TESTS_DIR} { minimal_init = '${MINIMAL_INIT}' }"

lint:
	echo "===> Linting..."
	luacheck ${PLUGIN_DIR}

docs:
	echo "===> Generating documentation..."
	nvim --headless --noplugin -u ${MINIMAL_INIT} \
		-c "luafile ${DOC_GEN_SCRIPT}" -c 'qa'

