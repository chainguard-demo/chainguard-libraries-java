# Example commands for Chainguard Libraries access

List entitlements:

```sh
chainctl libraries entitlements list
```

Create entitlement for Java with fallback to Maven Central activated:

```shell
chainctl libraries entitlements create --ecosystems=JAVA --policy=CHAINGUARD_AND_UPSTREAM
```

Create pull token for access to Java libraries and output environment variable
commands. Token valid for 30 days. The `--output env` form sets
`CHAINGUARD_JAVA_IDENTITY_ID` and `CHAINGUARD_JAVA_TOKEN`, the variables the
direct-access Maven settings and the test scripts read.

```shell
chainctl auth pull-token --output env --repository=java
```

Evaluate the output directly to export both variables into the current shell:

```shell
eval "$(chainctl auth pull-token --output env --repository=java)"
```

Create pull token for access to Java libraries for the chainguard.edu
organization, output environment variable commands, and pipe commands into a
shell script. Change the parent parameter to your organization name.

```shell
chainctl auth pull-token --output env --repository=java --parent=chainguard.edu > java-access.sh
```

Load the environment variables for use in a terminal.

```shell
source java-access.sh
```

Create new pull token for access to Java libraries and set environment variables:

```shell
eval $(chainctl auth pull-token --output env --repository=java --parent=chainguard.edu)
```

Create a policy for no cooldown and use it for Java:

```shell
chainctl libraries policy create --name=no-cooldown --cooldown-days=0
chainctl libraries policy enable --policy=no-cooldown --ecosystem=JAVA --mode=ENFORCE
```

List policies

```shell
chainctl libraries policy list
```

List policy bindings to ecosystems:

``` shell
chainctl libraries policy bindings list
```