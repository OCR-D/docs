# Cookbook OCR-D

> A set of recipes for common tasks and solutions for common problems developing and using software within OCR-D.

<!-- BEGIN-MARKDOWN-TOC -->
* [Introduction](#introduction)
	* [Scope and purpose of the OCR-D cookbook](#scope-and-purpose-of-the-ocr-d-cookbook)
	* [Other OCR-D documentation ](#other-ocr-d-documentation-)
* [Bootstrapping](#bootstrapping)
	* [Ubuntu Linux](#ubuntu-linux)
	* [Essential system packages](#essential-system-packages)
	* [Python API and CLI](#python-api-and-cli)
* [Python setup](#python-setup)
	* [Create virtualenv](#create-virtualenv)
	* [Activate virtualenv](#activate-virtualenv)
	* [Install `ocrd` in virtualenv](#install-ocrd-in-virtualenv)
* [Generic setup](#generic-setup)
* [From image to transcription](#from-image-to-transcription)
	* [Requirements](#requirements)
	* [OCR-D workflow](#ocr-d-workflow)
	* [Installation](#installation)
		* [Python & OCR-D tools](#python---ocr-d-tools)
		* [Git](#git)
		* [KRAKEN, OLENA, TESSEROCR, OCROPY](#kraken-olena-tesserocr-ocropy)
* [Workflows](#workflows)
	* [Binarize one image without existing METS file.](#binarize-one-image-without-existing-mets-file)
	* [Binarize all images of a METS file.](#binarize-all-images-of-a-mets-file)
	* [Binarize one image of a METS file.](#binarize-one-image-of-a-mets-file)
	* [Get Ground Truth from OCR-D ](#get-ground-truth-from-ocr-d-)
	* [Installing a MP executable](#installing-a-mp-executable)
	* [Tools for MP](#tools-for-mp)
		* [Getting files referenced inside METS](#getting-files-referenced-inside-mets)
		* [Getting files referenced inside METS](#getting-files-referenced-inside-mets-1)
* [FAQ](#faq)
	* [Question: After fixing error 'ocrd workspace validate' will still fail](#question-after-fixing-error--ocrd-workspace-validate--will-still-fail)
* [Links](#links)

<!-- END-MARKDOWN-TOC -->

## Introduction

This document, the "OCR-D cookbook" helps developers writing software and using
tools within the OCR-D ecosystem.

OCR-D is an initiative to improve text recognition within the context of mass digitization in cultural heritage institutions, with a strong focus on historical documents (16th - 19th century).

### Scope and purpose of the OCR-D cookbook

The OCR-D cookbook is a collection of concise recipes that provide pragmatic advise on how to

  * bootstrap a development environment, 
  * work with the `ocrd` command line tool,
  * manipulate METS and PAGE documents,
  * create [spec](https://ocr-d-github.com)

### Other OCR-D documentation 

 - [Specification](https://ocr-d.github.io)
 - [Glossary](https://ocr-d.github.io/glossary)

## Bootstrapping

### Ubuntu Linux

OCR-D development is targeted towards Ubuntu Linux >= 18.04 since it is free,
widely used and well-documented.

Most of the setup will be the same for other Debian-based Linuxes and older
Ubuntu versions. You might run into problems with outdated system packages
though.

In particular, it can be tricky at times to install `tesseract` at the right
version. Try [alex-p's PPA](https://launchpad.net/~alex-p/+archive/ubuntu/tesseract-ocr) or build
tesseract from source.

### Essential system packages

```sh
sudo apt install \
  git \
  build-essential \
  python python-pip \
  python3 python3-pip \
  libimage-exiftool-perl \
  libxml2-utils
```

  * `git`: Version control, [OCR-D uses git extensively](https://github.com/OCR-D)
  * `build-essential`: Installs `make` and C/C++ compiler
  * `python`: Python 2.7 for legacy applications like `ocropy`
  * `python3`: Current version of Python on which [the OCR-D software core stack](https://github.com/OCR-D/core) is built
  * `pip`/`pip3`: Python package management

### Python API and CLI

The OCR-D toolkit is based on a [Python API](https://ocr-d.github.io/core) that
you can reuse [if you are developing software in Python](#python-setup).

This API is exposed via a command line tool `ocrd`. This CLI offers much of the
same functionality of the API without the need to write Python code and can be readily
integrated into shell scripts and external command callouts in your code.

So, If you [do not intend to code in Python](#generic-setup) or want to wrap existing/legacy tools, a
major part of the functionality of the API is available as a command line tool
`ocrd`.

## Python setup

### Create virtualenv

We strongly recommend using `virtualenv` (or similar tools if they are more
familiar to you) over system-wide installation of python packages. It reduces
the amount of pain supporting multiple Python versions and allows you to test
your software in various configurations while you develop it, spinning up and
tearing down environments as necessary.

```sh
sudo apt install \
  python3-virtualenv \
  python-virtualenv # If you require Python2 compat
```

Create a `virtualenv` in an easy to remember or easy-to-search-shell-history-for location:

```sh
virtualenv -p 3.6 $HOME/ocrd-venv3
virtualenv -p 2.7 $HOME/ocrd-venv2 # If you require Python2 compat
```

### Activate virtualenv

You need to activate this virtual environment whenever you open a new terminal:

```sh
source $HOME/ocrd-venv3/bin/activate
```

If you tend to forget sourcing the script before working on your code, add
`source $HOME/ocrd-venv3` to the end of your `.bashrc`/`.zshrc` file and log
out and back in.

### Install `ocrd` in virtualenv

Make sure, the [`virtualenv` is activated](#activate-virtualenv) and install [`ocrd`](https://pypi.org/projects/ocrd) with pip:

```sh
pip install ocrd
```

## Generic setup

In this variant, you still need to install the `ocrd` Python package but since
it's only used for its CLI (and as a depencency for Python-based OCR-D
software), you can install it system-wide:

```sh
pip install ocrd
```

## From image to transcription

### Requirements

OS     | Linux (Ubuntu 18.04)
------:|----
Python | 3.5 or higher
GIT     | 

### OCR-D workflow

The workflow consits of several steps from the image with some additional metadata to the textual content of the image. The tools used to generate the text are divided in the following categories:

- Image preprocessing
- Layout analysis
- Text recognition and optimization
- Model training
- Long-term preservation
- Quality assurance

The workflow may be divided in the following steps:

- preprocessing/characterization
- preprocessing/optimization
- preprocessing/optimization/cropping
- preprocessing/optimization/deskewing
- preprocessing/optimization/despeckling
- preprocessing/optimization/dewarping
- preprocessing/optimization/binarization
- preprocessing/optimization/grayscale_normalization
- layout/segmentation
- layout/segmentation/region
- layout/segmentation/line
- layout/segmentation/word
- layout/segmentation/classification
- layout/analysis
- recognition/text-recognition
- recognition/font-identification

### Installation

#### Python & OCR-D tools

```shell=
# Step 1: Check/Install python
# ----------------------------
# Version 3.5 or higher
python3 --version 
sudo apt install python3
# Step 2: Check/Install pip (Packagemanagement system for Python) 
# -------------------------------------------
# Version 9.0.1 or higher?
pip --version
sudo apt install python-pip
# Step 3: Check/Install OCR-D Tools
# -------------------------------------------
which ocrd
sudo pip install ocrd
# -----------
# Alternative
# -----------
# Step 3: Install OCR-D Tools from GitHub
# -------------------------------------------
# Step 3a: Check/Install git and dependencies
```

See subsection [git](#git)

```shell=
# Step 3b: Clone repository from OCR-D
# Create Working Directory
$ mkdir -p ~/projects/OCR-D
# Change to Working Directory
$ cd ~/projects/OCR-D
# Clone repository
$ git clone https://github.com/OCR-D/core
# Step 3c: Create OCR-D Tools
$ cd core
$ make deps-ubuntu deps-pip install
# Test Installation
$ ocrd --version
ocrd, version 0.3.1
$ ocrd
Usage: ocrd [OPTIONS] COMMAND [ARGS]...

  CLI to OCR-D

Options:
  --help  Show this message and exit.

Commands:
  bashlib           Work with bash library
  generate-swagger  Generate Swagger schema from ocrd-tool.json...
  ocrd-tool         Work with ocrd-tool.json
  process           Execute OCR-D processors for a METS file...
  server            Start OCR-D web services
  workspace         Working with workspace

# That's it!
# You are now ready to test/execute your algorithms.
```

#### Git

```shell=
# Step 1: Check/Install git
# Version 2.10 or higher
$ git --version
git: Command not found
$ sudo apt install git
# Step 2: Check/Install make
$ make --version
make: Command not found
$ sudo apt install make
```

#### KRAKEN, OLENA, TESSEROCR, OCROPY

```shell=
# Step 0: Check/Install git and dependencies
```

See subsection [git](#git)

```shell=
# Step 1: Clone repositories
# Step 1a: KRAKEN
$ cd ~/projects/OCR-D
$ git clone https://github.com/OCR-D/ocrd_kraken
$ cd ocrd_kraken/
$ make deps-pip
$ make install
# Step 1b: Test installation
$ ocrd-kraken-binarize --version
Version 0.0.1, ocrd/core 0.3.1
```

## Workflows

### Binarize one image without existing METS file.

```shell=
# Step 0: Create Workspace & METS file 
# ------------------------
# Step 0a: Create workspace including METS file in subdir `./ws1`
$ ocrd workspace -d ws1 create
$ cd ws1  
# Step 0b: Validate workspace
$ ocrd workspace validate 
<report valid="false">
  <error>METS has no unique identifier</error>
  <error>No files</error>
</report>
# Step 0c: Add identifier to METS file
$ ocrd workspace set-id 'http://resolver.staatsbibliothek-berlin.de/SBB0000F29300000000'
$ ocrd workspace validate
<report valid="false">
  <error>No files</error>
</report>
# Step 1: Download tiff image
# ---------------------------
$ wget -O PPN767137728_00000005.tif "http://ngcs.staatsbibliothek-berlin.de/?action=metsImage&format=tif&metsFile=PPN767137728&divID=PHYS_0005&original=true"


# Step 2: Add image to METS
# -------------------------
# Be aware, that the ID and the GROUPID have to identical if the referenced image represents the original image 
$ ocrd workspace add --file-grp OCR-D-IMG --file-id OCR-D-IMG_0001 --group-id OCR-D-IMG_0001 --mimetype image/tiff PPN767137728_00000005.tif

# Step 3: Validate workspace
# --------------------------
$ ocrd workspace validate 
<report valid="true">
</report>

# Step 3a: Clone workspace (optional)
# -----------------------------------
# Create new directory and clone workspace to this directory
$ mkdir ../workspace2; cd ../workspace2
$ ocrd workspace clone --download-all $OLDPWD/mets.xml 
# Show all files (use --help to see all parameters)
$ ocrd workspace find
file:///path/to/new/workspace/OCR-D-IMG/PPN767137728_00000005.tif

# Step 4: Execute binarization of image
# -------------------------------------
```

See subsection [git](#git)

```shell=
# Step 4a: Install KRAKEN see [Installation KRAKEN] (#KRAKEN, OLENA, TESSEROCR, OCROPY)
```

See subsection [Install KRAKEN](#KRAKEN-OLENA-TESSEROCR-OCROPY)

```shell=
# Step 4b: List all available tools
$ ocrd ocrd-tool   ~/projects/OCR-D/ocrd_kraken/ocrd-tool.json list-tools
  ocrd-kraken-binarize
  ocrd-kraken-ocr
  ocrd-kraken-segment
# Step 4c: List attributes of 'ocrd-kraken-binarize'
$ ocrd ocrd-tool   ~/projects/OCR-D/ocrd_kraken/ocrd-tool.json tool ocrd-kraken-binarize description
  Binarize images with kraken
$ ocrd ocrd-tool   ~/projects/OCR-D/ocrd_kraken/ocrd-tool.json tool ocrd-kraken-binarize categories
  Image preprocessing
$ ocrd ocrd-tool   ~/projects/OCR-D/ocrd_kraken/ocrd-tool.json tool ocrd-kraken-binarize steps
  preprocessing/optimization/binarization
  
# Step 4d: Binarize Image with KRAKEN
# Binarize all images inside fileGrp 'OCR-D-IMG'
$ ocrd-kraken-binarize --input-file-grp OCR-D-IMG --output-file-grp OCR-D-IMG-KRAKEN-BIN --group-id OCR-D-IMG_0001 --working-dir ~/projects/OCR-D/data/workshop/binarizeOneImage --mets /path/to/new/workspace/mets.xml 
# Check result
$ firefox ~/projects/OCR-D/data/workshop/binarizeOneImage/OCR-D-IMG-KRAKEN-BIN/OCR-D-IMG-KRAKEN-BIN_0001.bin.png
# That's it
```

### Binarize all images of a METS file.


```shell=
# Step 0: Create Workspace & METS file 
# ------------------------
# Step 0a: Create workspace including METS file
$ ocrd workspace -d ~/projects/OCR-D/data/workshop/multipleImages create
$ cd ~/projects/OCR-D/data/workshop/multipleImages 
# Step 0b: Validate workspace
$ ocrd workspace --no-cache validate 
<report valid="false">
  <error>METS has no unique identifier</error>
  <error>No files</error>
</report>
# Step 0c: Add identifier to METS file
$ ocrd workspace set-id http://resolver.staatsbibliothek-berlin.de/SBB0000F29300000000
# <mods:mods xmlns:mods="http://www.loc.gov/mods/v3">
#   <mods:identifier type="purl">http://resolver.staatsbibliothek-berlin.de/SBB0000F29300000000</mods:identifier>
# </mods:mods>
$ ocrd workspace --no-cache validate
<report valid="false">
  <error>No files</error>
</report>
# Step 1: Download tiff images
# ----------------------------
$ wget -O PPN767137728_00000005.tif "http://ngcs.staatsbibliothek-berlin.de/?action=metsImage&format=jpg&metsFile=PPN767137728&divID=PHYS_0005&original=true"
$ wget -O PPN767137728_00000006.tif "http://ngcs.staatsbibliothek-berlin.de/?action=metsImage&format=jpg&metsFile=PPN767137728&divID=PHYS_0006&original=true"    


# Step 2: Add images to METS
# --------------------------
# Be aware, that the ID and the GROUPID have to identical if the referenced image represents the original image 
$ ocrd workspace add --file-grp OCR-D-IMG --file-id OCR-D-IMG_0001 --group-id OCR-D-IMG_0001 --mimetype image/tiff PPN767137728_00000005.tif
$ ocrd workspace add --file-grp OCR-D-IMG --file-id OCR-D-IMG_0002 --group-id OCR-D-IMG_0002 --mimetype image/tiff PPN767137728_00000006.tif

# Step 3: Validate workspace
# --------------------------
$ ocrd workspace --no-cache validate 
<report valid="true">
</report>

# Step 3a: Clone workspace (optional)
# -----------------------------------
# Create new directory and clone workspace to this directory
$ mkdir ../workspace3; cd ../workspace3
$ ocrd workspace clone --download-all $OLDPWD/mets.xml 
# Show all files (use --help to see all parameters)
$ ocrd workspace find
file:///path/to/new/workspace/OCR-D-IMG/PPN767137728_00000005.tif
file:///path/to/new/workspace/OCR-D-IMG/PPN767137728_00000006.tif

# Step 4: Binarize Image with KRAKEN
# ----------------------------------
$ ocrd-kraken-binarize --input-file-grp OCR-D-IMG --output-file-grp OCR-D-IMG-KRAKEN-BIN --working-dir ~/projects/OCR-D/data/workshop/binarizeAllImages --mets /tmp/pyocrd-'xyz'/mets.xml 
# Check result
$ firefox ~/projects/OCR-D/data/workshop/binarizeAllImages/OCR-D-IMG-KRAKEN-BIN/OCR-D-IMG-KRAKEN-BIN_0001.bin.png ~/projects/OCR-D/data/workshop/binarizeAllImages/OCR-D-IMG-KRAKEN-BIN/OCR-D-IMG-KRAKEN-BIN_0002.bin.png
# That's it
```

### Binarize one image of a METS file.

For preparing workspace see subsection [Binarize all images of a METS file](#binarize-all-images-of-a-mets-file) (Step 0 - 3)

```shell=
# Step 0: Reuse existing workspace 
# --------------------------------
$ cd ~/projects/OCR-D/data/workshop/multipleImages 

# Step 0b: Validate workspace
# --------------------------
$ ocrd workspace --no-cache validate 
<report valid="true">
</report>

# Step 1: Clone workspace (optional)
# -----------------------------------
# This step creates a temporal directory (/tmp/pyocrd-'xyz')
$ ocrd workspace --no-cache clone --download-all --mets-url ~/projects/OCR-D/data/workshop/multipleImages/mets.xml 
/tmp/pyocrd-'xyz'
# Change directory
$ cd /tmp/pyocrd-'xyz'
# Show all files (use --help to see all parameters)
$ ocrd workspace find
file:///tmp/pyocrd-'xyz'/OCR-D-IMG/PPN767137728_00000005.tif
file:///tmp/pyocrd-'xyz'/OCR-D-IMG/PPN767137728_00000006.tif

# Step 2: Binarize Image with KRAKEN
# ----------------------------------
# Step 2a: List all GROUPIDs.
§ ocrd workspace find --output-field groupId
OCR-D-IMG_0001
OCR-D-IMG_0002
Step 2b: Binarize image from a choosen GROUPID
$ ocrd-kraken-binarize --input-file-grp OCR-D-IMG --output-file-grp OCR-D-IMG-KRAKEN-BIN --group-id OCR-D-IMG_0001 --working-dir ~/projects/OCR-D/data/workshop/binarizeSelectedImage --mets /tmp/pyocrd-'xyz'/mets.xml 
# Check result
$ firefox ~/projects/OCR-D/data/workshop/binarizeSelectedImage/OCR-D-IMG-KRAKEN-BIN/OCR-D-IMG-KRAKEN-BIN_0001.bin.png 
# That's it
```

### Get Ground Truth from OCR-D 

```shell=
# Create data directory
$ mkdir -p ~/projects/OCR-D/data/groundTruth
$ cd ~/projects/OCR-D/data/groundTruth
# Download GT from OCR-D
$ wget http://ocr-d.de/sites/all/GTDaten/blumenbach_anatomie_1805.zip
$ unzip blumenbach_anatomie_1805.zip

# Step 1: Create workspace from METS
$ mkdir -p ~/projects/OCR-D/data/test; cd ~/projects/OCR-D/data/test
$ ocrd workspace clone --download-all ~/projects/OCR-D/data/groundTruth/blumenbach_anatomie_1805/mets.xml .
$ cd blumenbach_anatomie_1805/
```

### Installing a MP executable

```bash=
$ mkdir ~/projects/OCR-D/modules
$ cd ~/projects/OCR-D/modules
$ git clone https://github.com/OCR-D/ocrd_kraken
$ cd ocrd_kraken
$ sudo make install
```

### Tools for MP

#### Getting files referenced inside METS

The command 'ocrd workspace find' supports several options.

```shell=
$ cd ~/projects/OCR-D/data/workshop/binarizeAllImages
# List all files.
$ ocrd workspace find
file:///home/ocrd/projects/OCR-D/data/workshop/binarizeAllImages/PPN767137728.00000005.tif
file:///home/ocrd/projects/OCR-D/data/workshop/binarizeAllImages/PPN767137728.00000006.tif
file:///home/ocrd/projects/OCR-D/data/workshop/binarizeAllImages/OCR-D-IMG-KRAKEN-BIN/OCR-D-IMG-KRAKEN-BIN_0001.bin.png
file:///home/ocrd/projects/OCR-D/data/workshop/binarizeAllImages/OCR-D-IMG-KRAKEN-BIN/OCR-D-IMG-KRAKEN-BIN_0002.bin.png
# List all files inside a fileGrp
§ ocrd workspace find --file-grp OCR-D-IMG-KRAKEN-BIN
file:///home/ocrd/projects/OCR-D/data/workshop/binarizeAllImages/OCR-D-IMG-KRAKEN-BIN/OCR-D-IMG-KRAKEN-BIN_0001.bin.png
file:///home/ocrd/projects/OCR-D/data/workshop/binarizeAllImages/OCR-D-IMG-KRAKEN-BIN/OCR-D-IMG-KRAKEN-BIN_0002.bin.png
# List all files of a GROUPID
$ ocrd workspace find --group-id  OCR-D-IMG_0001
file:///home/ocrd/projects/OCR-D/data/workshop/binarizeAllImages/PPN767137728.00000005.tif
file:///home/ocrd/projects/OCR-D/data/workshop/binarizeAllImages/OCR-D-IMG-KRAKEN-BIN/OCR-D-IMG-KRAKEN-BIN_0001.bin.png
# See 'ocrd workspace find --help' for further information
```

#### Getting files referenced inside METS

The command 'ocrd workspace find' supports several options.

```shell=
$ cd ~/projects/OCR-D/data/workshop/binarizeAllImages
# List all files.
$ ocrd workspace find
file:///home/ocrd/projects/OCR-D/data/workshop/binarizeAllImages/PPN767137728.00000005.tif
file:///home/ocrd/projects/OCR-D/data/workshop/binarizeAllImages/PPN767137728.00000006.tif
file:///home/ocrd/projects/OCR-D/data/workshop/binarizeAllImages/OCR-D-IMG-KRAKEN-BIN/OCR-D-IMG-KRAKEN-BIN_0001.bin.png
file:///home/ocrd/projects/OCR-D/data/workshop/binarizeAllImages/OCR-D-IMG-KRAKEN-BIN/OCR-D-IMG-KRAKEN-BIN_0002.bin.png
# List all files inside a fileGrp
§ ocrd workspace find --file-grp OCR-D-IMG-KRAKEN-BIN
file:///home/ocrd/projects/OCR-D/data/workshop/binarizeAllImages/OCR-D-IMG-KRAKEN-BIN/OCR-D-IMG-KRAKEN-BIN_0001.bin.png
file:///home/ocrd/projects/OCR-D/data/workshop/binarizeAllImages/OCR-D-IMG-KRAKEN-BIN/OCR-D-IMG-KRAKEN-BIN_0002.bin.png
# List all files of a GROUPID
$ ocrd workspace find --group-id  OCR-D-IMG_0001
file:///home/ocrd/projects/OCR-D/data/workshop/binarizeAllImages/PPN767137728.00000005.tif
file:///home/ocrd/projects/OCR-D/data/workshop/binarizeAllImages/OCR-D-IMG-KRAKEN-BIN/OCR-D-IMG-KRAKEN-BIN_0001.bin.png
```

## FAQ

### Question: After fixing error 'ocrd workspace validate' will still fail

ocrd uses a cached directory (/tmp/cache-pyocrd). You may remove it manually or use the appropriate switch (--no-cache).

## Links
