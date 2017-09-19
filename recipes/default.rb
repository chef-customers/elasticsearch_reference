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

elasticsearch_config = Hash.new.tap do |es_hash|
  es_hash['cluster.name'] = node['elasticsearch']['cluster_name'] || 'elasticsearch'
  es_hash['node.name'] = node['hostname']
  es_hash['network.host'] = node['ipaddress'],
  es_hash['discovery.type'] = 'ec2' if node['aws']
  es_hash['cloud.aws.region'] = node['aws']['region'] if node['aws'] && node['aws'].has_key?('region')
  es_hash['http.max_content_length'] = node['elasticsearch']['es_max_content_length']
end

elasticsearch_install 'elasticsearch' do
  type 'tarball' # type of install
  dir '/opt/' # where to install
  download_url 'https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.5.2.tar.gz'
  download_checksum '0870e2c0c72e6eda976effa07aa1cdd06a9500302320b5c22ed292ce21665bf1'
  action :install # could be :remove as well
end

half_system_ram = (node['memory']['total'].to_i * 0.5).floor / 1024

elasticsearch_configure 'elasticsearch' do
  # if you override one of these, you probably want to override all
  path_home     '/opt/elasticsearch'
  path_conf     '/etc/elasticsearch'
  path_data     '/var/opt/elasticsearch'
  path_logs     '/var/log/elasticsearch'
  path_pid      '/var/run/elasticsearch'
  path_plugins  '/opt/elasticsearch/plugins'
  path_bin      '/opt/elasticsearch/bin'
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

execute 'install discovery-ec2 plugin' do
  command 'sudo /opt/elasticsearch-5.5.2/bin/elasticsearch-plugin install discovery-ec2'
  not_if { ::Dir.exist?('/opt/elasticsearch-5.5.2/plugins/discovery-ec2') }
  only_if { node['aws'] }
end

elasticsearch_service 'elasticsearch' do
  action :configure
end

elasticsearch_plugin 'x-pack'
