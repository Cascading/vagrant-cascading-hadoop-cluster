#!/usr/bin/env bash

. /etc/profile

export HDFS_USER=hdfs

su - $HDFS_USER -c "$HADOOP_PREFIX/bin/hadoop fs -mkdir -p /tmp /user/hive/warehouse; $HADOOP_PREFIX/bin/hadoop fs -chmod g+w /tmp /user/hive/warehouse"
