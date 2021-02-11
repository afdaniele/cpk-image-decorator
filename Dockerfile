# parameters
ARG ARCH
ARG REGISTRY="docker.io"
ARG REPOSITORY="NOT_SET"
ARG IMAGE="NOT_SET"
ARG TAG="NOT_SET"
ARG BASE=${REGISTRY}/${REPOSITORY}/${IMAGE}:${TAG}
ARG LAUNCHER=default
# ---
ARG NAME
ARG MAINTAINER
ARG DESCRIPTION

# base image
FROM ${BASE}

# recall all arguments
ARG ARCH
ARG LAUNCHER
ARG NAME
ARG DESCRIPTION
ARG MAINTAINER

# setup environment
ENV INITSYSTEM off
ENV QEMU_EXECVE 1
ENV TERM xterm
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONIOENCODING UTF-8
ENV DEBIAN_FRONTEND noninteractive

# keep some arguments as environment variables
ENV CPK_PROJECT_NAME "${NAME}"
ENV CPK_PROJECT_DESCRIPTION "${DESCRIPTION}"
ENV CPK_PROJECT_MAINTAINER "${MAINTAINER}"
ENV CPK_LAUNCHER "${LAUNCHER}"

# code environment
ENV CPK_SOURCE_DIR /code
ENV CPK_LAUNCHERS_DIR /launch
WORKDIR "${CPK_SOURCE_DIR}"

# copy QEMU
COPY ./assets/qemu/${ARCH}/ /usr/bin/

# copy binaries
COPY ./assets/bin/. /usr/local/bin/

# define and create repository paths
ENV CPK_PROJECT_LAUNCHERS_PATH "${CPK_LAUNCHERS_DIR}/${NAME}"
RUN mkdir -p "${CPK_PROJECT_LAUNCHERS_PATH}"

# install dependencies (APT)
COPY ./dependencies-apt.txt "${REPO_PATH}/"
RUN cpk-apt-install "${REPO_PATH}/dependencies-apt.txt"

# upgrade PIP
RUN pip3 install -U pip

# install dependencies (PIP3)
COPY ./dependencies-py3.txt "${REPO_PATH}/"
RUN cpk-pip3-install "${REPO_PATH}/dependencies-py3.txt"

# define healthcheck
RUN echo ND > /health
RUN chmod 777 /health
HEALTHCHECK \
    --interval=5s \
    CMD cat /health && grep -q ^healthy$ /health

# install launcher scripts
COPY ./launchers/default.sh "${CPK_PROJECT_LAUNCHERS_PATH}/"
RUN cpk-install-launchers "${CPK_PROJECT_LAUNCHERS_PATH}"

# define default command
CMD ["bash", "-c", "cpk-launcher-${CPK_LAUNCHER}"]

# store module metadata
LABEL \
    cpk.label.project.name="${NAME}" \
    cpk.label.project.description="${DESCRIPTION}" \
    cpk.label.architecture="${ARCH}" \
    cpk.label.code.location="${PROJECT_PATH}" \
    cpk.label.base.image="${BASE_IMAGE}" \
    cpk.label.base.tag="${BASE_TAG}" \
    cpk.label.maintainer="${MAINTAINER}"
