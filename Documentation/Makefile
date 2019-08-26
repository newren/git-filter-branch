# Guard against environment variables
MAN1_TXT =

MAN1_TXT += $(wildcard git-*.txt)

MAN_TXT = $(MAN1_TXT)
MAN_XML = $(patsubst %.txt,%.xml,$(MAN_TXT))
MAN_HTML = $(patsubst %.txt,%.html,$(MAN_TXT))

DOC_HTML = $(MAN_HTML)

DOC_MAN1 = $(patsubst %.txt,%.1,$(MAN1_TXT))

prefix ?= $(HOME)
bindir ?= $(prefix)/bin
htmldir ?= $(prefix)/share/doc/git-doc
mandir ?= $(prefix)/share/man
man1dir = $(mandir)/man1
# DESTDIR =

ASCIIDOC = asciidoc
ASCIIDOC_EXTRA =
ASCIIDOC_HTML = xhtml11
ASCIIDOC_DOCBOOK = docbook
ASCIIDOC_CONF = -f asciidoc.conf
ASCIIDOC_COMMON = $(ASCIIDOC) $(ASCIIDOC_EXTRA) $(ASCIIDOC_CONF) \
		-agit_version=$(GIT_VERSION)
TXT_TO_HTML = $(ASCIIDOC_COMMON) -b $(ASCIIDOC_HTML)
TXT_TO_XML = $(ASCIIDOC_COMMON) -b $(ASCIIDOC_DOCBOOK)
MANPAGE_XSL = manpage-normal.xsl
XMLTO = xmlto
XMLTO_EXTRA =
INSTALL ?= install
RM ?= rm -f
MAN_REPO = ../../git-manpages
HTML_REPO = ../../git-htmldocs

-include ../config.mak.autogen
-include ../config.mak

#
# For docbook-xsl ...
#	-1.68.1,	no extra settings are needed?
#	1.69.0,		set ASCIIDOC_ROFF?
#	1.69.1-1.71.0,	set DOCBOOK_SUPPRESS_SP?
#	1.71.1,		set ASCIIDOC_ROFF?
#	1.72.0,		set DOCBOOK_XSL_172.
#	1.73.0-,	no extra settings are needed
#

ifdef DOCBOOK_XSL_172
ASCIIDOC_EXTRA += -a git-asciidoc-no-roff
MANPAGE_XSL = manpage-1.72.xsl
else
	ifndef ASCIIDOC_ROFF
	# docbook-xsl after 1.72 needs the regular XSL, but will not
	# pass-thru raw roff codes from asciidoc.conf, so turn them off.
	ASCIIDOC_EXTRA += -a git-asciidoc-no-roff
	endif
endif
ifndef NO_MAN_BOLD_LITERAL
XMLTO_EXTRA += -m manpage-bold-literal.xsl
endif
ifdef DOCBOOK_SUPPRESS_SP
XMLTO_EXTRA += -m manpage-suppress-sp.xsl
endif

# Newer DocBook stylesheet emits warning cruft in the output when
# this is not set, and if set it shows an absolute link.  Older
# stylesheets simply ignore this parameter.
#
# Distros may want to use MAN_BASE_URL=file:///path/to/git/docs/
# or similar.
ifndef MAN_BASE_URL
MAN_BASE_URL = file://$(htmldir)/
endif
XMLTO_EXTRA += -m manpage-base-url.xsl

# If your target system uses GNU groff, it may try to render
# apostrophes as a "pretty" apostrophe using unicode.  This breaks
# cut&paste, so you should set GNU_ROFF to force them to be ASCII
# apostrophes.  Unfortunately does not work with non-GNU roff.
ifdef GNU_ROFF
XMLTO_EXTRA += -m manpage-quote-apos.xsl
endif

ifdef USE_ASCIIDOCTOR
ASCIIDOC = asciidoctor
ASCIIDOC_CONF =
ASCIIDOC_HTML = xhtml5
ASCIIDOC_DOCBOOK = docbook45
ASCIIDOC_EXTRA += -acompat-mode -atabsize=8
ASCIIDOC_EXTRA += -I. -rasciidoctor-extensions
ASCIIDOC_EXTRA += -alitdd='&\#x2d;&\#x2d;'
endif

SHELL_PATH ?= $(SHELL)
# Shell quote;
SHELL_PATH_SQ = $(subst ','\'',$(SHELL_PATH))

ifneq ($(findstring $(MAKEFLAGS),s),s)
ifndef V
	QUIET_ASCIIDOC	= @echo '   ' ASCIIDOC $@;
	QUIET_XMLTO	= @echo '   ' XMLTO $@;
	export V
endif
endif

all: html man

html: $(DOC_HTML)

man: man1
man1: $(DOC_MAN1)

install: install-man

install-man: man
	$(INSTALL) -d -m 755 $(DESTDIR)$(man1dir)
	$(INSTALL) -m 644 $(DOC_MAN1) $(DESTDIR)$(man1dir)

install-html: html
	$(INSTALL) -d -m 755 $(DESTDIR)$(htmldir)
	$(INSTALL) -m 644 $(DOC_HTML) $(DESTDIR)$(htmldir)

clean:
	$(RM) *.xml *.xml+ *.html *.html+ *.1
	$(RM) manpage-base-url.xsl

$(MAN_HTML): %.html : %.txt asciidoc.conf
	$(QUIET_ASCIIDOC)$(RM) $@+ $@ && \
	$(TXT_TO_HTML) -d manpage -o $@+ $< && \
	mv $@+ $@

manpage-base-url.xsl: manpage-base-url.xsl.in
	sed "s|@@MAN_BASE_URL@@|$(MAN_BASE_URL)|" $< > $@

%.1 : %.xml manpage-base-url.xsl
	$(QUIET_XMLTO)$(RM) $@ && \
	$(XMLTO) -m $(MANPAGE_XSL) $(XMLTO_EXTRA) man $<

%.xml : %.txt asciidoc.conf
	$(QUIET_ASCIIDOC)$(RM) $@+ $@ && \
	$(TXT_TO_XML) -d manpage -o $@+ $< && \
	mv $@+ $@

print-man1:
	@for i in $(MAN1_TXT); do echo $$i; done
