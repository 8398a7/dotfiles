require 'spec_helper'
require 'yaml'

nodes_dir_path = File.expand_path(File.dirname(__FILE__) << '/../../nodes')
node = YAML.load_file("#{nodes_dir_path}/darwin.yml").deep_symbolize_keys

describe command 'test $(which brew)' do
  its(:exit_status) { should eq 0 }
end

node[:homebrew][:repositories].each do |repo|
  describe command "brew tap | grep -q '#{repo}'" do
    its(:exit_status) { should eq 0 }
  end
end

node[:homebrew][:packages].each do |package|
  describe command "brew list | grep -q #{package}" do
    its(:exit_status) { should eq 0 }
  end
end
