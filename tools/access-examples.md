# Example commands for Chainguard Libraries access

`chainctl` commands for setting up and managing access to Chainguard Libraries.
The pull-token commands are what the demos and settings files in this repository
depend on. The entitlement and policy commands are for administrators setting up
an organization.

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
