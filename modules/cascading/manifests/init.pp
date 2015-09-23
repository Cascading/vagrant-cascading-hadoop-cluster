class cascading{

  file { ["/opt/tools/", "/opt/tools/bin"]:
    ensure => "directory"
  }

  exec { "download_sdk":
    command => "wget -P /tmp -i http://files.cascading.org/sdk/2.7/latest.txt",
    path => $path,
    # S3 can be slow at times hence a longer timeout
    timeout => 1800,
    unless => "ls /opt | grep CascadingSDK",
    require => Package["openjdk-7-jdk"]
  }

  exec { "unpack_sdk" :
    command => "tar xf /tmp/Cascading*tgz -C /opt && mv /opt/Cascading*SDK* /opt/CascadingSDK",
    path => $path,
    unless => "ls /opt | grep CascadingSDK",
    require => Exec["download_sdk"]
  }

  exec { "sdk_permissions" :
    command => "chown -R vagrant /opt/CascadingSDK",
    path => $path,
    require => Exec["unpack_sdk"]
  }


  file { "/etc/profile.d/ccsdk.sh":
    source => "puppet:///modules/cascading/ccsdk.sh",
    owner => root,
    group => root,
  }
  
  file { "/opt/tools/bin/sbt":
    source => "puppet:///modules/cascading/sbt",
    owner => root,
    group => root,
    mode => 755,
  }

  file { "/home/vagrant/.cascading/default.properties":
    source => "puppet:///modules/cascading/dotcascading",
    owner => vagrant,
    group => vagrant,
  }

  file { "/home/vagrant/.cascading/":
    ensure => "directory",
    owner => vagrant,
    group => vagrant,
  }

  exec { "download_leiningen":
       command => "wget -q https://raw.github.com/technomancy/leiningen/stable/bin/lein -O /opt/tools/bin/lein && chmod +x /opt/tools/bin/lein",
       path => $path,
       creates => "/opt/tools/bin/lein",
       require => File["/opt/tools/bin"],
  }
  
  exec { "download_sbt_jar":
       command => "wget -q http://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch//0.13.1/sbt-launch.jar -O /opt/tools/bin/sbt-launch.jar",
       path => $path,
       creates => "/opt/tools/bin/sbt-launch.jar",
       require => File["/opt/tools/bin"],
  }

  exec { "download_gradle":  
       command => "wget -q http://services.gradle.org/distributions/gradle-1.10-bin.zip -O /tmp/gradle.zip && unzip -o /tmp/gradle.zip -d /opt/tools",
       path => $path,
       creates => "/opt/tools/gradle-1.10",
       require => Package["unzip"]
  }

  package { "unzip":
    ensure => "installed"
  }

  package { "curl":
    ensure => "installed"
  }
}
