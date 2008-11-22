require 'pom2gem'
require 'rubygems/gem_runner'

module MavenGem
  def MavenGem.install(pom_location)
    if pom_location =~ %r[^http://]
      gem = PomSpec.from_url(pom_location)
    else
      gem = PomSpec.from_file(pom_location)
    end
    Gem::GemRunner.new.run(["install", gem])
  end
end

case ARGV[0]
when 'install'
  MavenGem.install ARGV[1]
end