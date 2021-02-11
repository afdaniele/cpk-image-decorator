MAKEFILE_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
ROOT_DIR:=${MAKEFILE_DIR}/../../..

IN_IMAGE=ubuntu
IN_TAG=focal

OUT_REGISTRY=docker.io
OUT_REPOSITORY=cpk
OUT_IMAGE=ubuntu
OUT_TAG=focal

all:
	#for arch in arm32v7 arm64v8 amd64 ; do \

	for arch in amd64 ; do \
		docker build \
			-t "${OUT_REGISTRY}/${OUT_REPOSITORY}/${OUT_IMAGE}:${OUT_TAG}-$${arch}" \
			-f ${ROOT_DIR}/Dockerfile \
			--build-arg BASE="$${arch}/${IN_IMAGE}:${IN_TAG}" \
			--build-arg ARCH="$${arch}" \
			${ROOT_DIR}; \
    done;
