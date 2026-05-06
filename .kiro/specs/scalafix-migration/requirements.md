# Requirements Document

## Introduction

This feature migrates the Repose project's Scala static code analysis from the deprecated Scalastyle plugin (`org.github.ngbinh.scalastyle:gradle-scalastyle-plugin_2.11:1.0.1`) to the Scalafix Gradle Plugin (`io.github.cosmicsilence:gradle-scalafix:0.2.6`). The old plugin was removed during the Java 11 migration because it was unavailable for modern toolchains. Scalafix is the recommended replacement — it is backed by the Scala Center's Scalafix engine, with the Gradle plugin wrapper maintained by the cosmicsilence community contributor (the Scala Center only officially maintains the sbt plugin). The migration restores Scala linting capability, provides auto-fix support, and integrates with the existing `check` lifecycle task alongside Checkstyle (Java) and CodeNarc (Groovy).

## Glossary

- **Build_System**: The Gradle 6.9.4 multi-module build for the Repose project
- **Scalafix_Plugin**: The `io.github.cosmicsilence:gradle-scalafix:0.2.6` Gradle plugin that delegates to the Scala Center's Scalafix engine
- **Scalafix_Configuration**: The `.scalafix.conf` file in HOCON format that defines which rules to apply
- **Check_Task**: The Gradle `check` lifecycle task that aggregates all verification tasks in subprojects
- **Scalastyle_Config**: The legacy `scalastyle_config.xml` file containing regex-based formatting checks
- **Source_Set**: A Gradle concept grouping source files (main, test, integrationTest, generated)
- **Subproject**: A module within the Repose multi-module Gradle build that contains Scala source code

## Requirements

### Requirement 1: Plugin Declaration

**User Story:** As a build engineer, I want the Scalafix Gradle plugin declared in the buildscript dependencies, so that it is available for application in subprojects.

#### Acceptance Criteria

1. THE Build_System SHALL declare `io.github.cosmicsilence:gradle-scalafix:0.2.6` in the root `build.gradle` buildscript dependencies block
2. THE Build_System SHALL resolve the Scalafix plugin from the Gradle Plugin Portal repository (`https://plugins.gradle.org/m2/`)
3. WHEN the buildscript dependencies are resolved, THE Build_System SHALL successfully download the Scalafix plugin without conflicts with existing classpath entries

### Requirement 2: Plugin Application

**User Story:** As a build engineer, I want the Scalafix plugin applied to all Scala subprojects, so that Scala source code is analyzed consistently across the entire codebase.

#### Acceptance Criteria

1. THE Build_System SHALL apply the `io.github.cosmicsilence.scalafix` plugin in the `subprojects` block of the root `build.gradle`
2. THE Build_System SHALL configure the Scalafix plugin to use a shared configuration file located at `repose-aggregator/src/config/styles/.scalafix.conf`
3. WHEN a subproject contains Scala source files, THE Scalafix_Plugin SHALL analyze those files using the shared configuration

### Requirement 3: Configuration File

**User Story:** As a developer, I want a `.scalafix.conf` file with appropriate linting rules, so that Scala code quality is enforced with modern, well-maintained rules.

#### Acceptance Criteria

1. THE Scalafix_Configuration SHALL be located at `repose-aggregator/src/config/styles/.scalafix.conf` in HOCON format
2. THE Scalafix_Configuration SHALL enable the DisableSyntax rule to catch unsafe language constructs
3. THE Scalafix_Configuration SHALL enable the OrganizeImports rule to enforce consistent import ordering
4. THE Scalafix_Configuration SHALL enable the LeakingImplicitClassVal rule to detect implicit class parameter leaks
5. THE Scalafix_Configuration SHALL enable the NoValInForComprehension rule to prevent val declarations in for comprehensions
6. THE Scalafix_Configuration SHALL enable the ProcedureSyntax rule to flag deprecated procedure-style method declarations
7. THE Scalafix_Configuration SHALL configure DisableSyntax to disallow `var`, `null`, and `throw` keywords

### Requirement 4: Formatting Concern Coverage

**User Story:** As a build engineer, I want the migration to document how old Scalastyle regex checks map to Scalafix equivalents, so that the team understands what coverage is retained and what gaps exist.

#### Acceptance Criteria

1. WHEN the Scalafix_Configuration is created, THE Build_System SHALL include inline comments documenting which Scalastyle checks are covered by Scalafix rules
2. THE Scalafix_Configuration SHALL document any formatting checks from the Scalastyle_Config that have no direct Scalafix equivalent
3. IF a Scalastyle regex check has no Scalafix equivalent, THEN THE Build_System SHALL note the gap as a comment in the configuration file recommending Scalafmt for whitespace formatting concerns

### Requirement 5: Check Task Integration

**User Story:** As a developer, I want Scalafix checks to run as part of the standard `check` task, so that Scala linting is enforced alongside Checkstyle and CodeNarc without requiring a separate command.

#### Acceptance Criteria

1. THE Build_System SHALL wire the `checkScalafix` task as a dependency of the `check` lifecycle task in each subproject
2. WHEN a developer runs `./gradlew check`, THE Build_System SHALL execute `checkScalafix` alongside `checkstyleMain`, `codenarcMain`, and other verification tasks
3. IF `checkScalafix` detects a rule violation, THEN THE Build_System SHALL fail the build with a descriptive error message identifying the file and violation

### Requirement 6: Source Set Exclusions

**User Story:** As a developer, I want generated source code excluded from Scalafix analysis and test sources included, so that only human-written code is linted while maintaining coverage of test code.

#### Acceptance Criteria

1. THE Scalafix_Plugin SHALL exclude the `generated` source set from analysis
2. THE Scalafix_Plugin SHALL include the `main` source set in analysis
3. THE Scalafix_Plugin SHALL include the `test` source set in analysis
4. THE Scalafix_Plugin SHALL include the `integrationTest` source set in analysis

### Requirement 7: Auto-Fix Capability

**User Story:** As a developer, I want to run Scalafix in both check-only and auto-fix modes, so that I can detect violations in CI and automatically fix them locally.

#### Acceptance Criteria

1. WHEN a developer runs `./gradlew checkScalafix`, THE Scalafix_Plugin SHALL report violations without modifying source files
2. WHEN a developer runs `./gradlew scalafix`, THE Scalafix_Plugin SHALL automatically apply fixes to source files where rules support auto-fixing
3. THE Build_System SHALL document both commands in a code comment near the plugin configuration

### Requirement 8: Build Compatibility

**User Story:** As a build engineer, I want the Scalafix plugin to be compatible with the existing build environment, so that it integrates without breaking the current toolchain.

#### Acceptance Criteria

1. THE Scalafix_Plugin SHALL be compatible with Gradle 6.9.4
2. THE Scalafix_Plugin SHALL be compatible with Scala 2.12.8
3. THE Scalafix_Plugin SHALL not conflict with existing plugins including Scoverage, Checkstyle, CodeNarc, JAXB, Shadow, and nebula publishing plugins
4. WHEN the Scalafix_Plugin is applied, THE Build_System SHALL continue to compile and test all subprojects without regressions

### Requirement 9: Legacy Cleanup

**User Story:** As a build engineer, I want all commented-out Scalastyle references removed from the build files, so that the codebase is clean and does not retain dead configuration.

#### Acceptance Criteria

1. THE Build_System SHALL remove the commented-out `classpath 'org.github.ngbinh.scalastyle:gradle-scalastyle-plugin_2.11:1.0.1'` line from the buildscript dependencies
2. THE Build_System SHALL remove the commented-out `apply plugin: 'scalaStyle'` line from the subprojects block
3. THE Build_System SHALL remove the commented-out `scalaStyle { ... }` configuration block from the subprojects block
4. THE Build_System SHALL remove the commented-out `check.dependsOn scalaStyle` line from the subprojects block
