# Tools and settings for Chainguard Libraries for Java

Helper scripts and example Maven `settings.xml` files for consuming
[Chainguard Libraries for Java](https://edu.chainguard.dev/chainguard/libraries/).
Use the scripts to confirm access, and the settings files as standalone
references you can drop in as your own Maven settings. Each demo in this
repository also ships its own `.mvn/settings.xml`.

## In this folder

| Resource | Purpose |
|---|---|
| [`access-examples.md`](access-examples.md) | `chainctl` command examples — entitlements, pull tokens, and policies. Start here to set up credentials. See [Authentication](#authentication). |
| `download-single-file-curl.sh` | Download a single artifact with `curl` to confirm direct access. See [Test scripts](#test-scripts). |
| `download-dependency-tree-maven.sh` | Resolve an artifact and its full dependency tree with Maven. See [Test scripts](#test-scripts). |
| `settings.xml.*` | Five example Maven settings files, one per access path. See [Maven settings files](#maven-settings-files). |

## Authentication

Direct access to the Chainguard Libraries for Java repositories uses a
Chainguard Libraries pull token, exported as environment variables:

```bash
eval "$(chainctl auth pull-token --output env --repository=java)"
```

This sets `CHAINGUARD_JAVA_IDENTITY_ID` and `CHAINGUARD_JAVA_TOKEN`, which the
direct-access settings files and both test scripts read. See
[`access-examples.md`](access-examples.md) for the full set of `chainctl`
commands, including entitlements, organization-scoped tokens, and policies.

Access through a repository manager (Cloudsmith, Artifactory, Nexus) uses that
manager's own account credentials instead — see the table below.

## Maven settings files

| File | Access path | Credentials (environment variables) |
|---|---|---|
| `settings.xml.cgr-only` | Direct to the Chainguard Libraries for Java repositories (`libraries.cgr.dev`), no Maven Central fallback | `CHAINGUARD_JAVA_IDENTITY_ID` / `CHAINGUARD_JAVA_TOKEN` |
| `settings.xml.cgr-central` | Direct to the Chainguard Libraries for Java repositories, with upstream Maven Central as the final fallback | `CHAINGUARD_JAVA_IDENTITY_ID` / `CHAINGUARD_JAVA_TOKEN` |
| `settings.xml.cloudsmith` | Through a Cloudsmith repository group | `CLOUDSMITH_USERNAME` / `CLOUDSMITH_PASSWORD` |
| `settings.xml.artifactory` | Through a JFrog Artifactory group | `ARTIFACTORY_USERNAME` / `ARTIFACTORY_PASSWORD` |
| `settings.xml.nexus` | Through a Sonatype Nexus group | Set directly in the file (server id `nexus`) |

### Direct access — `settings.xml.cgr-only` and `settings.xml.cgr-central`

These connect straight to the Chainguard Libraries endpoint. Because there is
no repository manager in between, the client lists the contexts itself, in
order:

1. `https://libraries.cgr.dev/java-remediated/` — remediated `*.cgr.N` artifacts
2. `https://libraries.cgr.dev/java/` — Chainguard rebuilds and the Maven Central fallback

The two files differ only in the fallback:

- `settings.xml.cgr-only` sets the `central` repository to an invalid URL, so
  resolution is restricted to Chainguard Libraries with no Maven Central
  fallback. This matches the configuration the demos use (see each demo's
  `.mvn/settings.xml`).
- `settings.xml.cgr-central` adds `https://repo1.maven.org/maven2/` as the final
  fallback for anything not served above.

Both read credentials from a pull token — see [Authentication](#authentication).

### Via a repository manager — `settings.xml.cloudsmith`, `settings.xml.artifactory`, `settings.xml.nexus`

Cloudsmith, Artifactory, and Nexus aggregate Chainguard Libraries and Maven
Central into a single **group** (or **virtual**) repository on the server side.
Because that merge already happens upstream, the client mirrors every request to
the one group URL — there is no need to enumerate the `java` / `java-remediated`
contexts or a Central fallback in the settings file. Edit the group URL in the
file to point at your server, and supply your repository manager account
credentials. The Cloudsmith and Artifactory files read them from the
environment variables above; the Nexus file has a commented-out `server` block
to fill in. Refer to the repository manager's documentation for other authentication mechanisms.

## Test scripts

Both scripts confirm access to Chainguard Libraries for Java and read the
`CHAINGUARD_JAVA_IDENTITY_ID` / `CHAINGUARD_JAVA_TOKEN` credentials from the
environment — set them up first per [Authentication](#authentication).

| Script | What it does |
|---|---|
| `download-single-file-curl.sh` | Downloads a single artifact directly from the repository (`libraries.cgr.dev/java`) with `curl`. Optionally takes an artifact path and output file name. |
| `download-dependency-tree-maven.sh` | Resolves an artifact and its full transitive dependency tree with Maven, using `settings.xml.cgr-only`. Optionally takes Maven coordinates (`groupId:artifactId:version`). |

```bash
# Single file with curl (defaults to jackson-core 2.18.2)
./download-single-file-curl.sh
./download-single-file-curl.sh com/google/guava/guava/33.4.0-jre/guava-33.4.0-jre.jar

# Full dependency tree with Maven (defaults to jackson-core 2.18.2)
./download-dependency-tree-maven.sh
./download-dependency-tree-maven.sh com.google.guava:guava:33.4.0-jre
```

## Using a settings file

Install it as your user-level Maven settings in the default location, so every
Maven command picks it up automatically:

```bash
cp settings.xml.cgr-only ~/.m2/settings.xml
```

Alternatively, pass it explicitly per command without installing it:

```bash
mvn -s settings.xml.cgr-only <goal>
```

Set the matching environment variables first — see
[Authentication](#authentication) and the
[top-level README](../README.md).
