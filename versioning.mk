VERSION ?= git-$(shell git rev-parse --short HEAD)

IMAGE := ${DRYCC_REGISTRY}/${IMAGE_PREFIX}/${SHORT_NAME}:${VERSION}

info:
	@echo "Build tag:       ${VERSION}"
	@echo "Registry:        ${DRYCC_REGISTRY}"
	@echo "Immutable tag:   ${IMAGE}"

.PHONY: podman-push
podman-push:
	podman push ${IMAGE}
