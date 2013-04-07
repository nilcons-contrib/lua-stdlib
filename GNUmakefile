## maintainer rules.

dont-forget-to-bootstrap = $(wildcard Makefile)

ifeq ($(dont-forget-to-bootstrap),)

Makefile: Makefile.in
	./configure
	$(MAKE)

Makefile.in:
	autoreconf --force --verbose --install

else

# Use 'make check V=1' for verbose output, or set SPECL_OPTS to
# pass alternative options to specl command.
SPECL_OPTS ?= $(specl_verbose_$(V))
specl_verbose_ = $(specl_verbose_$(AM_DEFAULT_VERBOSITY))
specl_verbose_0 =
specl_verbose_1 = --verbose --formatter=report

include Makefile

ROCKSPEC_ENV	  = $(LUA_ENV)
MKROCKSPECS 	  = $(ROCKSPEC_ENV) $(LUA) $(srcdir)/mkrockspecs.lua
ROCKSPEC_TEMPLATE = $(srcdir)/$(PACKAGE)-rockspec.lua

LUA_BINDIR ?= $(shell which $(LUA) |sed 's|/[^/]*$$||')
LUA_INCDIR ?= `cd $(LUA_BINDIR)/../include && pwd`
LUA_LIBDIR ?= `cd $(LUA_BINDIR)/../lib && pwd`

luarocks-config.lua: GNUmakefile
	$(AM_V_GEN){						\
	  echo 'rocks_trees = { "$(abs_srcdir)/luarocks" }';	\
	  echo 'variables = {';					\
	  echo '  LUA = "$(LUA)",';				\
	  echo '  LUA_BINDIR = "'$(LUA_BINDIR)'",';		\
	  echo '  LUA_INCDIR = "'$(LUA_INCDIR)'",';		\
	  echo '  LUA_LIBDIR = "'$(LUA_LIBDIR)'",';		\
	  echo '}';						\
	} > '$@'

rockspecs: luarocks-config.lua $(srcdir)/mkrockspecs.lua
	$(AM_V_at)rm -f *.rockspec
	@echo "  GEN      $(PACKAGE)-$(VERSION)-1.rockspec"
	$(AM_V_at)$(MKROCKSPECS) $(PACKAGE) $(VERSION) $(ROCKSPEC_TEMPLATE)
	@echo "  GEN      $(PACKAGE)-git-1.rockspec"
	$(AM_V_at)$(MKROCKSPECS) $(PACKAGE) git $(ROCKSPEC_TEMPLATE)

GIT ?= git

tag-release:
	$(GIT) diff --exit-code && \
	$(GIT) tag -f -a -m "Release tag" v$(VERSION)

define unpack-distcheck-release
	rm -rf $(PACKAGE)-$(VERSION)/ && \
	tar zxf ../$(PACKAGE)/$(PACKAGE)-$(VERSION).tar.gz && \
	cp -a -f $(PACKAGE)-$(VERSION)/* . && \
	rm -rf $(PACKAGE)-$(VERSION)/ && \
	echo "unpacked $(PACKAGE)-$(VERSION).tar.gz over current directory" && \
	echo './configure && make all rockspecs' && \
	./configure --version && ./configure && \
	$(MAKE) all rockspecs
endef

check-in-release: distcheck
	cd ../$(PACKAGE)-release && \
	$(unpack-distcheck-release) && \
	$(GIT) add . && \
	$(GIT) commit -a -m "Release v$(VERSION)" && \
	$(GIT) tag -f -a -m "Full source release tag" release-v$(VERSION)


## To test the release process without publishing upstream, use:
##   make release WOGER=: GIT_PUBLISH=:
GIT_PUBLISH ?= $(GIT)
WOGER ?= woger

WOGER_ENV = LUA_INIT= LUA_PATH='$(abs_srcdir)/?-git-1.rockspec'
WOGER_OUT = $(WOGER_ENV) $(LUA) -l$(PACKAGE) -e

release: rockspecs
	$(MAKE) tag-release && \
	$(MAKE) check-in-release && \
	$(GIT_PUBLISH) push && $(GIT_PUBLISH) push --tags && \
	LUAROCKS_CONFIG=$(abs_srcdir)/luarocks-config.lua luarocks \
	  --tree=$(abs_srcdir)/luarocks build $(PACKAGE)-$(VERSION)-1.rockspec && \
	$(WOGER) lua \
	  package=$(PACKAGE) \
	  package_name=$(PACKAGE_NAME) \
	  version=$(VERSION) \
	  notes=release-notes-$(VERSION) \
	  home="`$(WOGER_OUT) 'print (description.homepage)'`" \
	  description="`$(WOGER_OUT) 'print (description.summary)'`"

endif
