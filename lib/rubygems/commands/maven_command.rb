require 'rubygems/command'
require 'mvn_gem'

class Gem::Commands::MavenCommand < Gem::Command

  def initialize
    super 'maven', 'Install a Maven-published Java library as a gem'
  end

  def execute
    args = options[:args]

    raise "usage: gem maven <group id> <artifact id> <version>" unless args.length == 3
    MavenGem.install(*options[:args])
  end

end

