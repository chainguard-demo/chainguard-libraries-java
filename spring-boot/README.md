# Spring Boot demo — Chainguard Libraries for Java

A minimal Spring Boot web application that resolves all of its dependencies
from [Chainguard Libraries for Java](https://edu.chainguard.dev/chainguard/libraries/)
(`https://libraries.cgr.dev/java/`). It demonstrates the same setup with both
**Maven** and **Gradle**.

The application exposes a single endpoint:

```
GET /  ->  Hello, Chainguard Libraries!
```

It starts on http://localhost:8080 by default.

## Prerequisites

You need a Chainguard Libraries pull token exposed as environment variables.
`chainctl` emits the correctly named variables when you pass `--output env`:

```bash
eval "$(chainctl auth pull-token --output env --repository=java --parent=ORGANIZATION)"
```

Replace `ORGANIZATION` with the organization that holds your Java libraries
entitlement, or omit `--parent` if you belong to only one organization.

This sets the two variables that the Maven and Gradle configurations read:

- `CHAINGUARD_JAVA_IDENTITY_ID` — used as the registry username
- `CHAINGUARD_JAVA_TOKEN` — used as the registry password

See [`tools/access-examples.md`](../tools/access-examples.md) for more detail on
the pull-token setup.

Both builds resolve from `https://libraries.cgr.dev/java/` first and fall back
to Maven Central for anything not served by Chainguard.

## Java version

The toolchain is pinned to **Java 21 (LTS)**.

This project deliberately stays on **Spring Boot 3.4.x**. Spring Boot 3.4.x
bundles a version of ASM (used for classpath scanning) that cannot parse Java
24 or 25 bytecode, so the build fails at test/run time on anything newer than
Java 23. Java 21 is the most recent LTS that Spring Boot 3.4.x fully supports,
which makes it the sensible target here.

- **Gradle** uses the [Foojay toolchain resolver](https://github.com/gradle/foojay-toolchains).
  If a Java 21 JDK is already installed it is detected and used automatically;
  otherwise Gradle downloads one. The Gradle wrapper itself is 9.5.1, which can
  *run* on JDK 17 through 26 — so you can launch `./gradlew` with whatever JDK
  you have on your `PATH`, independent of the Java 21 toolchain it compiles
  with.
- **Maven** compiles with the JDK that runs `./mvnw`, targeting release 21, so
  you need **JDK 21 or newer** available to run the Maven build.

## Run with Maven

Maven reads the project-local settings at [`.mvn/settings.xml`](.mvn/settings.xml),
so pass it with `-s`:

```bash
# Start the app on http://localhost:8080
./mvnw -s .mvn/settings.xml spring-boot:run

# Build and run the tests
./mvnw -s .mvn/settings.xml clean package
```

The convenience script [`test.sh`](test.sh) runs the app with a project-local
Maven repository (`-Dmaven.repo.local=repo`) so downloaded artifacts are easy
to inspect:

```bash
./test.sh
```

## Run with Gradle

Gradle reads its repository configuration from [`settings.gradle`](settings.gradle)
automatically — no extra flag is required:

```bash
# Start the app on http://localhost:8080
./gradlew bootRun

# Build and run the tests
./gradlew clean build
```

## Try it

With the app running:

```bash
curl http://localhost:8080/
# -> Hello, Chainguard Libraries!
```

## Project layout

```
.mvn/settings.xml      — Maven repository + credentials (Chainguard, Central fallback)
settings.gradle        — Gradle repository config + Foojay toolchain resolver
build.gradle           — Gradle build (Java 21 toolchain, Spring Boot 3.4.x)
pom.xml                — Maven build (Java 21, Spring Boot 3.4.x)
test.sh                — Maven run helper using a local repo directory
src/main/java/dev/chainguard/ecosystems_java_demo/
  EcosystemsJavaDemoApplication.java  — Spring Boot entry point
  HelloWorldController.java           — GET / endpoint
```
