# Implementation Plan: Scalafix Migration

## Overview

Migrate from the deprecated Scalastyle plugin to the Scalafix Gradle plugin by modifying the root `build.gradle` and creating a new `.scalafix.conf` configuration file. The implementation adds the plugin dependency, applies and configures it in the subprojects block, creates the HOCON config with all specified rules, and removes all legacy commented-out Scalastyle references.

## Tasks

- [x] 1. Add Scalafix plugin classpath dependency
  - [x] 1.1 Add the `io.github.cosmicsilence:gradle-scalafix:0.2.6` classpath entry to the `buildscript.dependencies` block in the root `build.gradle`
    - Place it after the existing plugin classpath entries (e.g., after the `dependency-check-gradle` line)
    - The Gradle Plugin Portal repository is already declared in `buildscript.repositories`, so no repository changes are needed
    - _Requirements: 1.1, 1.2, 1.3_

- [x] 2. Apply the Scalafix plugin and configure it in the subprojects block
  - [x] 2.1 Add `apply plugin: 'io.github.cosmicsilence.scalafix'` in the `subprojects` block of the root `build.gradle`
    - Place it after the existing `apply plugin` lines (after the `org.owasp.dependencycheck` line)
    - _Requirements: 2.1_
  - [x] 2.2 Add the `scalafix { ... }` extension configuration block in the `subprojects` block
    - Configure `configFile` to point to `"$rootDir/repose-aggregator/src/config/styles/.scalafix.conf"`
    - Configure `ignoreSourceSets` to exclude `['generated', 'scoverage']`
    - Configure `semanticdb { autoConfigure = true }`
    - Add a usage comment above the block documenting `./gradlew checkScalafix` (lint) and `./gradlew scalafix` (auto-fix)
    - Place the block near the existing `checkstyle` and `codenarc` configuration blocks for consistency
    - _Requirements: 2.2, 6.1, 6.2, 6.3, 6.4, 7.1, 7.2, 7.3_

- [x] 3. Create the `.scalafix.conf` configuration file
  - [x] 3.1 Create the file at `repose-aggregator/src/config/styles/.scalafix.conf` in HOCON format
    - Enable rules: DisableSyntax, OrganizeImports, LeakingImplicitClassVal, NoValInForComprehension, ProcedureSyntax
    - Configure `DisableSyntax` with `noVars = true`, `noNulls = true`, `noThrows = true`
    - Configure `OrganizeImports` with groups `["re:javax?\\.", "scala.", "*"]`, `blankLines = Auto`, `groupedImports = Keep`, `importSelectorsOrder = Ascii`, `removeUnused = true`
    - Include header comments documenting the Scalastyle coverage mapping (what is covered by Scalafix vs what requires Scalafmt)
    - Include comments recommending Scalafmt for whitespace/formatting concerns not covered by Scalafix
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 4.1, 4.2, 4.3_

- [x] 4. Remove all commented-out Scalastyle references from build.gradle
  - [x] 4.1 Remove the commented-out `classpath 'org.github.ngbinh.scalastyle:gradle-scalastyle-plugin_2.11:1.0.1'` line and its associated comment from the `buildscript.dependencies` block
    - _Requirements: 9.1_
  - [x] 4.2 Remove the commented-out `apply plugin: 'scalaStyle'` line and its associated comment from the `subprojects` block
    - _Requirements: 9.2_
  - [x] 4.3 Remove the `//todo: write a good one of these plugins, because this is garbage` comment and the entire commented-out `scalaStyle { ... }` configuration block from the `subprojects` block
    - _Requirements: 9.3_
  - [x] 4.4 Remove the commented-out `// check.dependsOn scalaStyle` line from the `subprojects` block
    - _Requirements: 9.4_

- [x] 5. Checkpoint - Verify the build still works
  - Run `./gradlew buildEnvironment` to confirm the Scalafix plugin resolves without classpath conflicts
  - Run `./gradlew tasks --all` and verify `checkScalafix`, `checkScalafixMain`, `checkScalafixTest` tasks are registered
  - Run `./gradlew check --dry-run` on a Scala subproject to confirm `checkScalafix` is wired into the `check` lifecycle
  - Ensure all tests pass, ask the user if questions arise.
  - _Requirements: 5.1, 5.2, 8.1, 8.2, 8.3, 8.4_

## Notes

- This feature is entirely build configuration — no application code is modified
- The `checkScalafix` task is automatically wired as a dependency of `check` by the gradle-scalafix plugin itself
- DisableSyntax rules (`noVars`, `noNulls`, `noThrows`) may produce violations in existing code; the team should assess violation count before enforcing in CI
- The `scalafix` task (auto-fix mode) can be used to automatically fix violations for rules that support it (ProcedureSyntax, OrganizeImports)
- Whitespace/formatting concerns from the old Scalastyle config are not covered — Scalafmt is recommended as a future enhancement
