# Example commands for Chainguard Libraries access

`chainctl` commands for setting up and managing access to Chainguard Libraries.
The pull-token commands are what the demos and settings files in this repository
depend on. The entitlement and policy commands are for administrators setting up
an organization. The verify command checks a downloaded artifact and optionally
saves its SBOM and attestations.

## Prerequisites

Authenticate to the Chainguard platform first:

```shell
chainctl auth login
```

Creating entitlements and policies requires appropriate permissions on the
organization. Generating a pull token requires an active libraries entitlement.

Most users belong to a single organization, so `chainctl` selects it
automatically or prompts you to choose interactively. Add `--parent=<org>` to
any command below only if you belong to more than one organization and need it
to run non-interactively, for example in CI.

## Entitlements

List existing entitlements:

```shell
chainctl libraries entitlements list
```

Create an entitlement for Java with the upstream Maven Central fallback enabled:

```shell
chainctl libraries entitlements create --ecosystems=JAVA --policy=chainguard_and_upstream
```

`--ecosystems` is required and takes a comma-separated list, for example
`JAVA,PYTHON`. The `--policy` value is `chainguard` for Chainguard rebuilds
only, or `chainguard_and_upstream` to add the upstream fallback.

## Pull tokens

A pull token provides the credentials the Maven and Gradle configurations read.
The `--output env` form prints shell commands that set
`CHAINGUARD_JAVA_IDENTITY_ID` and `CHAINGUARD_JAVA_TOKEN`, the two variables the
direct-access settings files and the test scripts use.

Print the export commands:

```shell
chainctl auth pull-token --output env --repository=java
```

Evaluate the output to export both variables into the current shell:

```shell
eval "$(chainctl auth pull-token --output env --repository=java)"
```

`--repository` must be one of `oci`, `apk`, `java`, `python`, or `javascript`.
Control validity with `--ttl`, for example `--ttl=24h`; the maximum is `8760h`,
one year.

Write the export commands to a script to source later:

```shell
chainctl auth pull-token --output env --repository=java > java-access.sh
source java-access.sh
```

If you are a member of multiple organizations the preceding example commands
must use the `--parent` parameter with the name of your organization:

```shell
eval "$(chainctl auth pull-token --output env --parent=chainguard.edu --repository=java)"
```

```shell
chainctl auth pull-token --output env --repository=java --parent=chainguard.edu > java-access.sh
```

## Policies

Policies control the cooldown window and package gating for an ecosystem. A
newly created policy is inactive until it is enabled for an ecosystem.

Create a policy with no cooldown:

```shell
chainctl libraries policy create --name=no-cooldown --cooldown-days=0
```

Show the policy details:

```shell
chainctl libraries policy describe no-cooldown
```

Enable it for Java in enforcing mode:

```shell
chainctl libraries policy enable --policy=no-cooldown --ecosystem=JAVA --mode=ENFORCE
```

List policies and their bindings to ecosystems:

```shell
chainctl libraries policy list
chainctl libraries policy bindings list
```

## Verify artifacts and download attestations

`chainctl libraries verify` analyzes a local artifact and reports how much of it
was built from source by Chainguard, based on SBOM data, signatures, and
artifact inspection. It uses your `chainctl auth login` session and does not
need the pull token environment variables that the Maven, Gradle, and curl
configurations rely on.

Verify a single JAR:

```shell
chainctl libraries verify jackson-core-2.18.2.jar
```

`verify` accepts one or more paths, so you can check many artifacts in one
command:

```shell
chainctl libraries verify build/libs/*.jar build/libs/*.war
```

Add `--output-attestations` to save the SBOM and SLSA provenance published
alongside a verified, Chainguard-built Java artifact instead of discarding them
after the check. `--output-dir` sets the base directory, and files are written
under each artifact's Maven repository path, `group/artifact/version`:

```shell
chainctl libraries verify jackson-core-2.18.2.jar \
  --output-attestations --output-dir repo
```

For the preceding command, the files land under
`repo/com/fasterxml/jackson/core/jackson-core/2.18.2/`:

- `jackson-core-2.18.2.spdx.json` — SPDX SBOM, a trusted Chainguard attestation
- `jackson-core-2.18.2.slsa-attestation.json` — SLSA provenance, also trusted
- `jackson-core-2.18.2-cyclonedx.json` and `jackson-core-2.18.2-cyclonedx.xml` —
  CycloneDX SBOMs, saved when present but marked unverified, since Chainguard
  does not vouch for their contents

Only an artifact that verifies as a Chainguard build saves anything. Upstream or
tampered bytes save nothing, and inside a fat JAR each embedded library is
verified and saved individually. Downloading attestations is supported for Java
artifacts only; the flags are ignored for all other ecosystems.
