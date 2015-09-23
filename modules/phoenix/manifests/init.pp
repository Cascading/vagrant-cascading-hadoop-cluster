class phoenix {
  $phoenix_version = "4.5.1"
  $hbase_compat = "1.1" # phoenix compatibility version
  $hbase_version = "1.1.1" # actual installed version
  $phoenix_tarball = "phoenix-${phoenix_version}-HBase-${hbase_compat}-bin.tar.gz"
  $phoenix_home = "/opt/phoenix-${phoenix_version}-HBase-${hbase_compat}-bin"
  
  $server_jar = "phoenix-${phoenix_version}-HBase-${hbase_compat}-server.jar"
  $client_jar = "phoenix-${phoenix_version}-HBase-${hbase_compat}-client.jar"

  exec { "download_phoenix":
    command => "/tmp/grrr phoenix/phoenix-${phoenix_version}-HBase-${hbase_compat}/bin/phoenix-${phoenix_version}-HBase-${hbase_compat}-bin.tar.gz -O /vagrant/${phoenix_tarball} --read-timeout=5 --tries=0",
    timeout => 1800,
    path => $path,
    creates => "/vagrant/${phoenix_tarball}",
    require => [ Exec["download_grrr"]]
  }

  exec { "unpack_phoenix" :
    command => "tar xf /vagrant/${phoenix_tarball} -C /opt",
    path => $path,
    creates => "${phoenix_home}",
    require => Exec["download_phoenix", "unpack_hadoop"]
  }

  file { "/opt/hbase-${hbase_version}/lib/${server_jar}":
    ensure => 'link',
    target => "${phoenix_home}/${server_jar}",
  }
}
