SHELL=zsh

create-sample-data:
	@rm -rf gt
	@mkdir -p sample
	@touch sample/page{1,2,3,4,5,6,7,8}.{tif,gt.txt,nrm.png,bin.png}
	@rm sample/page{1,3,5,7}.nrm.png
	@rm sample/page{2,4,6,8}.tif

GT_FILES = $(patsubst %.gt.txt,%.box,$(wildcard sample/*.gt.txt))

shuffle: $(GT_FILES)

.SECONDEXPANSION:
$(GT_FILES): sample/%.box: $$(shell find -regex ".*$$(@:.box=).\(nrm.png\|bin.png\|tif\)"|shuf|head -n1)
	@echo "$< --> $@"
