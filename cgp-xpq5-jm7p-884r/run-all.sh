#!/usr/bin/env bash
#
# Demonstrates CGP-xpq5-jm7p-884r two ways against the vulnerable and the
# remediated jjwt:
#
#   1. JUnit test — requires a forged, unsigned token to be rejected.
#        vulnerable jjwt 0.7.0       -> test FAILS (bypass present)
#        remediated 0.7.0-0.cgr.1    -> test PASSES (bypass closed)
#   2. Live check — prints what the app does with the forged token.
#
# Same code and same test throughout; only the jjwt version differs. The
# remediated runs need Chainguard Libraries access — export
# CHAINGUARD_JAVA_IDENTITY_ID and CHAINGUARD_JAVA_TOKEN first.
#
# No `set -e`: the vulnerable test is meant to fail, and that must not abort
# the script.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MVNW="$SCRIPT_DIR/mvnw"
SETTINGS="$SCRIPT_DIR/.mvn/settings.xml"

run() {
	local label="$1" pom="$2"
	echo "=================================================="
	echo " $label"
	echo "   $pom"
	echo "=================================================="
	echo "-- unit test --"
	if "$MVNW" -s "$SETTINGS" -f "$SCRIPT_DIR/$pom" -q clean test; then
		echo "   JUnit result: PASSED"
	else
		echo "   JUnit result: FAILED (expected for the vulnerable build)"
	fi
	echo "-- live check --"
	"$MVNW" -s "$SETTINGS" -f "$SCRIPT_DIR/$pom" -q compile exec:java
	echo ""
}

run "VULNERABLE  — jjwt 0.7.0" pom.xml
run "REMEDIATED  — jjwt 0.7.0-0.cgr.1 (Chainguard Libraries)" pom-remediated.xml

echo "=================================================="
echo " Same code and the same test. Only the jjwt version changed."
echo "=================================================="
