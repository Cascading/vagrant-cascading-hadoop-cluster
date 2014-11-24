# Vagrant + Cascading + Hadoop 2 Cluster

Clone this project to create a 4 node [Apache Hadoop](http://hadoop.apache.org) cluster with the [Cascading
SDK](http://www.cascading.org/sdk/) pre-installed.

The Cascading 2.6 SDK includes Cascading and many of its sub-projects:

* [Lingual](http://www.cascading.org/lingual/) - ANSI SQL Command Shell and JDBC Driver
* [Pattern](http://www.cascading.org/pattern/) - Machine Learning
* [Cascalog](http://cascalog.org) - Clojure DSL over Cascding
* [Scalding](https://github.com/twitter/scalding) - Scala DSL over Cascading
* [Multitool](http://www.cascading.org/multitool/) - Command line tool for managing large files
* [Load](http://www.cascading.org/load/) - Command line tool for load testing Hadoop

To make getting started as easy as possible this setup also includes build tools used by parts of the SDK:

* [gradle](http://www.gradle.org/) - build tool used by Cascading and its
  related projects
* [leiningen 2](http://leiningen.org/) - a popular build tool in the clojure
  community, which is used in the [cascalog](http://cascalog.org/) tutorial
  included in the SDK
* [sbt](http://www.scala-sbt.org/) - a popular build tool in the scala community, which is
  used in the [scalding](https://github.com/twitter/scalding/wiki) tutorial included in the SDK

This work is based on: http://cscarioni.blogspot.co.uk/2012/09/setting-up-hadoop-virtual-cluster-with.html

## Deploying the cluster

First install either [Virtual Box](http://virtualbox.org) (free) or [VMware Fusion/Workstation](http://www.vmware.com/products/fusion/) (paid) and [Vagrant](http://vagrantup.com/) for your platform. If using VMware Fusion/Workstation, you will also need a VMware + Vagrant [license](https://www.vagrantup.com/vmware).

Then simply clone this repository, change into the directory and bring the cluster up.

    $ vagrant up

This will set up 4 machines - `master`, `hadoop1`, `hadoop2` and `hadoop3`. Each of them will have two CPUs and .5GB of
RAM. If this is too much for your machine, adjust the `Vagrantfile`.

The machines will be provisioned using [Puppet](http://puppetlabs.com/). All of them will have hadoop
(apache-hadoop-2.4.1) installed, ssh will be configured and local name resolution also works.

Hadoop is installed in `/opt/hadoop-2.4.1` and all tools are in the `PATH`.

The `master` machine acts as the namenode and the yarn resource manager, the 3 others are data nodes and run node
managers.

### Networking

The cluster uses [zeroconf](http://en.wikipedia.org/wiki/Zero-configuration_networking) (a.k.a. bonjour) for name
resolution. This means that you never have to remember any IP nor will you have to fiddle with your `/etc/hosts` file.

Name resolution works from the host to all VMs and between all VMs as well.  If you are using linux, make sure you have
`avahi-daemon` installed and it is running. On a Mac everything should just work (TM) witouth doing anything.  Windows
users have to install [Bonjour for Windows](http://support.apple.com/kb/dl999) before starting the cluster.

The network used is `192.168.7.0/24`. If that causes any problems, change the `Vagrantfile` and
`modules/avahi/file/hosts` files to something that works for you. Since everything else is name based, no other change
is required.

### Starting the cluster

This cluster uses the `ssh-into-all-the-boxes-and-start-things-up`-approach, which is fine for testing.

Once all machines are up and provisioned, the cluster can be started. Log into the master, format hdfs and start the
cluster.

     $ vagrant ssh master
     $ (master) sudo prepare-cluster.sh
     $ (master) sudo start-all.sh

After a little while, all daemons will be running and you have a fully working hadoop cluster. Note that the
`prepare-cluster.sh` step is a one time action.

### Stopping the cluster

If you want to shut down your cluster, but want to keep it around for later use, shut down all the services and tell
vagrant to stop the machines like this:

     $ vagrant ssh master
     $ (master) sudo stop-all.sh
     $ exit or Ctrl-D
     $ vagrant halt

When you want to use your cluster again, simply do this:

     $ vagrant up
     $ vagrant ssh master
     $ (master) sudo start-all.sh


### Getting rid of the cluster

If you don't need the cluster anymore and want to get your disk-space back do this:

     $ vagrant destroy -f

This will only delete the VMs all local files in the directory stay untouched and can be used again, if you decide to
start up a new cluster.

## Interacting with the cluster

### Webinterface

You can access all services of the cluster with your web-browser.

* namenode: http://master.local:50070/dfshealth.jsp
* application master: http://master.local:8088/cluster
* job history server: http://master.local:19888/jobhistory

### Command line

To interact with the cluster on the command line, log into the master and use the hadoop command.

    $ vagrant ssh master
    $ (master) hadoop fs -ls /
    $ ...

You can access the host file system from the `/vagrant` directory, which means that you can drop your hadoop job in
there and run it on your own fully distributed hadoop cluster.

## Performance

Since this is a fully virtualized environment running on your computer, it will not be super-fast. This is not the goal
of this setup. The goal is to have a fully distributed cluster for testing and troubleshooting.

To not overload the host machine, has each tasktracker a hard limit of 1 map task and 1 reduce task at a time.

## Cascading SDK

Puppet will download the latest [Cascading SDK](http://www.cascading.org/sdk/) 2.6-wip build and put all SDK tools in
the `PATH`. The SDK itself can be found in `/opt/CascadingSDK`.

### Driven

The SDK allows you to install the [Driven plugin for Cascading]((http://cascading.io/driven) , by simply running
`install-driven-plugin`. This will install the plugin for the vagrant user in `/home/vagrant/.cascading/.driven-plugin`.

Installing the plugin will cause every Cascading based application to send telemetry to `https://driven.cascading.io`.
If you no longer want this to happen, you can simply delete the installation directory of the plugin mentioned above.

For more information about driven, please read the [Driven
documentation](http://docs.cascading.io/driven/1.0/getting-started/index.html).

## HBase

This version of the cluster also contains [Apache HBase](http://hbase.apache.org). The layout on disk is similar to
Hadoop. The distributition is in `/opt/hbase-<version>`. You can start the HBase cluster like so.

    $ (master) sudo start-hbase.sh

The Hadoop cluster must be running, before you issue this command, since HBase requires HDFS to be up and running.

To cluster is shut down like so:

    $ (master) sudo stop-hbase.sh

The setup is fully distributed. `hadoop1`, `hadoop2` and `hadoop3` are running a
[zookeeper](http://zookeeper.apache.org) instance and a region-server each. The HBase master is running on the `master`
VM.

The webinterface of the HBase master is http://master.local:60010.

## Hacking & Troubleshooting & Tips & Tricks

### Getting help

If something is not working right, join the [Cascading
mailinglist](https://groups.google.com/forum/#!forum/cascading-user) and post your problem there.

## Single Node setup

If your computer is not capable of running 4 VMs at a time, you can still benefit from this setup. The `single-node`
directory contains an alternative `Vagrantfile`, which only starts the `master` and deploys everything on it.

The interaction, the start- and stop sequence work the same ways as in the multi-VM cluster, except that it isn't fully
distributed. This slimmed down version of the setup also does not include HBase.

To run the single node setup, run `vagrant up` in the `single-node` directory instead of the root directory. Everything
else stays the same.

## Hacking & Troubleshooting

### File sharing

Vagrant makes it easy to share files between the vms of the cluster and your host machine. The project directory is
mounted under `/vagrant`, which enables you to get files from or to your host, by simply copying them into that
directory.

### Storage locations

The namenode stores the `fsimage` in `/srv/hadoop/namenode`. The datanodes  are storing all data in
`/srv/hadoop/datanode`.

### Resetting the cluster

Sometimes, when experimenting too much, your cluster might not start anymore. If that is the case, you can easily reset
it like so.

    $ for host in master hadoop1 hadoop2 hadoop3; do vagrant ssh $host --command  'sudo rm -rf /srv/hadoop' ; done
    $ vagrant provision

After those two commands your cluster is in the same state as when you started it for the first time. You can now
reformat the namenode and restart all services.

### Puppet

If you change any of the puppet modules, you can simply apply the changes with vagrants built-in provisioner.

    $ vagrant provision

### Hadoop download

In order to save bandwidth and time we download hadoop only once and store it in the `/vagrant` directory, so that the
other vms can reuse it. If the download fails for some reason, delete the tarball and rerun `vagrant provision`.

We are also downloading a file containing checksums for the tarball. They are verified, before the cluster is started.
If something went wrong during the download, you will see the `verify_tarball` part of puppet fail. If that is the case,
delete the tarball and the checksum file (`<tarball>.mds`) and rerun `vagrant provision`.

## Wishlist

- have a way to configure the names/ips in only one file
