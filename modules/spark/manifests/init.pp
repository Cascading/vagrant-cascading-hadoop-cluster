class spark {
  $spark_version = "1.5.0"
  $hadoop_version = "2.7.1" # installed Hadoop version
  $hadoop_spark = "2.6" # Hadoop version for spark compatibility
  $spark_home = "/opt/spark-${spark_version}-bin-hadoop${hadoop_spark}"
  $spark_tarball = "spark-${spark_version}-bin-hadoop${hadoop_spark}.tgz"

  package { "scala" :
    ensure => present,
    require => Exec['apt-get update']
  }

  exec { "download_spark":
    command => "/tmp/grrr spark/spark-${spark_version}/spark-${spark_version}-bin-hadoop${hadoop_spark}.tgz  -O /vagrant/$spark_tarball --read-timeout=5 --tries=0",
    timeout => 1800,
    path => $path,
    creates => "/vagrant/$spark_tarball",
    require => [ Package["scala"], Exec["download_grrr"]]
  }

  exec { "unpack_spark" :
    command => "tar xf /vagrant/${spark_tarball} -C /opt",
    path => $path,
    creates => "${spark_home}",
    require => Exec["download_spark"]
  }

  file { "/etc/profile.d/spark-path.sh":
    content => template("spark/spark-path.sh.erb"),
    owner => vagrant,
    group => root,
  }

  # for spark standalone mode
  file { "${spark_home}/logs":
    ensure => "directory",
    owner  => "mapred",
    group  => "mapred",
    mode   => 755,
    require => Exec["unpack_spark"]
  }
  exec { "spark_slaves" :
    command => "ln -s /opt/hadoop-${hadoop_version}/etc/hadoop/slaves ${spark_home}/conf/slaves",
    path => $path,
    creates => "${spark_home}/conf/slaves",
    require => Exec["unpack_spark"]
  }
}
