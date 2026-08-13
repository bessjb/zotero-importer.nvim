IMAGE ?= zotero-importer.nvim:test
ROOT := $(CURDIR)
DEMO_DB := /plugin/.tmp/test_zotero_demo.sqlite

.PHONY: build unit integration test demo-db nvim shell clean

build:
	docker build -t $(IMAGE) .

unit: build
	docker run --rm \
		-v "$(ROOT):/plugin" \
		-w /plugin/test \
		$(IMAGE) \
		lua5.1 test_zotero.lua

integration: build
	docker run --rm \
		-v "$(ROOT):/plugin" \
		-w /plugin \
		$(IMAGE) \
		nvim --headless -u NONE \
		--cmd "set rtp+=/plugin" \
		--cmd "set rtp+=/opt/sqlite.lua" \
		-c "lua dofile('/plugin/test/run_integration.lua')"

test: unit integration

demo-db: build
	mkdir -p .tmp
	docker run --rm \
		-v "$(ROOT):/plugin" \
		-w /plugin \
		$(IMAGE) \
		nvim --headless -u NONE \
		--cmd "set rtp+=/plugin" \
		-c "lua local db = dofile('/plugin/test/test_db_setup.lua'); db.setup_test_db('$(DEMO_DB)')" \
		-c 'qa!'

nvim: demo-db
	tmpdir=$$(mktemp -d); \
	trap 'rm -rf "$$tmpdir"' EXIT; \
	cp -a "$(ROOT)/." "$$tmpdir/"; \
	docker run --rm -it \
		-e TERM \
		-v "$$tmpdir:/plugin" \
		-w /plugin \
		$(IMAGE) \
		nvim --clean -u /opt/zotero-nvim-init.lua \
		/plugin/test/snippets/latex_snippet.tex

shell: build
	docker run --rm -it \
		-v "$(ROOT):/plugin" \
		-w /plugin \
		$(IMAGE) bash

clean:
	docker image rm $(IMAGE)
