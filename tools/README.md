# Tools and settings for Chainguard Libraries for Java

Helper scripts and example Maven and Gradle configuration for consuming
[Chainguard Libraries for Java](https://edu.chainguard.dev/chainguard/libraries/).
Use the scripts to confirm access, and the settings files as standalone
references you can drop into your own Maven or Gradle build. Each demo in this
repository also ships its own build-tool configuration.

## In this folder

| Resource | Purpose |
|---|---|
| [`access-examples.md`](access-examples.md) | `chainctl` command examples — entitlements, pull tokens, and policies. Start here to set up credentials. See [Authentication](#authentication). |
| `download-single-file-curl.sh` | Download a single artifact with `curl` to confirm direct access. See [Test scripts](#test-scripts). |
| `download-dependency-tree-maven.sh` | Resolve an artifact and its full dependency tree with Maven. See [Test scripts](#test-scripts). |
| `settings.xml.*` | Five example Maven settings files, one per access path. See [Maven settings files](#maven-settings-files). |
| `settings.gradle.*` | Two example Gradle settings files for direct access. See [Gradle settings files](#gradle-settings-files). |
| `init.gradle` | Example Gradle init script that configures direct access for every build on a machine. See [Global init script](#global-init-script). |

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

## Gradle settings files

Gradle configures repositories in `settings.gradle` rather than in a user-level
file, so these examples are standalone references — merge the
`pluginManagement` and `dependencyResolutionManagement` blocks into your own
`settings.gradle` and keep your existing `rootProject.name`. The
[`spring-boot`](../spring-boot/README.md) demo shows the same setup in a working
build.

| File | Access path | Credentials (environment variables) |
|---|---|---|
| `settings.gradle.cgr-only` | Direct to the Chainguard Libraries for Java repositories (`libraries.cgr.dev`), no Maven Central fallback | `CHAINGUARD_JAVA_IDENTITY_ID` / `CHAINGUARD_JAVA_TOKEN` |
| `settings.gradle.cgr-central` | Direct to the Chainguard Libraries for Java repositories, with upstream Maven Central and the Gradle Plugin Portal as the final fallbacks | `CHAINGUARD_JAVA_IDENTITY_ID` / `CHAINGUARD_JAVA_TOKEN` |

Both files list the two Chainguard contexts explicitly, in order —
`java-remediated` for the remediated `*+cgr.N` artifacts, then `java` for the
Chainguard rebuilds and the Maven Central mirror. They read credentials from a
pull token — see [Authentication](#authentication). The two files differ only in
the fallback:

- `settings.gradle.cgr-only` restricts resolution to Chainguard Libraries with
  no Maven Central fallback.
- `settings.gradle.cgr-central` adds `mavenCentral()` for dependencies and
  `gradlePluginPortal()` for plugins as the final fallbacks.

For access through a repository manager, point the repository URL at your
server's group and supply that manager's account credentials, in the same way
as the Maven repository manager files.

### Global init script

The `settings.gradle.*` files configure repositories one project at a time. To
configure Chainguard access for every Gradle build on a machine or CI agent
instead, use a Gradle init script. [`init.gradle`](init.gradle) injects the same
two Chainguard contexts into plugin and dependency resolution globally, so
individual projects need no repository configuration of their own. This is also
the natural place to point every build at a repository manager group — set the
URL and the manager's credentials once rather than per project.

Installed in the Gradle user home, `init.gradle` is the machine-global
counterpart to `~/.m2/settings.xml` for Maven. The demos keep their repository
configuration in each project's own `settings.gradle` instead — the same reason
the Maven demos pass `-s` with a project-local `.mvn/settings.xml` — so running
a demo stays self-contained and does not change your machine-wide Gradle setup.

Install it in the Gradle user home, or apply it to a single build:

```bash
# Every build on this machine
cp init.gradle ~/.gradle/init.gradle

# One build only
gradle --init-script init.gradle <task>
```

The script hooks `beforeSettings` for plugin repositories and `settingsEvaluated`
for dependency repositories — the two phases where Gradle allows those
repositories to be set from an init script. Setting them from the wrong phase
fails with `Mutation of repositories declared in settings is only allowed during
settings evaluation`. See the Gradle
[initialization scripts documentation](https://docs.gradle.org/current/userguide/init_scripts.html)
for the discovery order and the `init.d` directory.

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

## Using a Maven settings file

Maven reads its settings from `~/.m2/settings.xml` by default, so a file
installed there applies globally to every project on the workstation. That is
the usual real-world setup — copy one of these examples into place and every
Maven command picks it up automatically:

```bash
cp settings.xml.cgr-only ~/.m2/settings.xml
```

Alternatively, pass a settings file explicitly per command, without installing
it globally:

```bash
mvn -s settings.xml.cgr-only <goal>
```

The demos in this repository use that second form on purpose. Each ships a
project-local `.mvn/settings.xml` and runs Maven with `-s`, so the demo is
self-contained and running it does not touch your global `~/.m2/settings.xml`.

Set the matching environment variables first — see
[Authentication](#authentication) and [`access-examples.md`](access-examples.md).
