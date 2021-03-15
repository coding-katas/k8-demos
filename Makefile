# Make will use bash instead of sh
SHELL := /usr/bin/env bash

.PHONY: help
help:
	@echo 'Usage:'
	@echo '    make all              launch all.'
	@echo '    make create           Create 1 cluster with kind.'
	@echo '    make demo_namespace   Demo.'	
	@echo

# all
.PHONY: all
all: demo1 create-cluster
	@echo "Done"


.PHONY: create-cluster
create-cluster:
	@source create-cluster.sh

.PHONY: demo1
demo1:
	@source demo-namespaces.sh
