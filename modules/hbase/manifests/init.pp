class hbase($regionservers_file = undef, $hbase_site_file = undef) {
  $hbase_version = "1.1.1"
  $hbase_home = "/opt/hbase-${hbase_version}"
  $hbase_tarball = "hbase-${hbase_version}-bin.tar.gz"

  if $regionservers_file == undef {
    $_regionservers_file = "puppet:///modules/hbase/regionservers"
  }
  else {
    $_regionservers_file = $regionservers_file
  }
  if $hbase_site_file == undef {
    $_hbase_site_file = "puppet:///modules/hbase/hbase-site.xml"
  }
  else {
    $_hbase_site_file = $hbase_site_file
  }

  file { "/srv/zookeeper":
    ensure => "directory"
  }

  exec { "download_hbase":
    command => "/tmp/grrr /hbase/${hbase_version}/$hbase_tarball -O /vagrant/$hbase_tarball --read-timeout=5 --tries=0",
    timeout => 1800,
    path => $path,
    creates => "/vagrant/$hbase_tarball",
    require => [ Package["openjdk-7-jdk"], Exec["download_grrr"]]
  }

  exec { "unpack_hbase" :
    command => "tar xf /vagrant/${hbase_tarball} -C /opt",
    path => $path,
    creates => "${hbase_home}",
    require => Exec["download_hbase"]
  }

  file {
    "${hbase_home}/conf/regionservers":
      source => $_regionservers_file,
      mode => 644,
      owner => root,
      group => root,
      require => Exec["unpack_hbase"]
  }

  file {
    "${hbase_home}/conf/hbase-site.xml":
      source => $_hbase_site_file,
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
