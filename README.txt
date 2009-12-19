= MavenGem

* http://www.jruby.org

== DESCRIPTION:

MavenGem is a tool, library, and gem plugin to install any Maven-published
Java library as though it were a gem.

== FEATURES:

* First release!
* maven_gem executable to install
** use pom file location, pom file URL, or group ID, artifact ID, and version
* gem plugin for "maven" command, same params (RubyGems 1.3.2+)

== PROBLEMS:

* No dependency tracking using Maven dependencies
* No support for gems with more than one group ID
* No support for gems with alphanumeric version numbers
* No tests, minimal docs :)

== SYNOPSIS:

maven_gem <pom url>
maven_gem <pom file>
maven_gem <group ID> <artifact ID> <version>

or "gem maven" with same args (RubyGems 1.3.2+)

== REQUIREMENTS:

JRuby 1.2.0 or higher. RubyGems 1.3.2 or higher for gem plugin.

== INSTALL:

gem install maven_gem

