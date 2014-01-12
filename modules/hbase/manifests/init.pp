class hbase {
  $hbase_version = "0.94.15"
  $hbase_home = "/opt/hbase-${hbase_version}"
  $hbase_tarball = "hbase-${hbase_version}.tar.gz"

  file { "/srv/zookeeper":
    ensure => "directory"
  }

  exec { "download_hbase":
    command => "/tmp/grrr /hbase/hbase-${hbase_version}/$hbase_tarball -O /vagrant/$hbase_tarball --read-timeout=5 --tries=0",
    timeout => 1800,
    path => $path,
    creates => "/vagrant/$hbase_tarball",
    require => [ Package["openjdk-6-jdk"], Exec["download_grrr"]]
  }

  exec { "unpack_hbase" :
    command => "tar xf /vagrant/${hbase_tarball} -C /opt",
    path => $path,
    creates => "${hbase_home}",
    require => Exec["verify_tarball"]
  }

  file {
    "${hbase_home}/conf/regionservers":
      source => "puppet:///modules/hbase/regionservers",
      mode => 644,
      owner => root,
      group => root,
      require => Exec["unpack_hbase"]
  }

  file {
    "${hbase_home}/conf/hbase-site.xml":
      source => "puppet:///modules/hbase/hbase-site.xml",
      mode => 644,
      owner => root,
      group => root,
      require => Exec["unpack_hbase"]
  }

  file {
    "${hbase_home}/conf/hbase-env.sh":
      source => "puppet:///modules/hbase/hbase-env.sh",
      mode => 644,
      owner => root,
      group => root,
      require => Exec["unpack_hbase"]
  }

  file { "/etc/profile.d/hbase-path.sh":
    content => template("hbase/hbase-path.sh.erb"),
    owner => root,
    group => root,
  }

}
