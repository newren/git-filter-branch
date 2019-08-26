# Run tests
#
# Copyright (c) 2005 Junio C Hamano
#

-include ../config.mak.autogen
-include ../config.mak

#GIT_TEST_OPTS = --verbose --debug
SHELL_PATH ?= $(SHELL)
TEST_SHELL_PATH ?= $(SHELL_PATH)
PERL_PATH ?= /usr/bin/perl
TAR ?= $(TAR)
RM ?= rm -f
PROVE ?= prove
DEFAULT_TEST_TARGET ?= test

ifdef TEST_OUTPUT_DIRECTORY
TEST_RESULTS_DIRECTORY = $(TEST_OUTPUT_DIRECTORY)/test-results
CHAINLINTTMP = $(TEST_OUTPUT_DIRECTORY)/chainlinttmp
else
TEST_RESULTS_DIRECTORY = test-results
CHAINLINTTMP = chainlinttmp
endif

# Shell quote;
SHELL_PATH_SQ = $(subst ','\'',$(SHELL_PATH))
TEST_SHELL_PATH_SQ = $(subst ','\'',$(TEST_SHELL_PATH))
PERL_PATH_SQ = $(subst ','\'',$(PERL_PATH))
TEST_RESULTS_DIRECTORY_SQ = $(subst ','\'',$(TEST_RESULTS_DIRECTORY))
CHAINLINTTMP_SQ = $(subst ','\'',$(CHAINLINTTMP))

T = $(sort $(wildcard t[0-9][0-9][0-9][0-9]-*.sh))
CHAINLINTTESTS = $(sort $(patsubst chainlint/%.test,%,$(wildcard chainlint/*.test)))
CHAINLINT = sed -f chainlint.sed

all: $(DEFAULT_TEST_TARGET)

test: pre-clean check-chainlint
	$(MAKE) aggregate-results-and-cleanup

failed:
	@failed=$$(cd '$(TEST_RESULTS_DIRECTORY_SQ)' && \
		grep -l '^failed [1-9]' *.counts | \
		sed -n 's/\.counts$$/.sh/p') && \
	test -z "$$failed" || $(MAKE) $$failed

prove: pre-clean check-chainlint
	@echo "*** prove ***"; $(PROVE) --exec '$(TEST_SHELL_PATH_SQ)' $(GIT_PROVE_OPTS) $(T) :: $(GIT_TEST_OPTS)
	$(MAKE) clean-except-prove-cache

$(T):
	@echo "*** $@ ***"; '$(TEST_SHELL_PATH_SQ)' $@ $(GIT_TEST_OPTS)

pre-clean:
	$(RM) -r '$(TEST_RESULTS_DIRECTORY_SQ)'

clean-except-prove-cache: clean-chainlint
	$(RM) -r 'trash directory'.* '$(TEST_RESULTS_DIRECTORY_SQ)'

clean: clean-except-prove-cache
	$(RM) .prove

clean-chainlint:
	$(RM) -r '$(CHAINLINTTMP_SQ)'

check-chainlint:
	@mkdir -p '$(CHAINLINTTMP_SQ)' && \
	err=0 && \
	for i in $(CHAINLINTTESTS); do \
		$(CHAINLINT) <chainlint/$$i.test | \
		sed -e '/^# LINT: /d' >'$(CHAINLINTTMP_SQ)'/$$i.actual && \
		diff -u chainlint/$$i.expect '$(CHAINLINTTMP_SQ)'/$$i.actual || err=1; \
	done && exit $$err

aggregate-results-and-cleanup: $(T)
	$(MAKE) aggregate-results
	$(MAKE) clean

aggregate-results:
	for f in '$(TEST_RESULTS_DIRECTORY_SQ)'/t*-*.counts; do \
		echo "$$f"; \
	done | '$(SHELL_PATH_SQ)' ./aggregate-results.sh

.PHONY: pre-clean $(T) aggregate-results clean check-chainlint clean-chainlint
