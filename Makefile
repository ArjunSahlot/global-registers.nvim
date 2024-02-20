.PHONY: test lint docs init

TESTS_DIR := tests/
PLUGIN_DIR := lua/

DOC_GEN_SCRIPT := ./scripts/docs.lua
MINIMAL_INIT := ./scripts/minimal_init.vim

test:
	nvim --headless --noplugin -u ${MINIMAL_INIT} \
		-c "PlenaryBustedDirectory ${TESTS_DIR} { minimal_init = '${MINIMAL_INIT}' }"

lint:
	luacheck ${PLUGIN_DIR}

docs:
	nvim --headless --noplugin -u ${MINIMAL_INIT} \
		-c "luafile ${DOC_GEN_SCRIPT}" -c 'qa'

init:
	@nvim --headless --noplugin \
	  -c "vimgrep /global_registers/gj **/*.lua **/*.vim Makefile" \
	  -c "cfdo %s/global_registers/$(name)/ge | update" \
	  -c "qa"
	@find . -depth -type d -name '*global_registers*' | \
	  while read dir; do mv "$$dir" "$${dir//global_registers/$(name)}"; done
	@find . -type f -name '*global_registers*' | \
	  while read file; do mv "$$file" "$${file//global_registers/$(name)}"; done
