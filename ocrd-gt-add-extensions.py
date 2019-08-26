#!/usr/bin/env python3
# pylint: disable=wrong-import-order, wrong-import-position


# # TODO
#
#     * [ ] Run sha256deep on bagsdir before bulk operation to understand what changed
#     * [ ] Anpassen der URL in PAGE-XML
#     * [X] Ersetzen von falschen Extensions (tif fuer jpg, jpg fuer png usw)
#     * [X] Fortschrittsanzeige grob


#  from ocrd_utils.logging import setOverrideLogLevel
#  setOverrideLogLevel('DEBUG')

import os
import click
from ocrd.decorators import ocrd_loglevel
from pathlib import Path

from ocrd import Workspace, Resolver
from ocrd_utils import (
    getLogger,
    pushd_popd,

    MIMETYPE_PAGE,
    EXT_TO_MIME
    #  MIME_TO_EXT
)

LOG = getLogger('update-bags')

#TODO PAGE-XMl

MIME_TO_EXT = {
    MIMETYPE_PAGE:          ".xml",
    "application/pdf":      ".pdf",
    "image/tiff":           ".tif",
    "image/tif":            ".tif",
    "image/jp2":            ".jp2",
    "image/png":            ".png",
    "image/jpg":            ".jpg",
    "image/jpeg":           ".jpg",
    "application/alto+xml": ".xml",
}

resolver = Resolver()

DOCS_REPO = Path(__file__).resolve(True).parent
UPDATE_BAGIT_SCRIPT = Path(DOCS_REPO, 'update-bagit')

def update_checksums(bagdir):
    with pushd_popd(bagdir):
        os.system('zsh "%s"' % UPDATE_BAGIT_SCRIPT)

resolver = Resolver()
def do_the_update(bagdir, non_local_urls=False):
    directory = Path(bagdir, 'data')
    if not Path(directory, 'mets.xml').exists():
        LOG.error("Something's wrong with OCRD-ZIP at %s, no data/mets.xml!", bagdir)
        return
    workspace = Workspace(resolver, directory=str(directory))
    with pushd_popd(directory):
        for f in workspace.mets.find_files():
            fp = Path(f.url)
            if not fp.exists() and not non_local_urls:
                LOG.debug("Skipping non-local file: %s", fp)
                continue
            ext = MIME_TO_EXT.get(f.mimetype)
            if not ext:
                LOG.error("No rule to translate '%s' to an extension. Skipping %s", f.mimetype, fp)
                continue
            if fp.suffix == ext:
                LOG.debug("Already has the right extension, %s", fp.name)
                continue
            if fp.suffix and fp.suffix in EXT_TO_MIME and fp.suffix != ext:
                LOG.warning("Has the WRONG extension, is '%s' should be '%s'", fp.suffix, ext)
                f.url = f.url[:-len(fp.suffix)]
            LOG.info('Renaming %s{,%s}', fp, ext)
            f.url = "%s%s" % (f.url, ext)
            if fp.exists():
                fp.rename('%s%s' % (fp, ext))
        workspace.save_mets()
        LOG.debug('Running bagit update script')
        update_checksums(bagdir)
    LOG.info("FINISHED: %s", bagdir)

@click.group()
@ocrd_loglevel
def cli(**kwargs):  # pylint: disable=unused-argument
    pass

@cli.command('one')
@click.option('-L', '--non-local-urls', help="Don't skip non-local files", is_flag=True, default=False)
@click.argument('bagdir', type=click.Path(dir_okay=True, writable=True, readable=False, resolve_path=True), required=True)
def update_one(bagdir, non_local_urls):
    """
    Update OCR-D bag
    """
    do_the_update(bagdir, non_local_urls=non_local_urls)

@cli.command('many')
@click.option('-L', '--non-local-urls', help="Don't skip non-local files", is_flag=True, default=False)
@click.argument('bagsdir', type=click.Path(dir_okay=True, writable=True, readable=False, resolve_path=True), required=True)
def update_many(bagsdir, non_local_urls):
    """
    Update many OCR-D bags at once

    BAGSDIR must contain only directories thaty contain unserialized OCRD-ZIP
    """
    # yes, that is bagsdir, bagdirs and bagdir. Deal with it 😎 🆒
    bagsdir = Path(bagsdir)
    bagdirs = [x for x in bagsdir.iterdir() if x.is_dir() and not x.name.startswith('.')]
    total = len(bagdirs)
    cur = 0
    for bagdir in bagdirs:
        LOG.info(">>>>> OCR-D-ZIP [%05d / %05d] %s", cur, total, bagdir)
        do_the_update(bagdir, non_local_urls=non_local_urls)
        cur += 1

if __name__ == '__main__':
    cli()
# pylint: disable=no-value-for-parameter
