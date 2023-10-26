#!/bin/bash

# Step 1: Update the OS
sudo apt-get update

# Step 2: Install openssh server
sudo apt-get install openssh-server

# Step 3: Create a new group
sudo addgroup hadoop_group

# Step 4: Create a new user in the newly created group
sudo adduser --ingroup hadoop_group hadoop_user

# Step 5: Login to the newly created user
su - hadoop_user

# Step 6: Generate SSH key
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
ssh localhost

# Step 7: Unzip the JDK and Hadoop files
tar -xzf jdk-8u45-linux-x64.tar.gz
tar -xzf hadoop-2.5.1.tar.gz

# Step 8: Set environment variables in .bashrc
echo 'export JAVA_HOME=~/jdk1.8.0_05' >> ~/.bashrc
echo 'export HADOOP_HOME=~/hadoop-2.5.1' >> ~/.bashrc
echo 'export PATH=$PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin' >> ~/.bashrc
source ~/.bashrc

# Step 9: Edit hadoop-env.sh
echo 'export JAVA_HOME=~/jdk1.8.0_05' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# Step 10: Configure core-site.xml
cat <<EOL > $HADOOP_HOME/etc/hadoop/core-site.xml
<configuration>
  <property>
    <name>fs.default.name</name>
    <value>hdfs://localhost:9000</value>
  </property>
</configuration>
EOL

# Step 11: Configure mapred-site.xml
cat <<EOL > $HADOOP_HOME/etc/hadoop/mapred-site.xml
<configuration>
  <property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
  </property>
  <property>
    <name>mapreduce.job.tracker</name>
    <value>localhost:54311</value>
  </property>
  <property>
    <name>mapreduce.tasktracker.map.tasks.maximum</name>
    <value>4</value>
  </property>
  <property>
    <name>mapreduce.map.tasks</name>
    <value>4</value>
  </property>
</configuration>
EOL

# Step 12: Configure hdfs-site.xml
cat <<EOL > $HADOOP_HOME/etc/hadoop/hdfs-site.xml
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>1</value>
  </property>
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>file:/home/hadoop_user/hdfs/namenode</value>
  </property>
  <property>
    <name>dfs.datanode.data.dir</name>
    <value>file:/home/hadoop_user/hdfs/datanode</value>
  </property>
</configuration>
EOL

# Step 13: Configure yarn-site.xml
cat <<EOL > $HADOOP_HOME/etc/hadoop/yarn-site.xml
<configuration>
  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
  </property>
</configuration>
EOL

# Step 14: Format Hadoop Namenode
hdfs namenode -format

# Step 15: Start Hadoop Services
$HADOOP_HOME/sbin/start-all.sh

# Step 16: Check Running Nodes
jps
