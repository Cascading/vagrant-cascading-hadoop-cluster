include base

class{ 'hadoop':
  slaves_file => "puppet:///modules/hadoop/slaves-single",
  hdfs_site_file => "puppet:///modules/hadoop/hdfs-site-single.xml"
}
class{ 'hbase':
  regionservers_file => "puppet:///modules/hbase/regionservers-single",
  hbase_site_file => "puppet:///modules/hbase/hbase-site-single.xml"
}

include hbase
#include hive
include phoenix
include spark
include avahi
include cascading
