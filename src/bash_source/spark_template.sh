#!/bin/bash

#Author: Hamed Zeinalzadeh
#Date Created: 4/22/2022
#Last Modified: 6/07/2022

#Description
#set up template machines

#Usage
# Create template machines by setting up hadoop and spark on them 

#sudo su -u
#sudo apt-get update
#sudo apt-get upgrade
sudo apt install wget

#input root name (assuming all names are the same)
echo "insert root name : "
read ROOT_NAME
echo

#input spark and hadoop version
echo "insert spark version : "
read SPARK_VERSION
echo
echo "insert hadoop version : "
read HADOOP_VERSION
echo

#input num of nodes 
echo "insert number of nodes : "
read NUM_OF_NODES
echo

#input IPs
ip_list=()

echo "insert Master IP : "
read MASTER_IP
ip_list+=($MASTER_IP)

VAR=1
while [ $VAR -lt $NUM_OF_NODES ]
do
    echo "insert slave number $VAR IP : "
    read SLAVE_IP
    ip_list+=($SLAVE_IP)
    let VAR=VAR+1
done


#set hostname on master
#echo "* On master - master.spark.com" >> /etc/hostname
#echo "* On node1  - node1.spark.com" >> /etc/hostname

#echo "172.20.2.62  master.spark.com" >> /etc/hosts
#echo "172.20.2.43  node1.spark.com" >> /etc/hosts

#setup ssh(only in master)
sudo apt-get install openssh-server openssh-client
ssh-keygen -t rsa -P ""
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

for I in ${ip_list[@]};
do
    ssh-copy-id $ROOT_NAME@$I
done 

#install java on master
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install openjdk-11-jdk

#checking java version
java -version

#download and install apache spark on master
wget https://dlcdn.apache.org/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz
#wget https://dlcdn.apache.org/spark/spark-3.2.1/spark-3.2.1-bin-hadoop3.2.tgz
sudo tar -xvf spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz
sudo mv spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION /usr/local/spark
echo "export PATH=$PATH:/usr/local/spark/bin" >> ~/.bashrc
source ~/.bashrc
#disable firewall
#ufw disable
