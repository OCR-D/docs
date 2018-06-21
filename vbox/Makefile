REPODIR = $(HOME)/build
REPOURL = https://github.com/OCR-D/

# Repos to clone. Default: "$(OCRD_REPOS)"
OCRD_REPOS = core \
			 ocrd_kraken \
			 ocrd_tesserocr \
			 ocrd_ocropy

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
	@echo "    OCRD_REPOS  Repos to clone. Default: "$(OCRD_REPOS)""

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

# (Re-)Install the repos
install:
	if [[ -z "$$VIRTUAL_ENV" ]];then \
		echo "!! No virualenv set!!!" ;\
		echo "Run 'source $HOME/venv3' for Python3 (recommended)"  ;\
		echo "Run 'source $HOME/venv2' for Python2 (only for ocrd_ocropy)"  ;\
		exit 1 ;\
	fi
	for repo in $(OCRD_REPOS);do \
		cd $(REPODIR)/$$repo ;\
		pip install -r requirements.txt ;\
		pip install -e . ;\
	done
