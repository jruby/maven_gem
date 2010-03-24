$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'maven_gem/xml_utils'
require 'maven_gem/pom_spec'
require 'maven_gem/pom_fetcher'
require 'rubygems'
require 'rubygems/gem_runner'

module MavenGem
  def self.install(group, artifact = nil, version = nil)
    gem = build(group, artifact, version)
    Gem::GemRunner.new.run(["install", gem])
  ensure
    FileUtils.rm_f(gem) if gem
  end

  def self.build(group, artifact = nil, version = nil)
    gem = if artifact
      url = MavenGem::PomSpec.to_maven_url(group, artifact, version)
      MavenGem::PomSpec.build(url)
    else
      MavenGem::PomSpec.build(group)
    end
  end
end
