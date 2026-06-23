#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
  echo "usage: $0 MANAGED_SETTINGS_JSON" >&2
  exit 2
fi

managed_settings_file=$1
if [ ! -f "$managed_settings_file" ]; then
  echo "missing managed JSON settings: $managed_settings_file" >&2
  exit 1
fi

input_file=$(mktemp)
trap 'rm -f "$input_file"' EXIT

cat >"$input_file"
if ! grep -q '[^[:space:]]' "$input_file"; then
  printf '{}\n' >"$input_file"
fi

# Recursive object merge: existing local values are preserved unless the
# managed settings file defines the same key, in which case managed wins.
jq -s '.[0] * .[1]' "$input_file" "$managed_settings_file"
