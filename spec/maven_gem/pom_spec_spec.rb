require File.dirname(__FILE__) + '/../spec_helper'

describe MavenGem::PomSpec do

  before(:each) do
    ant_path = File.join(FIXTURES, 'ant.pom')
    @pom = MavenGem::PomFetcher.fetch(ant_path)
  end

  describe "maven_to_gem_version" do
    it "represents alpha keyword as 0" do
      MavenGem::PomSpec.maven_to_gem_version("1.0-alpha").should == '1.0.0'
    end

    it "represents beta keyword as 1" do
      MavenGem::PomSpec.maven_to_gem_version("1.0-beta").should == '1.0.1'
    end

    it "removes non numeric characters from gem version" do
      MavenGem::PomSpec.maven_to_gem_version("1.0.0-SNAPSHOT").should == '1.0.0'
    end
  end

  describe "parse_pom" do
    it "keeps the groupId as group" do
      ant_pom.group.should == 'ant'
    end

    it "keeps the artifactId as artifact" do
      ant_pom.artifact.should == 'ant'
    end

    it "keeps the original version as maven_version" do
      ant_pom.maven_version.should == '1.6.5'
      with_non_numeric_version = @pom.gsub(/<version>1.6.5<\/version>/, '<version>1.6.6-SNAPSHOT</version>')
      MavenGem::PomSpec.parse_pom(with_non_numeric_version).maven_version.should == '1.6.6-SNAPSHOT'
    end

    it "keeps the version number as version" do
      ant_pom.version.should == '1.6.5'
      with_non_numeric_version = @pom.gsub(/<version>1.6.5<\/version>/, '<version>1.6.6-SNAPSHOT</version>')
      MavenGem::PomSpec.parse_pom(with_non_numeric_version).version.should == '1.6.6'
    end

    it "keeps the pom description as description" do
      ant_pom.description.should == 'Apache Ant'
    end

    it "keeps the project url as url" do
      ant_pom.url.should == 'http://ant.apache.org'
    end

    it "doesn't add dependencies when the node doesn't exist" do
      hudson_rake_pom.dependencies.should be_empty
    end

    it "doesn't add dependencies when are optional" do
      ant_pom.dependencies.should be_empty
    end

    it "adds dependencies when aren't optional" do
      pom = pom_with_dependencies
      pom.dependencies.map {|d| d.name}.should include('xerces.xercesImpl')
    end

    it "adds dependencies with formatted gem version" do
      pom = pom_with_dependencies
      pom.dependencies.map {|d| d.version_requirements.as_list }.flatten.should include('= 2.6.2')
    end

    it "doesn't add authors when the node doesn't exist" do
     ant_pom.authors.should be_empty
    end

    it "uses parent groupId when groupId node doesn't exist" do
      pom = hudson_rake_pom
      pom.group.should == 'org.jvnet.hudson.plugins'
    end

    it "adds authors when developers node is present" do
      pom = hudson_rake_pom

      pom.authors.should include('David Calavera')
    end

    it "uses group and artifact to create the specification name" do
      ant_pom.name.should == 'ant.ant'
      hudson_rake_pom.name.should == 'org.jvnet.hudson.plugins.rake'
    end

    it "uses group, artifact and version to create library and jar attributes" do
      pom = ant_pom
      pom.lib_name.should == 'ant.rb'
      pom.gem_name.should == 'ant.ant-1.6.5'
      pom.jar_file.should == 'ant-1.6.5.jar'
      pom.remote_dir.should == 'ant/ant/1.6.5'
      pom.remote_jar_url.should == "http://mirrors.ibiblio.org/pub/mirrors/maven2/ant/ant/1.6.5/ant-1.6.5.jar"
      pom.gem_file.should == 'ant.ant-1.6.5-java.gem'

      with_non_numeric_version = @pom.gsub(/<version>1.6.5<\/version>/, '<version>1.6.6-SNAPSHOT</version>')
      pom = MavenGem::PomSpec.parse_pom(with_non_numeric_version)
      pom.jar_file.should == 'ant-1.6.6-SNAPSHOT.jar'
      pom.gem_file.should == 'ant.ant-1.6.6-java.gem'
    end
  end

  describe "generate_spec" do
    it "generates a speficication object from a pom file" do
      spec = MavenGem::PomSpec.generate_spec(ant_pom)
      spec.should be_kind_of(Gem::Specification)
    end

    it "uses the pom version and name in the specification" do
      pom = ant_pom
      spec = MavenGem::PomSpec.generate_spec(pom)
      spec.name.should == pom.name
      spec.version.version.should == pom.version
    end

    it "uses the pom artifact to add a library file" do
      pom = ant_pom
      spec = MavenGem::PomSpec.generate_spec(pom)
      spec.lib_files.should include("lib/#{pom.artifact}.rb")
    end
  end

  describe "create_gem" do
    it "creates the gem file" do
      begin
        pom = ant_pom
        spec = MavenGem::PomSpec.generate_spec(pom)
        lambda {
          MavenGem::PomSpec.create_gem(spec, pom)
        }.should_not raise_error
      ensure
        require 'fileutils'
        FileUtils.rm_f('ant.ant-1.6.5-java.gem')
      end
    end
  end

  describe "to_maven_url" do
    it "creates an artifact jar url from group, arifact and version" do
      MavenGem::PomSpec.to_maven_url('ant', 'ant', '1.6.5').should ==
        "http://mirrors.ibiblio.org/pub/mirrors/maven2/ant/ant/1.6.5/ant-1.6.5.pom"
    end
  end

  def pom_with_dependencies
    with_deps = @pom.gsub(/<optional>true<\/optional>/, '')
    MavenGem::PomSpec.parse_pom(with_deps)
  end

  def hudson_rake_pom
    pom = MavenGem::PomFetcher.fetch(File.join(FIXTURES, 'hudson-rake.pom'))
    MavenGem::PomSpec.parse_pom(pom)
  end

  def ant_pom
    MavenGem::PomSpec.parse_pom(@pom)
  end
end
