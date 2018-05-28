SHELL = /bin/bash
DESTDIR = _site

PANDOC = pandoc
export YHY_FILTER_SRC
export YHY_FILTER_BASEURL

content_src = content/%/README.org
content_dst = $(DESTDIR)/%/index.html
content_src_files = $(shell find content -type f -name 'README.org')
content_dst_files = \
	$(patsubst $(content_src),$(content_dst),$(content_src_files))

static_src = static/%
static_dst = $(DESTDIR)/%
static_src_files = $(shell find static -type f)
static_dst_files = \
	$(patsubst $(static_src),$(static_dst),$(static_src_files))

local_src_files = $(shell find content -type d -name '_*')
local_dst_files = \
	$(patsubst content/%,$(DESTDIR)/%,$(local_src_files))


.PHONY: update build dev local clean

update:
	scripts/update.sh

build: YHY_FILTER_BASEURL = https://github.com/yeonghoey/yeonghoey/raw/master
build: $(content_dst_files) $(static_dst_files)

dev: local
	pipenv run python scripts/dev.py

local: $(content_dst_files) $(static_dst_files) $(local_dst_files)

clean:
	-rm -rf $(DESTDIR)/*

$(content_dst): YHY_FILTER_SRC = $<
$(content_dst): $(content_src)
	mkdir -p "$(dir $@)"
	@env | grep '^YHY_'
	pipenv run $(PANDOC) \
		--standalone \
		--mathjax \
		--filter 'scripts/filter.py' \
		--output '$@' \
		'$<'

$(static_dst): $(static_src)
	mkdir -p "$(dir $@)"
	cp '$<' '$@'

$(local_dst_files):
	mkdir -p "$(dir $@)"
	ln -sf $(abspath $(patsubst $(DESTDIR)/%,content/%,$@)) $@
