#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

IMAGE_NAME="momo-store-backend"
IMAGE_VERSION="${VERSION:-1.0.${CI_PIPELINE_ID}}"


: "${CI_REGISTRY:?CI_REGISTRY is not set}"
: "${CI_REGISTRY_IMAGE:?CI_REGISTRY_IMAGE is not set}"
: "${CI_REGISTRY_USER:?CI_REGISTRY_USER is not set}"
: "${CI_REGISTRY_PASSWORD:?CI_REGISTRY_PASSWORD is not set}"

FULL_IMAGE="$CI_REGISTRY_IMAGE/$IMAGE_NAME"

echo "Logging in to GitLab Container Registry..."

echo "$CI_REGISTRY_PASSWORD" | docker login "$CI_REGISTRY" \
    -u "$CI_REGISTRY_USER" \
    --password-stdin

echo "Building backend image..."

docker build \
    -f "$PROJECT_ROOT/src/backend/Dockerfile" \
    -t "$FULL_IMAGE:$IMAGE_VERSION" \
    "$PROJECT_ROOT"

echo "Pushing image: $FULL_IMAGE:$IMAGE_VERSION"

docker push "$FULL_IMAGE:$IMAGE_VERSION"

if [[ "${CI_COMMIT_BRANCH:-}" == "${CI_DEFAULT_BRANCH:-}" ]]; then
    docker tag "$FULL_IMAGE:$IMAGE_VERSION" "$FULL_IMAGE:latest"
    docker push "$FULL_IMAGE:latest"
fi

echo "Backend image successfully published!"