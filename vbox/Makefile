REPODIR = $(HOME)/build
REPOURL = https://github.com/OCR-D/

OCRD_REPOS = core \
			 ocrd_kraken \
			 ocrd_tesserocr \
			 ocrd_olena \
			 ocrd_ocropy

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
