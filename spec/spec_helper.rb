begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'maven_gem'
require 'rubygems'
require 'mocha'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end

FIXTURES = File.join(File.dirname(__FILE__), 'fixtures')
