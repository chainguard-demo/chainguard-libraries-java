# chainguard-libraries-java

This repository contains tools and example projects for
[Chainguard Libraries for Java](https://edu.chainguard.dev/chainguard/libraries/java/).

Available directories:

* `cve-2024-38819` - Spring Framework application to showcase how to fix CVE-2024-38819
* `cve-2026-22732` - Spring Security application to showcase how to fix CVE-2026-22732
* `spring-boot` - minimal Spring Boot web application that resolves from Chainguard Libraries, buildable with both Maven and Gradle
* `tools` - collection of scripts and example configuration files

## Prerequisites

* A Chainguard account with a Java libraries entitlement
* [`chainctl`](https://edu.chainguard.dev/chainguard/chainctl/) installed and authenticated
* JDK 17 for the `cve-*` demos and JDK 21 for the `spring-boot` demo — the versions differ by design, since each CVE demo is pinned to the Spring Boot release whose CVE it shows, and `cve-2024-38819` on Spring Boot 2.5.x predates Java 21 support. To run every demo, have both JDK 17 and JDK 21 available
* Apache Maven — required only for `tools/download-dependency-tree-maven.sh`; the demo projects use the bundled Maven wrapper (`./mvnw`) and need no separate install
* Gradle — not required; the `spring-boot` demo bundles the Gradle wrapper (`./gradlew`) and provisions its Java 21 toolchain automatically

## Getting started

Configure access to Chainguard Libraries, either directly or through a
repository manager, using the example settings and commands in
[`tools`](tools/README.md). Then follow each demo's README to run it.

## Resources

* [Chainguard Libraries product page](https://www.chainguard.dev/libraries)
* [Chainguard Libraries documentation](https://edu.chainguard.dev/chainguard/libraries/)
* [Chainguard Libraries for Java documentation](https://edu.chainguard.dev/chainguard/libraries/java/)
* [Chainguard learning labs with more demos](https://edu.chainguard.dev/software-security/learning-labs/)
* [Chainguard Libraries for JavaScript examples](https://github.com/chainguard-demo/chainguard-libraries-javascript)
* [Chainguard Libraries for Python examples](https://github.com/chainguard-demo/chainguard-libraries-python)

## Videos

* [Chainguard Libraries fallback to upstream and policies](https://www.youtube.com/watch?v=o8DY_V4bkbg)
* [Chainguard Libraries for Java - CVE remediation and browsing](https://www.youtube.com/watch?v=hXL0Y0zwUYc)
* [Chainguard Libraries for Java - CVE remediation example projects](https://www.youtube.com/watch?v=-a1CungNdWw)