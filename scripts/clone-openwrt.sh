#!/usr/bin/env bash

set -Eeuo pipefail

repo_url="${1:?repository URL is required}"
repo_branch="${2:?repository branch is required}"
destination="${3:-openwrt}"

# A shallow clone is sufficient for the build and avoids transferring the
# complete LEDE history. Retry transient GitHub/network failures before the
# workflow fails.
rm -rf -- "$destination"
for attempt in 1 2 3; do
    if git -c http.sslBackend=openssl -c http.version=HTTP/1.1 clone \
        --depth=1 \
        --single-branch \
        --no-tags \
        --branch "$repo_branch" \
        "$repo_url" \
        "$destination"; then
        exit 0
    fi

    rm -rf -- "$destination"
    if [ "$attempt" -lt 3 ]; then
        sleep $((attempt * 10))
    fi
done

echo "Unable to clone $repo_url branch $repo_branch after 3 attempts" >&2
exit 1
