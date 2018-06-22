REPODIR = $(HOME)/build
REPOURL = https://github.com/OCR-D/

# python2 modules. Default: $(OCRD_REPOS_PY2)
OCRD_REPOS_PY2 = ocrd_ocropy

# python3 modules. Default: $(OCRD_REPOS_PY3)
OCRD_REPOS_PY3 = ocrd_kraken ocrd_tesserocr ocrd-train

# OCRD_REPOS_PY3 = $(shell cd $(REPODIR);find  -maxdepth 1 -name 'ocrd*' -not -name 'ocrd_ocropy' -printf '%P\n')

# Repos to clone. Default: $(OCRD_REPOS)
OCRD_REPOS = $(OCRD_REPOS_PY2) $(OCRD_REPOS_PY3)


# BEGIN-EVAL makefile-parser --make-help Makefile

help:
	@echo ""
	@echo "  Targets"
	@echo ""
	@echo "    clone    Clone the repositories"
	@echo "    update   Update the repositories"
	@echo "    install  (Re-)Install the repos"
	@echo ""
	@echo "  Variables"
	@echo ""
	@echo "    OCRD_REPOS_PY3 Repos to clone. Default: $(OCRD_REPOS_PY3)"
	@echo "    OCRD_REPOS_PY2 Repos to clone. Default: $(OCRD_REPOS_PY2)"
	@echo "    OCRD_REPOS     Repos to clone. Default: $(OCRD_REPOS)"

# END-EVAL

# Clone the repositories
clone:
	cd $(REPODIR); \
	for repo in $(OCRD_REPOS);do \
		git clone --depth 1 $(REPOURL)/$$repo; \
	done

# Update the repositories
update:
	cd $(REPODIR); \
	for repo in $(OCRD_REPOS);do \
		git -C $$repo pull; \
	done

FILTER_NOISE = |grep -v '^Requirement' |grep -v '^make'

# (Re-)Install the repos
install:
	if [ "x" = "x$$VIRTUAL_ENV" ];then \
		echo "!! No virualenv set!!!" ;\
		echo "Run 'source \$$HOME/venv3' for Python3 (recommended)"  ;\
		echo "Run 'source \$$HOME/venv2' for Python2 (only for ocrd_ocropy)"  ;\
		exit 1 ;\
	fi
	pip install --upgrade ocrd $(FILTER_NOISE) ;\
	if [ "$$VIRTUAL_ENV" = *2 ];then \
		$(MAKE) $(OCRD_REPOS_PY2) ;\
	else \
		$(MAKE) $(OCRD_REPOS_PY3) ;\
	fi

$(OCRD_REPOS):
	-cd $(REPODIR)/$@; make deps install $(FILTER_NOISE)
