require 'spec_helper'
require 'yaml'

nodes_dir_path = File.expand_path(File.dirname(__FILE__) << '/../../nodes')
node = YAML.load_file("#{nodes_dir_path}/osx.yml")

describe command 'test $(which brew)' do
  its(:exit_status) { should eq 0 }
end

node['brew']['add_repositories'].each do |repo|
  describe command "brew tap | grep -q '#{repo}'" do
    its(:exit_status) { should eq 0 }
  end
end

node['brew']['install_packages'].each do |package|
  describe command "brew list | grep -q #{package}" do
    its(:exit_status) { should eq 0 }
  end
end

node['brew']['install_apps'].each do |app|
  describe command "brew cask list | grep -q #{app}" do
    its(:exit_status) { should eq 0 }
  end
end
