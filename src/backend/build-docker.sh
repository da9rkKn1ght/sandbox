
#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONFIG_FILE="$PROJECT_ROOT/.env.nexus"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Configuration file not found: $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

: "${NEXUS_USERNAME:?NEXUS_USERNAME is not set}"
: "${NEXUS_PASSWORD:?NEXUS_PASSWORD is not set}"
: "${NEXUS_REGISTRY:?NEXUS_REGISTRY is not set}"
: "${NEXUS_BACKEND_REPOSITORY:?NEXUS_BACKEND_REPOSITORY is not set}"
: "${BACKEND_IMAGE_NAME:?BACKEND_IMAGE_NAME is not set}"
: "${IMAGE_TAG:?IMAGE_TAG is not set}"

FULL_IMAGE="$NEXUS_REGISTRY/$NEXUS_BACKEND_REPOSITORY/$BACKEND_IMAGE_NAME:$IMAGE_TAG"

echo "Logging in to Nexus..."

printf '%s' "$NEXUS_PASSWORD" | docker login "$NEXUS_REGISTRY" \
    --username "$NEXUS_USERNAME" \
    --password-stdin

echo "Building backend image: $FULL_IMAGE"

docker build \
    -f "$PROJECT_ROOT/src/backend/Dockerfile" \
    -t "$FULL_IMAGE" \
    "$PROJECT_ROOT"

echo "Pushing backend image to Nexus..."

docker push "$FULL_IMAGE"

echo "Backend image successfully published: $FULL_IMAGE"
