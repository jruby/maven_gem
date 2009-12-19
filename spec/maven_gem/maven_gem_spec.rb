require File.dirname(__FILE__) + '/../spec_helper'

describe MavenGem do
  describe "build" do
    it "creates a gem with group, artifact and version" do
      begin
      lambda { 
        MavenGem.build('ant', 'ant', '1.6.5')
      }.should_not raise_error
      ensure
        require 'fileutils'
        FileUtils.rm_f('ant.ant-1.6.5-java.gem')
      end
    end
  end
end
