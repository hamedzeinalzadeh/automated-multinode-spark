#!/bin/bash

#Author: Hamed Zeinalzadeh
#Date Created: 4/22/2022
#Last Modified: 6/07/2022

#Description
#set up spark multi-node cluster

#Usage
#if you have multiple VMs that can ping each other,
#then running this script on master node can config a mullti-node spark serivce on your VMs. 
#for configuring additional nodes, follow the script and copy worker sessions for your particular node

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

#set hostname, install java and spark on slaves, configure master information on all the nodes
for I in ${ip_list[@]:1};
do
    SSH_COMMANDS="#sudo su -; #sudo apt-get update; #sudo apt-get upgrade; sudo add-apt-repository ppa:webupd8team/java; sudo apt-get update; sudo apt-get install openjdk-11-jdk; java -version; wget https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz; sudo tar -xvf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz; sudo mv spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} /usr/local/spark; echo \"export PATH=\$PATH:/usr/local/spark/bin\" >> ~/.bashrc; source ~/.bashrc; cd /usr/local/spark/conf; sudo cp spark-env.sh.template spark-env.sh; echo \"export SPARK_MASTER_HOST=${I}\">> spark-env.sh; sudo ufw disable"
    ssh $ROOT_NAME@$I "${SSH_COMMANDS}"
done 

#configure slaves/worker information only on master
for I in ${ip_list[@]:1};
do
    echo "${I}" >> /usr/local/spark/conf/slaves
done

#start spark from master
#/usr/local/spark/spark-3.2.1-bin-hadoop3.2/sbin/start-all.ssh

#open spark URL --> http://master_ip:8080/

#configure jupyternotebook
sudo apt-get install python3-pip
pip install jupyter

echo 'export PYTHONPATH=$SPARK_HOME/python:$PYTHONPATH' >> ~/.bashrc
echo 'export PYSPARK_DRIVER_PYTHON="jupyter"' >> ~/.bashrc
echo 'export PYSPARK_DRIVER_PYTHON_OPTS="notebook"'>> ~/.bashrc
echo 'export PYSPARK_PYTHON=python3' >> ~/.bashrc
source ~/.bashrc

#run jupyter notebook --> jupyter notebook --ip 0.0.0.0
#open jupyter notebook URL --> http://masterip:8888/