# Elasticsearch Reference Wrapper Cookbook

## Overview
This is a reference cookbook, demonstrating how customers would be able to configure an Elasticsearch standalone instance or cluster.
It's a [wrapper](https://blog.chef.io/2017/02/14/writing-wrapper-cookbooks/) cookbook wrapping the excellent [Elasticsearch Chef Cookbook](https://github.com/elastic/cookbook-elasticsearch)

Please refer to the upstream cookbook's [README](https://github.com/elastic/cookbook-elasticsearch/blob/master/README.md) for latest details.

## Performance Tuning
Important! For latest Elasticsearch and hardware recommendations on this topic be sure to ask your Customer Architect for the information from the "Scaling Chef Automate Beyond 50,000 nodes" document.

The following performance tuning settings are required in order to achieve the desired throughput rates on the recommended hardware.

### Minimum Master Nodes
Elasticsearch recommends that you set minimum_master_nodes to (ClusterSize/2)+1 this ensures that you never end up with a split brain scenario where different nodes end up with a different view of the world. For our recommended cluster sizes this is 2 for 3 node clusters and 4 for 6 node clusters.

This setting ends up in `/etc/elasticsearch/elasticsearch.yml`

```
discovery.zen.minimum_master_nodes: 2
```

If you need to change this on a live cluster, for example if you expand from 3 to 6 elasticsearch cluster nodes. You can set it with curl on any node in your cluster. Once set on a single node the setting will apply to all.

### JVM settings
Configure Elasticsearch’s JVM heap size to be approximately 25% of the total system RAM (Elasticsearch uses off-heap caching for data).

### File handles
Elasticsearch’s performance may be limited by the maximum number of file descriptors it can open. This is typically set by the limits.conf configuration file in Linux and tested using the `ulimit -n` command.  To adjust this setting, see the documentation for your operating system.  For more information, see:  https://www.elastic.co/guide/en/elasticsearch/guide/current/_file_descriptors_and_mmap.html

### Shard Count
Elasticsearch uses sharding to evenly distribute the data across the data nodes - this allows you to scale both storage and performance by adding more Elasticsearch nodes to your cluster!
The default shard count for Elasticsearch is 5, which is optimal for 5 data nodes.  In most cases, you want to adjust the shard count to equal the number of nodes in your Elasticsearch cluster - up to 9 nodes.

### Indexing throttle
Elasticsearch will throttle indexing while segments are merging. By default this is set very conservatively. We set this to 100MB which is Elastic’s recommend value for SSD storage:

```
indices.store.throttle.max_bytes_per_sec: "100mb"
```

## ToDo
 - Demonstrate backups/restores
 - Provisioning example, perhaps with Terraform
 - Companion monitoring cookbook
