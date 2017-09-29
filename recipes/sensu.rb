#
# Cookbook:: elasticsearch_reference
# Recipe:: sensu
#
# Copyright:: 2017, The Authors, All Rights Reserved.

include_recipe 'sensu::default'

subscriptions = []
#subscriptions += node['sensu']['subscriptions']
#subscriptions << 'base'

sensu_client node['fqdn'] do
  address node['ipaddress']
  subscriptions subscriptions
end

include_recipe "sensu::client_service"

# required to build the sensu elasticsearch plugin gem
execute "yum groupinstall 'Development Tools' -y"

node['myorg']['sensu']['plugins'].each do |plugin, version|
  sensu_gem plugin do
    version version
  end
end


sensu_check 'es_health' do
  command "check-es-cluster-status.rb -h #{node['ipaddress']}"
  handlers ["default"]
  subscribers ["elasticsearch"]
  interval 30
  additional(:notification => "Elasticsearch is not running", :occurrences => 5)
end



#check-es-circuit-breakers.rb
#check-es-cluster-health.rb
#bin/check-es-file-descriptors.rb
#check-es-heap.rb
#check-es-indexes.rb
#check-es-indicies-sizes.rb
#check-es-node-status.rb
#check-es-query-count.rb
#check-es-query-exists.rb
#check-es-query-ratio.rb
#check-es-shard-allocation-status.rb
#handler-es-delete-indices.rb
#metrics-es-cluster.rb
#metrics-es-node.rb
#metrics-es-node-graphite.rb
