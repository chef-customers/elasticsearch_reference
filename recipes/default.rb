#
# Cookbook:: elasticsearch_reference
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

include_recipe 'sysctl::apply'
include_recipe 'java'
elasticsearch_user 'elasticsearch'

directory '/var/run/elasticsearch' do
  action :create
  recursive true
  owner 'elasticsearch'
  group 'elasticsearch'
end

#To enable bootstrap mlockall we need to give the elasticsearch server unlimited memlock.
#The proper way to do this with systemd is a config file for the service and daemon-reload.
directory '/etc/systemd/system/elasticsearch.service.d' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

file '/etc/systemd/system/elasticsearch.service.d/elasticsearch.conf' do
  action :create
  owner 'root'
  group 'root'
  mode '0644'
  content <<-EOF.gsub(/^\s+/, '')
  [Service]
  LimitMEMLOCK=infinity
  EOF
  notifies :run, 'execute[reload_systemd_config]', :immediately
end

execute 'reload_systemd_config' do
  command 'systemctl daemon-reload'
  action :nothing
end

es_cluster_name = node['elasticsearch']['cluster_name'] || 'elasticsearch'
query = "chef_environment:#{node.chef_environment} AND cluster_name:#{es_cluster_name}"
Chef::Log.warn "query: #{query}"
cluster_members = []
search(:node, query, filter_result: { 'fqdn' => ['fqdn'] }).each do |result|
  cluster_members << result['fqdn']
end
listen_ip = node['ipaddress']

Chef::Log.warn "cluster members #{cluster_members}"

elasticsearch_config = Hash.new.tap do |es_hash|
  es_hash['bootstrap.memory_lock'] = true
  es_hash['cluster.name'] = es_cluster_name
  es_hash['node.name'] = node['hostname']
  es_hash['network.host'] = listen_ip
  es_hash['discovery.zen.ping.unicast.hosts'] = cluster_members.sort
  es_hash['http.max_content_length'] = node['elasticsearch']['es_max_content_length']
end

elasticsearch_install 'elasticsearch' do
  type 'package' # type of install
  version node['elasticsearch']['version']
  action :install # could be :remove as well
end

elasticsearch_configure 'elasticsearch' do
  logging(action: 'INFO')

  jvm_options %w(
              -Dlog4j2.disable.jmx=true
              -XX:+UseParNewGC
              -XX:+UseConcMarkSweepGC
              -XX:CMSInitiatingOccupancyFraction=75
              -XX:+UseCMSInitiatingOccupancyOnly
              -XX:+HeapDumpOnOutOfMemoryError
              -XX:+PrintGCDetails
              -Xss512k
  )

  configuration elasticsearch_config
  action :manage
end

elasticsearch_service 'elasticsearch' do
  action :configure
end

# example plugin
# elasticsearch_plugin 'x-pack'
