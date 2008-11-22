#!/usr/bin/env jruby
require 'rexml/document'
require 'net/http'
require 'rubygems'
require 'yaml'
require 'fileutils'

module PomSpec
  def self.from_file(filename, options = {})
    puts "Reading POM from #{filename}" if options[:verbose]
    pom_doc = REXML::Document.new(File.read(filename))
    from_doc(pom_doc, options)
  end

  def self.from_url(url, options = {})
    uri = URI.parse(url)
    puts "Retrieving POM from #{url}" if options[:verbose]
    pom_doc = REXML::Document.new(Net::HTTP.get(uri))
    from_doc(pom_doc, options)
  end
  
  def self.from_doc(pom_doc, options = {})
    spec = Gem::Specification.new

    spec.platform = "java"
    
    artifact = nil
    group = nil
    version = nil
    
    puts "Processing POM" if options[:verbose]
    pom_doc.elements.each("/project/*") do |element|
      case element.name
      when "artifactId"
        spec.name = element.text
        artifact = element.text
      when "groupId"
        group = element.text
      when "version"
        spec.version = element.text
        version = element.text
      when "description"
        spec.description = element.text
      when "dependencies"
        element.elements.each do |dependency|
          dep_artifact = dependency.elements[2].text
          dep_version = dependency.elements[3].text

          new_dep = Gem::Dependency.new(dep_artifact, "=#{dep_version}")
          spec.dependencies << new_dep
        end
      when "developers"
        element.elements.each("developer") do |developer|
          spec.authors << developer.elements[2].text
        end
      when "url"
        spec.homepage = element.text
      end
    end
    
    group_dir = group.gsub('.', '/')
    spec.lib_files << "#{artifact}.rb"
    gem_name = "#{artifact}-#{version}"
    gem_dir = "#{gem_name}.#{$$}"
    remote_dir = "#{group_dir}/#{artifact}/#{version}"
    jar_file = "#{gem_name}.jar"
    spec.lib_files << jar_file
    
    puts "Using #{gem_dir} work dir" if options[:verbose]
    FileUtils.mkdir_p(gem_dir)
    FileUtils.mkdir_p("#{gem_dir}/lib")
    
    full_url = "#{maven_base_url}/#{remote_dir}/#{jar_file}"
    puts "Fetching #{full_url}" if options[:verbose]
    system "wget -q #{full_url} -O #{gem_dir}/lib/#{jar_file}" or
      fail "ERROR: Could not fetch #{full_url}"
    
    ruby_file = <<END
begin
  require 'java'
  require File.dirname(__FILE__) + '/#{jar_file}'
rescue LoadError
  puts 'JAR-based gems require JRuby to load. Please visit www.jruby.org.'
  raise
end
END
    ruby_file = "#{gem_dir}/lib/#{artifact}.rb"
    puts "Writing #{ruby_file}" if options[:verbose]
    File.open(ruby_file, 'w') do |file|
      file.write(ruby_file)
    end
    
    metadata_file = "#{gem_dir}/metadata"
    puts "Writing #{metadata_file}" if options[:verbose]
    File.open(metadata_file, 'w') do |file|
      file.write(spec.to_yaml)
    end
    
    gem_file = "#{gem_name}-java.gem"
    
    puts "Building #{gem_file}" if options[:verbose]
    Dir.chdir(gem_dir) do
      fail unless
        system('gzip metadata') and
        system('tar czf data.tar.gz lib/*') and
        system("tar cf ../#{gem_file} data.tar.gz metadata.gz")
    end
    
    FileUtils.rm_rf(gem_dir)
    puts "Done!" if options[:verbose]
    
    "#{gem_name}-java.gem"
  end
  
  def self.maven_base_url
    "http://mirrors.ibiblio.org/pub/mirrors/maven2"
  end
end

if __FILE__ == $0
  if ARGV[0]
    if ARGV[0] =~ %r[^http://]
      spec = PomSpec.from_url(ARGV[0])
    else
      spec = PomSpec.from_file(ARGV[0])
    end
  else
    raise ArgumentError, "specify filename or URL on command line"
  end
end