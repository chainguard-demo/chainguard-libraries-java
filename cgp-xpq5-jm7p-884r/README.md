# CGP-xpq5-jm7p-884r — jjwt signature-stripping authentication bypass

This demo shows an authentication bypass in the
[jjwt](https://github.com/jwtk/jjwt) library that was disclosed through
[Chainguard Athena](https://www.chainguard.dev/athena) as
CGP-xpq5-jm7p-884r (
[JSON](https://github.com/chainguard-dev/athena/blob/main/advisories/CGP-xpq5-jm7p-884r/CGP-xpq5-jm7p-884r.json), [markdown](https://github.com/mosabua/athena/blob/advisory-index/docs/advisories/CGP-xpq5-jm7p-884r.md)
), and how
Chainguard Libraries for Java remediates it without a code change or a
disruptive upgrade.

The finding has **no CVE**, so a vulnerability scanner reports the project as
clean. The exploit is a 9.8-severity, network-exploitable bypass with full
impact.

## The vulnerability

The parser gates signature verification solely on the presence of a non-empty
third token segment. Strip the signature — send `header.payload.` with a
trailing dot and an empty signature — and the verification block is skipped
even when a signing key is configured. The parser returns attacker-controlled
claims as authentic.

A single forged, unsigned token is enough:

```
eyJhbGciOiJub25lIn0.eyJzdWIiOiJhZG1pbiJ9.
```

That decodes to `{"alg":"none"}` and `{"sub":"admin"}`. An application that
authenticates with the generic `parse()` method treats the caller as `admin`.

- **Package:** `io.jsonwebtoken:jjwt`
- **Affected:** `0.1` through `0.12.0`
- **Weakness:** CWE-347, improper verification of cryptographic signature

The affected code is the single-jar `io.jsonwebtoken:jjwt` coordinate. This
demo pins `0.7.0`, the version Chainguard has remediated, so the fixed artifact
is a drop-in replacement.

## Prerequisites

- A Chainguard account with a Java libraries entitlement
- [`chainctl`](https://edu.chainguard.dev/chainguard/chainctl/) installed and
  authenticated
- JDK 17 or higher
- A Chainguard Libraries pull token exported as `CHAINGUARD_JAVA_IDENTITY_ID`
  and `CHAINGUARD_JAVA_TOKEN`, as described in the
  [`tools`](../tools/README.md) directory

The demo projects use the bundled Maven wrapper, so no separate Maven install
is needed.

## Running it

```
./run-all.sh
```

For each variant this runs the JUnit test and then a live check. The test
requires a forged, unsigned token to be rejected, so it fails on the vulnerable
build and passes on the remediated one. Expected output:

```
VULNERABLE  — jjwt 0.7.0
-- unit test --
   JUnit result: FAILED (expected for the vulnerable build)
-- live check --
Signed token  -> ACCEPTED as 'alice'
Forged token  -> ACCEPTED as 'admin'

REMEDIATED  — jjwt 0.7.0-0.cgr.1 (Chainguard Libraries)
-- unit test --
   JUnit result: PASSED
-- live check --
Signed token  -> ACCEPTED as 'alice'
Forged token  -> REJECTED (SignatureException)
```

To run just the test, or just the live check, for a single variant:

```
./mvnw -s .mvn/settings.xml -f pom.xml            -q clean test         # fails: bypass present
./mvnw -s .mvn/settings.xml -f pom-remediated.xml -q clean test         # passes: bypass closed
./mvnw -s .mvn/settings.xml -f pom.xml            -q compile exec:java  # live check
```

## The test

`src/test/java/dev/chainguard/jjwtbypass/JwtBypassTest.java` encodes the secure
expectation. `forgedUnsignedTokenIsRejected` asserts that a token with its
signature stripped is rejected when a signing key is configured. On the
vulnerable jjwt the forged token is accepted, so the test fails; on the
remediated build it is rejected, so the test passes. A second test confirms a
normally signed token is still accepted.

## How the remediation works

`pom.xml` depends on upstream `io.jsonwebtoken:jjwt:0.7.0`. The forged token is
accepted — the bypass fires.

`pom-remediated.xml` changes only the version to
`io.jsonwebtoken:jjwt:0.7.0-0.cgr.1`, Chainguard's source-built artifact with
the Athena patch backported. It resolves from the Chainguard Libraries
`java-remediated` repository. The forged token is now rejected. The application
code is identical across both runs.

Upgrading upstream instead would mean jumping to `0.12.0`, which is an
API-breaking release — `parserBuilder()` replaces `parser()`, `verifyWith()`
replaces `setSigningKey()`. The Chainguard remediated `0.7.0-0.cgr.1` closes
the bypass with no such change, which is the point: remediate now, upgrade on
your own schedule.

## Resources

- [Chainguard Athena](https://www.chainguard.dev/athena)
- [Athena disclosures repository](https://github.com/chainguard-dev/athena)
- [Chainguard Libraries for Java](https://edu.chainguard.dev/chainguard/libraries/java/)
