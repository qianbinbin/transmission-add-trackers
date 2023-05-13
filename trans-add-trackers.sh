#!/usr/bin/env sh

HOST="localhost:9091"

AUTH="username:password"

CHECK_INTERVAL=60

TRACKERS_URL="https://cf.trackerslist.com/all.txt"

TRACKERS_RENEW_INTERVAL=$((60 * 60 * 8))

error() { echo "$@" >&2; }

TMP_DIR=$(mktemp -d)
# Won't work with some shell, like dash
trap 'rm -rf "$TMP_DIR"' EXIT

TRACKERS="$TMP_DIR/trackers"
TRACKERS_TMP="$TRACKERS.tmp"

renew_trackers() {
  error "Fetching trackers: $TRACKERS_URL"
  curl -fsSL "$TRACKERS_URL" | grep -v '^$' >"$TRACKERS_TMP"
  if [ ! -s "$TRACKERS_TMP" ]; then
    rm -f "$TRACKERS_TMP"
    return 1
  fi
  mv "$TRACKERS_TMP" "$TRACKERS"
}

add_trackers() {
  hash_long="$1"
  hash_short=$(echo "$1" | cut -c -8)

  # Transmission doesn't support WebSocket trackers, see https://github.com/transmission/transmission/issues/5509

  # Trackers from Transmission don't contain paths, e.g. http://example:80
  # IPv6 trackers will be wrong like http://[2001:-1 , which should be a bug
  old_trackers=$(transmission-remote "$HOST" --auth "$AUTH" --torrent "$hash_long" --info-trackers | grep "Tracker [[:digit:]]\+:" | awk '{ print $3 }')
  # Escape square brackets for `sed` to work with IPv6, i.e. [...] -> \[...\]
  old_trackers=$(echo "$old_trackers" | sed 's|\[|\\\[|g; s|\]|\\\]|g')

  # Trackers fetched from the web contain paths, e.g. http://example:80/announce
  # new_trackers=$(sed '\|\[|d; \|wss\?://|d' "$TRACKERS")
  new_trackers=$(cat "$TRACKERS")
  for ot in $old_trackers; do
    # Cannot remove duplicate IPv6 trackers due to incomplete addresses
    new_trackers=$(echo "$new_trackers" | sed "\|$ot|d")
  done
  if [ -z "$new_trackers" ]; then
    # error "No new trackers for $hash_short."
    return 1
  fi

  added=0
  total=$(echo "$new_trackers" | wc -l)
  for nt in $new_trackers; do
    # Duplicate and WebSocket trackers will cause "Error: invalid argument"
    if transmission-remote "$HOST" --auth "$AUTH" --torrent "$hash_long" --tracker-add "$nt" | grep -qs success; then
      : $((added += 1))
    fi
    printf "\rAdding $total new tracker(s) for $hash_short: %s" "$added/$total" >&2
  done
  printf "\n" >&2
  [ "$added" -eq "$total" ]
}

for _ in $(seq 5); do
  renew_trackers && break
  sleep 5
done

if [ ! -s "$TRACKERS" ]; then
  error "Failed to fetch trackers."
  exit 1
fi

start=$(date +%s)
while true; do
  current=$(date +%s)
  if [ $((current - start)) -ge "$TRACKERS_RENEW_INTERVAL" ]; then
    renew_trackers && start="$current"
  fi

  hashes=$(transmission-remote "$HOST" --auth "$AUTH" --torrent all --info | grep Hash | awk '{ print $2 }')
  for h in $hashes; do
    add_trackers "$h"
  done
  sleep "$CHECK_INTERVAL"
done
