#!/usr/bin/env bash
#
# Downloads a single artifact from Chainguard Libraries for Java with curl to
# confirm direct access to the repository at libraries.cgr.dev.
#
# Credentials come from the same environment variables used by
# settings.xml.cgr-only — export them first with a Chainguard Libraries pull
# token (see README.md):
#
#   eval "$(chainctl auth pull-token --output env --repository=java)"
#
# This sets CHAINGUARD_JAVA_IDENTITY_ID and CHAINGUARD_JAVA_TOKEN.
#
# Usage: download-single-file-curl.sh [ARTIFACT_PATH] [OUTPUT_FILE]
#   ARTIFACT_PATH  Repository path of the artifact, relative to the java
#                  context. Defaults to
#                  com/fasterxml/jackson/core/jackson-core/2.18.2/jackson-core-2.18.2.jar
#   OUTPUT_FILE    Local file to write. Defaults to the artifact file name.

set -euo pipefail

BASE_URL="https://libraries.cgr.dev/java"
ARTIFACT_PATH="${1:-com/fasterxml/jackson/core/jackson-core/2.18.2/jackson-core-2.18.2.jar}"
OUTPUT_FILE="${2:-$(basename "$ARTIFACT_PATH")}"

if [[ -z "${CHAINGUARD_JAVA_IDENTITY_ID:-}" || -z "${CHAINGUARD_JAVA_TOKEN:-}" ]]; then
  echo "Error: CHAINGUARD_JAVA_IDENTITY_ID and CHAINGUARD_JAVA_TOKEN must be set." >&2
  echo "Export them with a Chainguard Libraries pull token:" >&2
  echo "  eval \"\$(chainctl auth pull-token --output env --repository=java)\"" >&2
  exit 1
fi

echo "Downloading: $BASE_URL/$ARTIFACT_PATH"
echo "Writing to:  $OUTPUT_FILE"
echo "Pass a different artifact path (and optional output file) as arguments, e.g."
echo "  $0 com/google/guava/guava/33.4.0-jre/guava-33.4.0-jre.jar"

curl -f -S -X GET \
  "$BASE_URL/$ARTIFACT_PATH" \
  -u "$CHAINGUARD_JAVA_IDENTITY_ID:$CHAINGUARD_JAVA_TOKEN" \
  --output "$OUTPUT_FILE"

echo "Download successful. Artifact saved to '$OUTPUT_FILE'."
