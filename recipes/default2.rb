#
# Cookbook:: elasticsearch_reference
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

include_recipe 'java'

elasticsearch_user 'elasticsearch' do
  username 'elasticsearch'
  groupname 'elasticsearch'
  shell '/bin/bash'
  comment 'Elasticsearch User'
  action :create
end

elasticsearch_install 'elasticsearch' do
  type 'package'
  version '5.6.0'
  action :install
end

elasticsearch_configure 'elasticsearch' do
  allocated_memory '512m'
  configuration ({
    'cluster.name' => node['elasticsearch']['conf']['cluster-name'],
    'node.name' => node['fqdn'],
    'http.port' => 9200,
    'discovery.zen.minimum_master_nodes' => 2
  })
end

elasticsearch_service 'elasticsearch' do
 action [:configure, :enable]
end

elasticsearch_plugin 'x-pack'
