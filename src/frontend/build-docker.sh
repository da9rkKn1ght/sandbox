
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
: "${NEXUS_FRONTEND_REPOSITORY:?NEXUS_FRONTEND_REPOSITORY is not set}"
: "${FRONTEND_IMAGE_NAME:?FRONTEND_IMAGE_NAME is not set}"
: "${IMAGE_TAG:?IMAGE_TAG is not set}"

FULL_IMAGE="$NEXUS_REGISTRY/$NEXUS_FRONTEND_REPOSITORY/$FRONTEND_IMAGE_NAME:$IMAGE_TAG"

echo "Logging in to Nexus..."

printf '%s' "$NEXUS_PASSWORD" | docker login "$NEXUS_REGISTRY" \
    --username "$NEXUS_USERNAME" \
    --password-stdin

echo "Building frontend image: $FULL_IMAGE"

docker build \
    -f "$PROJECT_ROOT/src/frontend/Dockerfile" \
    -t "$FULL_IMAGE" \
    "$PROJECT_ROOT"

echo "Pushing frontend image to Nexus..."

docker push "$FULL_IMAGE"

echo "Frontend image successfully published: $FULL_IMAGE"
