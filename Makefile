# The default target of this Makefile is...
all::

# Define V=1 to have a more verbose compile.
#
# Define NO_GETTEXT if you don't want Git output to be translated.
# A translated Git requires GNU libintl or another gettext implementation.
#
# Define USE_GETTEXT_SCHEME and set it to 'fallthrough', if you don't trust
# the installed gettext translation of the shell scripts output.
#
# Define NO_MSGFMT_EXTENDED_OPTIONS if your implementation of msgfmt
# doesn't support GNU extensions like --check and --statistics
#
# Define DOCBOOK_XSL_172 if you want to format man pages with DocBook XSL v1.72
# (not v1.73 or v1.71).
#
# Define ASCIIDOC_ROFF if your DocBook XSL does not escape raw roff directives
# (versions 1.68.1 through v1.72).
#
# Define GNU_ROFF if your target system uses GNU groff.  This forces
# apostrophes to be ASCII so that cut&pasting examples to the shell
# will work.
#
# Define USE_ASCIIDOCTOR to use Asciidoctor instead of AsciiDoc to build the
# documentation.
#
# Define ASCIIDOCTOR_EXTENSIONS_LAB to point to the location of the Asciidoctor
# Extensions Lab if you have it available.
#
# Define GETTEXT_POISON if you are debugging the choice of strings marked
# for translation.  In a GETTEXT_POISON build, you can turn all strings marked
# for translation into gibberish by setting the GIT_GETTEXT_POISON variable
# (to any value) in your environment.
#

# Among the variables below, these:
#   gitexecdir
# can be specified as a relative path some/where/else;
# this is interpreted as relative to $(prefix) and "git" at
# runtime figures out where they are based on the path to the executable.
# Additionally, the following will be treated as relative by "git" if they
# begin with "$(prefix)/":
#   mandir
#   htmldir
#   localedir
# This can help installing the suite in a relocatable way.

prefix = $(HOME)
bindir = $(prefix)/bin
mandir = $(prefix)/share/man
gitexecdir = libexec/git-core
sharedir = $(prefix)/share
localedir = $(sharedir)/locale
htmldir = $(prefix)/share/doc/git-doc
lib = lib
# DESTDIR =

bindir_relative = $(patsubst $(prefix)/%,%,$(bindir))
mandir_relative = $(patsubst $(prefix)/%,%,$(mandir))
gitexecdir_relative = $(patsubst $(prefix)/%,%,$(gitexecdir))
localedir_relative = $(patsubst $(prefix)/%,%,$(localedir))
htmldir_relative = $(patsubst $(prefix)/%,%,$(htmldir))

export prefix bindir sharedir localedir

RM = rm -f
DIFF = diff
TAR = tar
FIND = find
INSTALL = install
XGETTEXT = xgettext
MSGFMT = msgfmt


### --- END CONFIGURATION SECTION ---

# Having this variable in your environment would break pipelines because
# you cause "cd" to echo its destination to stdout.  It can also take
# scripts to unexpected places.  If you like CDPATH, define it for your
# interactive shell sessions without exporting it.
unexport CDPATH

# what 'all' will build and 'install' will install in gitexecdir
ALL_PROGRAMS = git-filter-branch

# Set paths to tools early so that they can be used for version tests.
SHELL_PATH ?= /bin/sh
TEST_SHELL_PATH = $(SHELL_PATH)

ifneq ($(findstring s,$(MAKEFLAGS)),s)
ifndef V
	QUIET_GEN      = @echo '   ' GEN $@;
	QUIET_XGETTEXT = @echo '   ' XGETTEXT $@;
	QUIET_MSGFMT   = @echo '   ' MSGFMT $@;
	export V
	export QUIET_GEN
endif
endif

# Shell quote (do not use $(call) to accommodate ancient setups);

DESTDIR_SQ = $(subst ','\'',$(DESTDIR))
bindir_SQ = $(subst ','\'',$(bindir))
bindir_relative_SQ = $(subst ','\'',$(bindir_relative))
mandir_SQ = $(subst ','\'',$(mandir))
mandir_relative_SQ = $(subst ','\'',$(mandir_relative))
localedir_SQ = $(subst ','\'',$(localedir))
localedir_relative_SQ = $(subst ','\'',$(localedir_relative))
gitexecdir_SQ = $(subst ','\'',$(gitexecdir))
gitexecdir_relative_SQ = $(subst ','\'',$(gitexecdir_relative))
htmldir_relative_SQ = $(subst ','\'',$(htmldir_relative))
prefix_SQ = $(subst ','\'',$(prefix))

SHELL_PATH_SQ = $(subst ','\'',$(SHELL_PATH))
TEST_SHELL_PATH_SQ = $(subst ','\'',$(TEST_SHELL_PATH))

export DIFF TAR INSTALL DESTDIR SHELL_PATH


### Build rules

SHELL = $(SHELL_PATH)

.PHONY: doc man html
doc:
	$(MAKE) -C Documentation all

man:
	$(MAKE) -C Documentation man

html:
	$(MAKE) -C Documentation html

XGETTEXT_FLAGS = \
	--force-po \
	--add-comments=TRANSLATORS: \
	--msgid-bugs-address="Git Mailing List <git@vger.kernel.org>" \
	--from-code=UTF-8
XGETTEXT_FLAGS_SH = $(XGETTEXT_FLAGS) --language=Shell \
	--keyword=gettextln --keyword=eval_gettextln

## Note that this is meant to be run only by the localization coordinator
## under a very controlled condition, i.e. (1) it is to be run in a
## Git repository (not a tarball extract), (2) any local modifications
## will be lost.

po/git-filter-branch.pot: FORCE
	$(QUIET_XGETTEXT)$(XGETTEXT) -o$@ $(XGETTEXT_FLAGS_SH) git-filter-branch

.PHONY: pot
pot: po/git-filter-branch.pot

POFILES := $(wildcard po/*.po)
MOFILES := $(patsubst po/%.po,po/build/locale/%/LC_MESSAGES/git-filter-branch.mo,$(POFILES))

ifndef NO_GETTEXT
all:: $(MOFILES)
endif

po/build/locale/%/LC_MESSAGES/git-filter-branch.mo: po/%.po
	$(QUIET_MSGFMT)mkdir -p $(dir $@) && $(MSGFMT) -o $@ $<

### Testing rules

test:
	$(MAKE) -C t/ all

.PHONY: test

### Installation rules

ifneq ($(filter /%,$(firstword $(gitexecdir))),)
gitexec_instdir = $(gitexecdir)
else
gitexec_instdir = $(prefix)/$(gitexecdir)
endif
gitexec_instdir_SQ = $(subst ','\'',$(gitexec_instdir))
export gitexec_instdir

install: all
	$(INSTALL) -d -m 755 '$(DESTDIR_SQ)$(bindir_SQ)'
	$(INSTALL) -d -m 755 '$(DESTDIR_SQ)$(gitexec_instdir_SQ)'
	$(INSTALL) $(ALL_PROGRAMS) '$(DESTDIR_SQ)$(gitexec_instdir_SQ)'
ifndef NO_GETTEXT
	$(INSTALL) -d -m 755 '$(DESTDIR_SQ)$(localedir_SQ)'
	(cd po/build/locale && $(TAR) cf - .) | \
	(cd '$(DESTDIR_SQ)$(localedir_SQ)' && umask 022 && $(TAR) xof -)
endif

.PHONY: install-doc install-man install-html

install-doc:
	$(MAKE) -C Documentation install

install-man:
	$(MAKE) -C Documentation install-man

install-html:
	$(MAKE) -C Documentation install-html


### Maintainer's dist rules

GIT-VERSION-FILE: FORCE
	@$(SHELL_PATH) ./GIT-VERSION-GEN
-include GIT-VERSION-FILE

all::
	@echo git-filter-branch is just a shell script\; no build needed.

TARNAME = git-filter-branch-$(GIT_VERSION)
dist:
	git archive --format=tar \
		--prefix=$(TARNAME)/ HEAD^{tree} > $(TARNAME).tar
	@mkdir -p $(TARNAME)
	@echo $(GIT_VERSION) > $(TARNAME)/version
	$(TAR) rf $(TARNAME).tar \
		--owner=root --group=root \
		$(TARNAME)/version
	@$(RM) -r $(TARNAME)
	gzip -f -9 $(TARNAME).tar

htmldocs = git-filter-branch-htmldocs-$(GIT_VERSION)
manpages = git-filter-branch-manpages-$(GIT_VERSION)
.PHONY: dist-doc distclean
dist-doc:
	$(RM) -r .doc-tmp-dir
	mkdir .doc-tmp-dir
	$(MAKE) -C Documentation DESTDIR=./ \
		htmldir=../.doc-tmp-dir \
		install-html
	cd .doc-tmp-dir && $(TAR) cf ../$(htmldocs).tar .
	gzip -n -9 -f $(htmldocs).tar
	:
	$(RM) -r .doc-tmp-dir
	mkdir -p .doc-tmp-dir/man1
	$(MAKE) -C Documentation DESTDIR=./ \
		man1dir=../.doc-tmp-dir/man1 \
		install-man
	cd .doc-tmp-dir && $(TAR) cf ../$(manpages).tar .
	gzip -n -9 -f $(manpages).tar
	$(RM) -r .doc-tmp-dir

### Cleaning rules

distclean: clean

clean:
	$(RM) -r po/build/
	$(RM) -r $(TARNAME) .doc-tmp-dir
	$(RM) $(htmldocs).tar.gz $(manpages).tar.gz
	$(MAKE) -C Documentation/ clean
	$(MAKE) -C t/ clean

.PHONY: all install clean
.PHONY: FORCE
