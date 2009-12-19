require File.dirname(__FILE__) + '/../spec_helper'

describe MavenGem::PomFetcher do
  
  before(:each) do
    @ant_path = File.join(FIXTURES, 'ant.pom')
    @ant_pom = File.read(@ant_path)
  end

  it "removes namespaces from pom file" do
    pom = MavenGem::PomFetcher.clean_pom(@ant_pom)
    pom.should =~ /<project>/
  end

  it "reads the pom file from a url when the protocol is http" do
    ant_url = "http://mirrors.ibiblio.org/pub/mirrors/maven2/ant/ant/1.6.5/ant.pom"
    Net::HTTP.expects(:get).with(URI.parse(ant_url)).returns(@ant_pom)

    pom = MavenGem::PomFetcher.fetch_pom(ant_url)
    pom.should == @ant_pom
  end

  it "reads the pom file from the system when the path is not an url" do
    File.expects(:read).with(@ant_path).returns(@ant_pom)

    pom = MavenGem::PomFetcher.fetch_pom(@ant_path)
    pom.should == @ant_pom
  end
end
