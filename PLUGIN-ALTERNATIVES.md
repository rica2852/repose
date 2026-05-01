# Gradle Plugin Alternatives Analysis

This document provides analysis and recommendations for the plugins that were commented out during the Java 11 upgrade.

## Summary of Commented-Out Plugins

### 1. ❌ Scalastyle Plugin (`org.github.ngbinh.scalastyle:gradle-scalastyle-plugin_2.11:1.0.1`)

**Status**: Deprecated/Unavailable  
**Original Purpose**: Static code analysis for Scala code

**Recommended Alternative**: [Scalafix Gradle Plugin](https://github.com/cosmicsilence/gradle-scalafix)

**Why Scalafix?**
- Modern, actively maintained (latest version 0.2.6 from Nov 2025)
- More powerful than Scalastyle - can automatically fix issues, not just report them
- Better Scala 2.12+ support
- Integrates well with modern Gradle versions

**Implementation**:
```groovy
buildscript {
    dependencies {
        classpath 'io.github.cosmicsilence:gradle-scalafix:0.2.6'
    }
}

// In subprojects
apply plugin: 'io.github.cosmicsilence.scalafix'

scalafix {
    configFile = file("$rootDir/repose-aggregator/src/config/styles/scalafix.conf")
}
```

**Migration Notes**:
- You'll need to convert your existing `scalastyle_config.xml` to Scalafix's `.scalafix.conf` format
- Scalafix uses different rule names, but covers similar checks
- Can run both linting and auto-fixing: `./gradlew scalafix` (fix) or `./gradlew checkScalafix` (check only)

---

### 2. ⚠️ HTTP Builder NG Plugin (`gradle.plugin.io.github.http-builder-ng:http-plugin:0.1.1`)

**Status**: Dormant (project maintainers stepped away)  
**Original Purpose**: Making HTTP requests from Gradle tasks (specifically for `publishToPackageRepo`)

**Current Situation**:
- The plugin still works but is no longer maintained
- Used only for the `publishToPackageRepo` task which is already commented out

**Recommended Alternatives**:

#### Option A: Keep it commented out (RECOMMENDED)
Since the task is already disabled and the plugin is dormant, leave it commented out unless you actually need to publish to the package repository.

#### Option B: Use HttpBuilder-NG library directly
If you need the functionality, use the library directly in a custom task:

```groovy
buildscript {
    dependencies {
        classpath 'io.github.http-builder-ng:http-builder-ng-core:1.0.4'
    }
}

task publishToPackageRepo {
    doLast {
        def http = groovyx.net.http.HttpBuilder.configure {
            request.uri = 'http://your-repo.com'
        }
        // Make HTTP calls
    }
}
```

#### Option C: Use Gradle's built-in HTTP capabilities
For simple HTTP operations, use Gradle's native capabilities:

```groovy
task publishToPackageRepo {
    doLast {
        def url = new URL('http://your-repo.com/api')
        def connection = url.openConnection()
        connection.requestMethod = 'POST'
        // ... configure and execute
    }
}
```

---

### 3. ⚠️ Gradle Git Plugin (`org.ajoberstar:gradle-git:1.7.2`)

**Status**: Archived (maintainer considers it obsolete)  
**Original Purpose**: Git operations from Gradle (likely for tagging releases)

**Current Situation**:
- You're already using `com.netflix.nebula:gradle-git-scm-plugin:3.0.1` which provides similar functionality
- The old `org.ajoberstar:gradle-git` is archived and no longer maintained

**Recommended Alternative**: [Grgit](https://github.com/ajoberstar/grgit) (newer version)

**Why Grgit?**
- Same author, but modernized
- Better Gradle integration
- Still maintained (though feature-frozen)
- Latest version: 5.2.2

**Implementation**:
```groovy
buildscript {
    dependencies {
        classpath 'org.ajoberstar.grgit:grgit-gradle:5.2.2'
    }
}

// In root project
apply plugin: 'org.ajoberstar.grgit.service'

// Access git info
def grgit = org.ajoberstar.grgit.Grgit.open(currentDir: project.rootDir)
version = grgit.describe()
```

**Note**: The maintainer considers this "feature frozen" but it's stable and works well with modern Gradle/Java versions.

---

## Recommendations Priority

### High Priority
1. ✅ **Leave HTTP plugin commented out** - Not needed unless you're actively publishing to package repos
2. ✅ **Keep using nebula.gradle-git-scm** - Already working, no action needed

### Medium Priority  
3. 🔄 **Consider Scalafix** - Only if you want Scala linting/formatting
   - Current impact: None (checks are skipped)
   - Benefit: Better code quality for Scala code
   - Effort: Medium (need to create config file and test)

### Low Priority
4. 📝 **Document the missing plugins** - Already done in this file

---

## Implementation Plan

If you want to restore Scala linting:

1. Add Scalafix plugin to buildscript dependencies
2. Create `.scalafix.conf` configuration file
3. Apply plugin in subprojects with Scala code
4. Run `./gradlew checkScalafix` to verify
5. Optionally add to `check` task

Example minimal `.scalafix.conf`:
```hocon
rules = [
  OrganizeImports
  DisableSyntax
  LeakingImplicitClassVal
  NoValInForComprehension
  ProcedureSyntax
]

DisableSyntax.noVars = true
DisableSyntax.noThrows = true
DisableSyntax.noNulls = true
```

---

## Conclusion

The commented-out plugins are not critical for the build to function. The main functionality (building, testing, packaging) works without them. Consider adding Scalafix only if Scala code quality checks are important for your project.
