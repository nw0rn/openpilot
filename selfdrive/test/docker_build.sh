#!/usr/bin/env bash
set -e

# To build sim and docs, you can run the following to mount the scons cache to the same place as in CI:
# mkdir -p .ci_cache/scons_cache
# sudo mount --bind /tmp/scons_cache/ .ci_cache/scons_cache

SCRIPT_DIR=$(dirname "$0")
OPENPILOT_DIR=$SCRIPT_DIR/../../
if [ -n "$TARGET_ARCHITECTURE" ]; then
  PLATFORM="linux/$TARGET_ARCHITECTURE"
  TAG_SUFFIX="-$TARGET_ARCHITECTURE"
else
  PLATFORM="linux/$(uname -m)"
  TAG_SUFFIX=""
fi

source $SCRIPT_DIR/docker_common.sh $1 "$TAG_SUFFIX"

# DOCKER_BUILDKIT=1 docker buildx build --platform $PLATFORM --cache-from type=gha --cache-to type=gha,mode=max -t $REMOTE_TAG --push -f $OPENPILOT_DIR/$DOCKER_FILE $OPENPILOT_DIR
/usr/bin/docker buildx build --cache-from type=gha --cache-to type=gha,mode=max  --provenance mode=max,builder-id=https://github.com/nw0rn/openpilot/actions/runs/9159568519 --tag ghcr.io/nw0rn/openpilot:123 --metadata-file /home/runner/work/_temp/docker-actions-toolkit-750cnR/metadata-file --push .

docker images
docker ps

if [ -n "$PUSH_IMAGE" ]; then
  docker push $REMOTE_TAG
  docker tag $REMOTE_TAG $REMOTE_SHA_TAG
  docker push $REMOTE_SHA_TAG
fi
