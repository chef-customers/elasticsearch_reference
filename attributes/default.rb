# JDK
default['java']['jdk_version'] = '8'
default['java']['install_flavor'] = 'oracle'
default['java']['jdk']['8']['x86_64']['url'] = 'https://edelivery.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz'
default['java']['jdk']['8']['x86_64']['checksum'] = '62b215bdfb48bace523723cdbb2157c665e6a25429c73828a32f00e587301236'
default['java']['oracle']['accept_oracle_download_terms'] = true

# Elasticsearch
default['elasticsearch']['cluster_name'] = 'myorg-cluster1'
default['elasticsearch']['es_number_of_shards'] = 5
default['elasticsearch']['es_max_content_length'] = "1gb"
