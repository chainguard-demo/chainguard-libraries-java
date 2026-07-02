#!/usr/bin/env bash
#
# Fetches an artifact and its full transitive dependency tree through
# Chainguard Libraries with Maven to confirm access.
#
# Uses the direct cgr-only settings (settings.xml.cgr-only) by default. To test
# a different access path, point -s at settings.xml.cloudsmith or
# settings.xml.artifactory instead.
#
# Set the matching credentials in your environment first — for cgr-only that
# is CHAINGUARD_JAVA_IDENTITY_ID and CHAINGUARD_JAVA_TOKEN (see README.md).
#
# Usage: download-dependency-tree-maven.sh [GAV]
#   GAV  Optional Maven coordinates (groupId:artifactId:version) of the
#        artifact to fetch. Defaults to
#        com.fasterxml.jackson.core:jackson-core:2.18.2.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

ARTIFACT="${1:-com.fasterxml.jackson.core:jackson-core:2.18.2}"

echo "Retrieving artifact: $ARTIFACT"
echo "Pass different GAV coordinates as the first argument to change this, e.g."
echo "  $0 com.google.guava:guava:33.4.0-jre"
echo "  $0 org.apache.commons:commons-collections4:4.5.0"
echo "  $0 org.apache.httpcomponents.client5:httpclient5:5.4.1"

mvn dependency:get \
    -s "$SCRIPT_DIR/settings.xml.cgr-only" \
    -U \
    -Dmaven.repo.local=repo \
    -Dartifact="$ARTIFACT"

echo "Artifacts retrieved successfully. You can find them in the 'repo' directory."
