require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "maven_gem"
    gem.summary = %Q{Packaging Maven artifacts as Rubygems.}
    gem.description = %Q{MavenGem is a command and RubyGems plugin for packaging Maven artifacts as gems.}
    gem.email = "headius@headius.com"
    gem.homepage = "http://github.com/jruby/maven_gem"
    gem.authors = ["Charles Nutter", "David Calavera"]

    gem.files = FileList['bin/*', 'lib/**/*.rb', 'History.txt', 'LICENSE', 'Rakefile', 'README.rdoc', 'VERSION']

    gem.add_development_dependency 'rspec'
    gem.add_development_dependency 'mocha'
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_opts = ['--options', "spec/spec.opts"]
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_opts = ['--options', "spec/spec.opts"]
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec
