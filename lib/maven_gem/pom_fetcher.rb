require 'net/http'
require 'uri'

module MavenGem
  class PomFetcher

    def self.fetch(path, options = {})
      puts "Reading POM from #{path}" if options[:verbose]

      fetch_pom(path, options)
    end

    def self.clean_pom(pom) #avoid namespaces errors and gotchas
      pom.gsub(/<project[^>]+/, '<project>')
    end

    def self.fetch_pom(path, options = {})
      path =~ /^http:\/\// ? fetch_from_url(path, options) :
        fetch_from_file(path, options)
    end

    private
    def self.fetch_from_url(path, options = {})
      Net::HTTP.get(URI.parse(path))
    end

    def self.fetch_from_file(path, options = {})
      File.read(path)
    end
  end
end
