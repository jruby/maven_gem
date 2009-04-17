require 'net/http'
require 'pom2gem'
require 'rubygems/gem_runner'

module MavenGem
  def MavenGem.install(group, artifact = nil, version = nil)
    begin
      if artifact
        # fetch pom and install
        url = MavenGem::PomSpec.maven_base_url + "/#{group}/#{artifact}/#{version}/#{artifact}-#{version}.pom"
        gem = PomSpec.from_url(url)
      else
        if group =~ %r[^http://]
          gem = PomSpec.from_url(pom_location)
        else
          gem = PomSpec.from_file(pom_location)
        end
      end
      Gem::GemRunner.new.run(["install", gem])
    ensure
      FileUtils.rm_f gem
    end
  end
end

case ARGV.shift
when 'install'
  MavenGem.install *ARGV
end