ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
BUILD_DIR := $(ROOT_DIR)/build
DIST_DIR := $(BUILD_DIR)/dist
GIT_COMMIT := $(shell git rev-parse HEAD)

SPARK_REPO_URL ?= git@github.com:apache/spark.git#v2.4.0

.ONESHELL:
SHELL := /bin/bash
.SHELLFLAGS = -ec

HADOOP_VERSION ?= "2.8"
SPARK_DIR ?= $(ROOT_DIR)/spark
$(SPARK_DIR):
	if cd $(SPARK_DIR); then git pull; else git clone $(SPARK_REPO_URL) $(SPARK_DIR); fi

prod-dist: $(SPARK_DIR)
	pushd $(SPARK_DIR)
	rm -rf spark-*.tgz
	dev/make-distribution.sh --tgz --pip -Pmesos "-Phadoop-$(HADOOP_VERSION)" -Pnetlib-lgpl -Psparkr -DskipTests
	filename=`ls spark-*.tgz`
	rm -rf $(DIST_DIR)
	mkdir -p $(DIST_DIR)
	mv $${filename} $(DIST_DIR)
	echo "Built: $(DIST_DIR)/$${filename}"
	popd

.PHONY: prod-dist