#!/usr/bin/env bash
# Offline check that the Spotify rule matches Spotify only. wpexec connects
# to PipeWire as a client but changes no routing, defaults or services.
set -euo pipefail
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
conf="$repo_dir/wireplumber/wireplumber.conf.d/50-spotify-follow-default.conf"
# wpexec accepts only an object argument, so the rule list travels as a string.
arg="$(python3 -c 'import json,re,sys;m=re.search(r"stream\.rules = \[(.*)\]",sys.stdin.read(),re.S);print("{ conf = " + json.dumps(m.group(1).strip()) + " }")' <"$conf")"
if out="$(WIREPLUMBER_DEBUG=3 timeout 30 wpexec "$repo_dir/scripts/check-spotify-follow-default.lua" "$arg" 2>&1)"; then
    echo "PASS: rule sets state.restore-target=false for Spotify only"
else
    printf '%s\n' "$out" | grep -E 'CHECK FAILED|wplua' || printf '%s\n' "$out" | tail -5
    exit 1
fi
