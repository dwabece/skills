#!/usr/bin/env bash
# Moves an issue to a column of a GitHub Projects (v2) board.
# A column is an option of a single-select field, so a move is: project id, field and option ids,
# item id (item-add returns the existing item when the issue is already on the project), one write.
# Prints one line: `moved <issue-url> to "<column>"` or `move failed: <reason>` (exit 1).
set -uo pipefail

[ $# -ge 4 ] || { echo "usage: move.sh <project-owner> <project-number> <issue-url> <column> [status-field]"; exit 2; }
owner=$1 number=$2 url=$3 column=$4 field=${5:-Status}
fail() { echo "move failed: $*"; exit 1; }

project_id=$(gh project view "$number" --owner "$owner" --format json --jq .id) \
  || fail "project $owner/$number not found, or gh lacks the project scope"

fields=$(gh project field-list "$number" --owner "$owner" --limit 100 --format json \
  --jq ".fields[] | select(.name==\"$field\") | .id, (.options[]? | \"\(.id)\t\(.name)\")") \
  || fail "cannot read the fields of project $owner/$number"
field_id=$(head -n1 <<<"$fields")
[ -n "$field_id" ] || fail "project has no field \"$field\""
option_id=$(tail -n +2 <<<"$fields" | awk -F'\t' -v c="$column" '$2 == c { print $1 }')
[ -n "$option_id" ] || fail "no column \"$column\", available: $(tail -n +2 <<<"$fields" | cut -f2 | paste -sd, -)"

item_id=$(gh project item-add "$number" --owner "$owner" --url "$url" --format json --jq .id) \
  || fail "cannot add $url to the project"

gh project item-edit --project-id "$project_id" --id "$item_id" \
  --field-id "$field_id" --single-select-option-id "$option_id" >/dev/null \
  || fail "cannot set \"$field\" to \"$column\""

echo "moved $url to \"$column\""
