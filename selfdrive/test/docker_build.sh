#!/usr/bin/env bash
set -xv

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
docker pull ghcr.io/nw0rn/openpilot/openpilot-base:latest
docker build --cache-from ghcr.io/nw0rn/openpilot/openpilot-base:latest -t $REMOTE_TAG -t $LOCAL_TAG -f $OPENPILOT_DIR/$DOCKER_FILE $OPENPILOT_DIR

docker images
docker ps

if [ -n "$PUSH_IMAGE" ]; then
  docker push $REMOTE_TAG
  docker tag $REMOTE_TAG $REMOTE_SHA_TAG
  docker push $REMOTE_SHA_TAG
fi

