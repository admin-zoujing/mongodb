#!/bin/bash
#安装centos7+mongodbshard脚本 
#图形客户端下载地址：https://robomongo.org/download
#http://www.runoob.com/mongodb


#echo 'db.createUser({user:"admin",pwd:"Adminqwe123",roles:[{role:"root",db:"admin"},{role:"clusterAdmin",db:"admin"}]})' | mongo --port 27017 admin
# echo 'db.dropUser("admin")' | mongo admin
#sed -i 's|#auth=true|auth=true|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/mongodb.conf
#systemctl restart mongodb.service 

systemctl stop mongodb.service 
systemctl disable mongodb.service 
rm -rf /usr/lib/systemd/system/mongodb.service
systemctl daemon-reload 
rm -rf /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/*

#3台服务器上各安装Shard,Config,Route服务
#    主机              IP                 服务及端口
# momgodbclusterA  192.168.8.50         mongod shard1_1:27017 
#                                       mongod shard2_1:27018 
#                                       mongod config1:20000 
#                                       mongs1:30000 
#momgodbclusterB   192.168.8.51         mongod shard1_2:27017 
#                                       mongod shard2_2:27018 
#                                       mongod config2:20000 
#                                       mongs2:30000 
#momgodbclusterC   192.168.5.52         mongod shard1_3:27017 
#                                       mongod shard2_3:27018 
#                                       mongod config3:20000 
#                                       mongs3:30000 


serverIP=`ifconfig|grep 'inet'|head -1|awk '{print $2}'|cut -d: -f2`

   if   [[ "${serverIP}" = "192.168.8.50" ]];then
            hostname momgodbclusterA && export HOSTNAME=momgodbclusterA
            echo "192.168.8.50 momgodbclusterA
            192.168.8.51 momgodbclusterB
            192.168.8.52 momgodbclusterC" >> /etc/hosts


              #创建数据目录
              mkdir -pv /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/{shard1_1,shard2_1,config,conf}
              chown -R mongodb:mongodb /usr/local/mongodb

              firewall-cmd --permanent --zone=public --add-port=27017/tcp --permanent
              firewall-cmd --permanent --zone=public --add-port=27018/tcp --permanent
              firewall-cmd --permanent --zone=public --add-port=20000/tcp --permanent
              firewall-cmd --permanent --zone=public --add-port=30000/tcp --permanent
              firewall-cmd --permanent --query-port=27017/tcp
              firewall-cmd --permanent --query-port=27018/tcp
              firewall-cmd --permanent --query-port=20000/tcp
              firewall-cmd --permanent --query-port=30000/tcp
              firewall-cmd --reload

              #配置shard1所用到的Replica Sets 
cat > /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbshard1.conf <<EOF
dbpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/shard1_1
journal=true
directoryperdb=true
wiredTigerDirectoryForIndexes=true
wiredTigerCacheSizeGB=3
#这个数字是你设置的(limit-1G)*0.5,最小1.5G。
logpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/shard1_1/shard1_1.log
logappend=true
port=27017
fork=true
bind_ip=0.0.0.0
#auth=true
#clusterAuthMode=keyFile
#keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/testKeyFile.file
shardsvr=true
replSet=shard1   
maxConns=20000
EOF

             chmod 755 /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbshard1.conf
             chown -R mongodb:mongodb /usr/local/mongodb

cat > /usr/lib/systemd/system/mongodbshard1.service <<EOF
[Unit]
Description=High-performance, schema-free document-oriented database
After=syslog.target network.target

[Service]
Group=mongodb
User=mongodb
Type=forking
ExecStart=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/bin/mongod -f /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbshard1.conf
LimitNOFILE=64000
TimeoutStartSec=180
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
            systemctl daemon-reload 
            systemctl enable mongodbshard1.service 
            systemctl restart mongodbshard1.service 
                            
              sleep 30
              echo 'db.runCommand({"replSetInitiate":{"_id":"shard1","members":[{"_id":0,"host":"192.168.8.50:27017"},{"_id":1,"host":"192.168.8.51:27017"},{"_id":2,"host":"192.168.8.52:27017"},]}})' | mongo --port 27017 admin  
              
              #配置shard2所用到的Replica Sets 
cat > /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbshard2.conf <<EOF
dbpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/shard2_1
journal=true
directoryperdb=true
wiredTigerDirectoryForIndexes=true
wiredTigerCacheSizeGB=3
#这个数字是你设置的(limit-1G)*0.5,最小1.5G。
logpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/shard2_1/shard2_1.log 
logappend=true
port=27018
fork=true
bind_ip=0.0.0.0
#auth=true
#clusterAuthMode=keyFile
#keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/testKeyFile.file 
shardsvr=true
replSet=shard2   
maxConns=20000
EOF
             chmod 755 /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbshard2.conf
             chown -R mongodb:mongodb /usr/local/mongodb

cat > /usr/lib/systemd/system/mongodbshard2.service <<EOF
[Unit]
Description=High-performance, schema-free document-oriented database
After=syslog.target network.target

[Service]
Group=mongodb
User=mongodb
Type=forking
ExecStart=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/bin/mongod -f /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbshard2.conf
LimitNOFILE=64000
TimeoutStartSec=180
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
            systemctl daemon-reload 
            systemctl enable mongodbshard2.service 
            systemctl restart mongodbshard2.service 

              sleep 30
              echo 'db.runCommand({"replSetInitiate":{"_id":"shard2","members":[{"_id":0,"host":"192.168.8.50:27018"},{"_id":1,"host":"192.168.8.51:27018"},{"_id":2,"host":"192.168.8.52:27018"},]}})' | mongo --port 27018 admin

#配置Config Server
cat > /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbconfigsvr.conf <<EOF
dbpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/config 
journal=true
directoryperdb=true
wiredTigerDirectoryForIndexes=true
wiredTigerCacheSizeGB=3
#这个数字是你设置的(limit-1G)*0.5,最小1.5G。
logpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/config/config.log 
logappend=true
port=20000
fork=true
bind_ip=0.0.0.0
#auth=true
#clusterAuthMode=keyFile
#keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/testKeyFile.file
configsvr=true
replSet=config   
maxConns=20000
EOF
             chmod 755 /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbconfigsvr.conf
             chown -R mongodb:mongodb /usr/local/mongodb

cat > /usr/lib/systemd/system/mongodbconfigsvr.service <<EOF
[Unit]
Description=High-performance, schema-free document-oriented database
After=syslog.target network.target

[Service]
Group=mongodb
User=mongodb
Type=forking
ExecStart=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/bin/mongod -f /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbconfigsvr.conf
LimitNOFILE=64000
TimeoutStartSec=180
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
            systemctl daemon-reload 
            systemctl enable mongodbconfigsvr.service 
            systemctl restart mongodbconfigsvr.service 
           
             sleep 30
             echo 'db.runCommand({"replSetInitiate":{"_id":"config","members":[{"_id":0,"host":"192.168.8.50:20000"},{"_id":1,"host":"192.168.8.51:20000"},{"_id":2,"host":"192.168.8.52:20000"},]}})' | mongo --port 20000 admin  

              #配置3台Route Process 
cat > /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbconfigdb.conf <<EOF
logpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/mongos.log
logappend=true
port=30000
fork=true
bind_ip=0.0.0.0
#clusterAuthMode=keyFile
#keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/testKeyFile.file
configdb=config/192.168.8.50:20000,192.168.8.51:20000,192.168.8.52:20000   
maxConns=20000
EOF
             chmod 755 /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbconfigdb.conf
             chown -R mongodb:mongodb /usr/local/mongodb

cat > /usr/lib/systemd/system/mongodbconfigdb.service <<EOF
[Unit]
Description=High-performance, schema-free document-oriented database
After=syslog.target network.target

[Service]
Group=mongodb
User=mongodb
Type=forking
ExecStart=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/bin/mongos -f /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbconfigdb.conf
LimitNOFILE=64000
TimeoutStartSec=180
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
            systemctl daemon-reload 
            systemctl enable mongodbconfigdb.service 
            systemctl restart mongodbconfigdb.service 

            #配置Shard Cluster 
            sleep 30
            echo 'db.runCommand({addshard:"shard1/192.168.8.50:27017,192.168.8.51:27017,192.168.8.52:27017"})' | mongo --port 30000 admin 
            echo 'db.runCommand({addshard:"shard2/192.168.8.50:27018,192.168.8.51:27018,192.168.8.52:27018"})' | mongo --port 30000 admin 
            echo 'db.runCommand({enablesharding:"test" })' | mongo --port 30000 admin 
            echo 'db.runCommand({shardcollection: "test.users", key: { _id:1 }})' | mongo --port 30000 admin 













   elif [[ "${serverIP}" = "192.168.8.51" ]];then
            hostname momgodbclusterB && export HOSTNAME=momgodbclusterB
            echo "192.168.8.50 momgodbclusterA
            192.168.8.51 momgodbclusterB
            192.168.8.52 momgodbclusterC" >> /etc/hosts

              #创建数据目录
              mkdir -pv /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/{shard1_2,shard2_2,config,conf}
              chown -R mongodb:mongodb /usr/local/mongodb

              firewall-cmd --permanent --zone=public --add-port=27017/tcp --permanent
              firewall-cmd --permanent --zone=public --add-port=27018/tcp --permanent
              firewall-cmd --permanent --zone=public --add-port=20000/tcp --permanent
              firewall-cmd --permanent --zone=public --add-port=30000/tcp --permanent
              firewall-cmd --permanent --query-port=27017/tcp
              firewall-cmd --permanent --query-port=27018/tcp
              firewall-cmd --permanent --query-port=20000/tcp
              firewall-cmd --permanent --query-port=30000/tcp
              firewall-cmd --reload

              #配置shard1所用到的Replica Sets 
cat > /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbshard1.conf <<EOF
dbpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/shard1_2
journal=true
directoryperdb=true
wiredTigerDirectoryForIndexes=true
wiredTigerCacheSizeGB=3
#这个数字是你设置的(limit-1G)*0.5,最小1.5G。
logpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/shard1_2/shard1_2.log 
logappend=true
port=27017
fork=true
bind_ip=0.0.0.0
#auth=true
#clusterAuthMode=keyFile
#keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/testKeyFile.file 
shardsvr=true
replSet=shard1   
maxConns=20000
EOF
             chmod 755 /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbshard1.conf
             chown -R mongodb:mongodb /usr/local/mongodb

cat > /usr/lib/systemd/system/mongodbshard1.service <<EOF
[Unit]
Description=High-performance, schema-free document-oriented database
After=syslog.target network.target

[Service]
Group=mongodb
User=mongodb
Type=forking
ExecStart=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/bin/mongod -f /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbshard1.conf
LimitNOFILE=64000
TimeoutStartSec=180
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
            systemctl daemon-reload 
            systemctl enable mongodbshard1.service 
            systemctl restart mongodbshard1.service 
              
              sleep 30
              echo 'db.runCommand({"replSetInitiate":{"_id":"shard1","members":[{"_id":0,"host":"192.168.8.50:27017"},{"_id":1,"host":"192.168.8.51:27017"},{"_id":2,"host":"192.168.8.52:27017"},]}})' | mongo --port 27017 admin  
              
              #配置shard2所用到的Replica Sets 
cat > /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbshard2.conf <<EOF
dbpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/shard2_2
journal=true
directoryperdb=true
wiredTigerDirectoryForIndexes=true
wiredTigerCacheSizeGB=3
#这个数字是你设置的(limit-1G)*0.5,最小1.5G。
logpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/shard2_2/shard2_2.log 
logappend=true
port=27018
fork=true
bind_ip=0.0.0.0
#auth=true
#clusterAuthMode=keyFile
#keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/testKeyFile.file 
shardsvr=true
replSet=shard2   
maxConns=20000
EOF
             chmod 755 /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbshard2.conf
             chown -R mongodb:mongodb /usr/local/mongodb

cat > /usr/lib/systemd/system/mongodbshard2.service <<EOF
[Unit]
Description=High-performance, schema-free document-oriented database
After=syslog.target network.target

[Service]
Group=mongodb
User=mongodb
Type=forking
ExecStart=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/bin/mongod -f /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbshard2.conf
LimitNOFILE=64000
TimeoutStartSec=180
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
            systemctl daemon-reload 
            systemctl enable mongodbshard2.service 
            systemctl restart mongodbshard2.service 
              
              sleep 30
              echo 'db.runCommand({"replSetInitiate":{"_id":"shard2","members":[{"_id":0,"host":"192.168.8.50:27018"},{"_id":1,"host":"192.168.8.51:27018"},{"_id":2,"host":"192.168.8.52:27018"},]}})' | mongo --port 27018 admin
              
              #配置Config Server
cat > /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbconfigsvr.conf <<EOF
dbpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/config 
journal=true
directoryperdb=true
wiredTigerDirectoryForIndexes=true
wiredTigerCacheSizeGB=3
#这个数字是你设置的(limit-1G)*0.5,最小1.5G。
logpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/config/config.log 
logappend=true
port=20000
fork=true
bind_ip=0.0.0.0
#auth=true
#clusterAuthMode=keyFile
#keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/testKeyFile.file
configsvr=true
replSet=config   
maxConns=20000
EOF
             chmod 755 /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbconfigsvr.conf
             chown -R mongodb:mongodb /usr/local/mongodb

cat > /usr/lib/systemd/system/mongodbconfigsvr.service <<EOF
[Unit]
Description=High-performance, schema-free document-oriented database
            After=syslog.target network.target

[Service]
Group=mongodb
User=mongodb
Type=forking
ExecStart=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/bin/mongod -f /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbconfigsvr.conf
LimitNOFILE=64000
TimeoutStartSec=180
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
            systemctl daemon-reload 
            systemctl enable mongodbconfigsvr.service 
            systemctl restart mongodbconfigsvr.service 

            sleep 30
            echo 'db.runCommand({"replSetInitiate":{"_id":"config","members":[{"_id":0,"host":"192.168.8.50:20000"},{"_id":1,"host":"192.168.8.51:20000"},{"_id":2,"host":"192.168.8.52:20000"},]}})' | mongo --port 20000 admin  
             
              #配置3台Route Process 
cat > /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbconfigdb.conf <<EOF
logpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/mongos.log
logappend=true
port=30000
fork=true
bind_ip=0.0.0.0
#clusterAuthMode=keyFile
#keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/testKeyFile.file
configdb=config/192.168.8.50:20000,192.168.8.51:20000,192.168.8.52:20000   
maxConns=20000
EOF
             chmod 755 /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbconfigdb.conf
             chown -R mongodb:mongodb /usr/local/mongodb

cat > /usr/lib/systemd/system/mongodbconfigdb.service <<EOF
[Unit]
Description=High-performance, schema-free document-oriented database
After=syslog.target network.target

[Service]
Group=mongodb
User=mongodb
Type=forking
ExecStart=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/bin/mongos -f /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbconfigdb.conf
LimitNOFILE=64000
TimeoutStartSec=180
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
            systemctl daemon-reload 
            systemctl enable mongodbconfigdb.service 
            systemctl restart mongodbconfigdb.service 

            #配置Shard Cluster 
            sleep 30
            echo 'db.runCommand({addshard:"shard1/192.168.8.50:27017,192.168.8.51:27017,192.168.8.52:27017"})' | mongo --port 30000 admin 
            echo 'db.runCommand({addshard:"shard2/192.168.8.50:27018,192.168.8.51:27018,192.168.8.52:27018"})' | mongo --port 30000 admin 
            echo 'db.runCommand({enablesharding:"test" })' | mongo --port 30000 admin 
            echo 'db.runCommand({shardcollection: "test.users", key: { _id:1 }})' | mongo --port 30000 admin 













   elif [[ "${serverIP}" = "192.168.8.52" ]];then
            hostname momgodbclusterC && export HOSTNAME=momgodbclusterC
            echo "192.168.8.50 momgodbclusterA
            192.168.8.51 momgodbclusterB
            192.168.8.52 momgodbclusterC" >> /etc/hosts

              #创建数据目录
              mkdir -pv /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/{shard1_3,shard2_3,config,conf}
              chown -R mongodb:mongodb /usr/local/mongodb

              firewall-cmd --permanent --zone=public --add-port=27017/tcp --permanent
              firewall-cmd --permanent --zone=public --add-port=27018/tcp --permanent
              firewall-cmd --permanent --zone=public --add-port=20000/tcp --permanent
              firewall-cmd --permanent --zone=public --add-port=30000/tcp --permanent
              firewall-cmd --permanent --query-port=27017/tcp
              firewall-cmd --permanent --query-port=27018/tcp
              firewall-cmd --permanent --query-port=20000/tcp
              firewall-cmd --permanent --query-port=30000/tcp
              firewall-cmd --reload



              #配置shard1所用到的Replica Sets 
cat > /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbshard1.conf <<EOF
dbpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/shard1_3
journal=true
directoryperdb=true
wiredTigerDirectoryForIndexes=true
wiredTigerCacheSizeGB=3
#这个数字是你设置的(limit-1G)*0.5,最小1.5G。
logpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/shard1_3/shard1_3.log 
logappend=true
port=27017
fork=true
bind_ip=0.0.0.0
#auth=true
#clusterAuthMode=keyFile
#keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/testKeyFile.file
shardsvr=true
replSet=shard1   
maxConns=20000
EOF
             chmod 755 /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbshard1.conf
             chown -R mongodb:mongodb /usr/local/mongodb

cat > /usr/lib/systemd/system/mongodbshard1.service <<EOF
[Unit]
Description=High-performance, schema-free document-oriented database
After=syslog.target network.target

[Service]
Group=mongodb
User=mongodb
Type=forking
ExecStart=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/bin/mongod -f /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbshard1.conf
LimitNOFILE=64000
TimeoutStartSec=180
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
            systemctl daemon-reload 
            systemctl enable mongodbshard1.service 
            systemctl restart mongodbshard1.service 
             
              sleep 30
              echo 'db.runCommand({"replSetInitiate":{"_id":"shard1","members":[{"_id":0,"host":"192.168.8.50:27017"},{"_id":1,"host":"192.168.8.51:27017"},{"_id":2,"host":"192.168.8.52:27017"},]}})' | mongo --port 27017 admin    
              
              #配置shard2所用到的Replica Sets 
cat > /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbshard2.conf <<EOF
dbpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/shard2_3
journal=true
directoryperdb=true
wiredTigerDirectoryForIndexes=true
wiredTigerCacheSizeGB=3
#这个数字是你设置的(limit-1G)*0.5,最小1.5G。
logpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/shard2_3/shard2_3.log 
logappend=true
port=27018
fork=true
bind_ip=0.0.0.0
#auth=true
#clusterAuthMode=keyFile
#keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/testKeyFile.file
shardsvr=true
replSet=shard2   
maxConns=20000
EOF
             chmod 755 /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbshard2.conf
             chown -R mongodb:mongodb /usr/local/mongodb

cat > /usr/lib/systemd/system/mongodbshard2.service <<EOF
[Unit]
Description=High-performance, schema-free document-oriented database
After=syslog.target network.target

[Service]
Group=mongodb
User=mongodb
Type=forking
ExecStart=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/bin/mongod -f /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbshard2.conf
LimitNOFILE=64000
TimeoutStartSec=180
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
            systemctl daemon-reload 
            systemctl enable mongodbshard2.service 
            systemctl restart mongodbshard2.service 
             
              sleep 30
              echo 'db.runCommand({"replSetInitiate":{"_id":"shard2","members":[{"_id":0,"host":"192.168.8.50:27018"},{"_id":1,"host":"192.168.8.51:27018"},{"_id":2,"host":"192.168.8.52:27018"},]}})' | mongo --port 27018 admin
              
              #配置Config Server
cat > /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbconfigsvr.conf <<EOF
dbpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/config 
journal=true
directoryperdb=true
wiredTigerDirectoryForIndexes=true
wiredTigerCacheSizeGB=3
#这个数字是你设置的(limit-1G)*0.5,最小1.5G。
logpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/config/config.log 
logappend=true
port=20000
fork=true
bind_ip=0.0.0.0
#auth=true
#clusterAuthMode=keyFile
#keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/testKeyFile.file 
configsvr=true
replSet=config   
maxConns=20000
EOF
             chmod 755 /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbconfigsvr.conf
             chown -R mongodb:mongodb /usr/local/mongodb

cat > /usr/lib/systemd/system/mongodbconfigsvr.service <<EOF
[Unit]
Description=High-performance, schema-free document-oriented database
            After=syslog.target network.target

[Service]
Group=mongodb
User=mongodb
Type=forking
ExecStart=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/bin/mongod -f /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbconfigsvr.conf
LimitNOFILE=64000
TimeoutStartSec=180
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
            systemctl daemon-reload 
            systemctl enable mongodbconfigsvr.service 
            systemctl restart mongodbconfigsvr.service  

              sleep 30
              echo 'db.runCommand({"replSetInitiate":{"_id":"config","members":[{"_id":0,"host":"192.168.8.50:20000"},{"_id":1,"host":"192.168.8.51:20000"},{"_id":2,"host":"192.168.8.52:20000"},]}})' | mongo --port 20000 admin    

              #配置3台Route Process 
cat > /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbconfigdb.conf <<EOF
logpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/mongos.log
logappend=true
port=30000
fork=true
bind_ip=0.0.0.0
#clusterAuthMode=keyFile
#keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/testKeyFile.file 
configdb=config/192.168.8.50:20000,192.168.8.51:20000,192.168.8.52:20000   
maxConns=20000
EOF
             chmod 755 /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbconfigdb.conf
             chown -R mongodb:mongodb /usr/local/mongodb

cat > /usr/lib/systemd/system/mongodbconfigdb.service <<EOF
[Unit]
Description=High-performance, schema-free document-oriented database
After=syslog.target network.target

[Service]
Group=mongodb
User=mongodb
Type=forking
ExecStart=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/bin/mongos -f /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbconfigdb.conf
LimitNOFILE=64000
TimeoutStartSec=180
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
            systemctl daemon-reload 
            systemctl enable mongodbconfigdb.service 
            systemctl restart mongodbconfigdb.service 

           #配置Shard Cluster 
           sleep 30
           echo 'db.runCommand({addshard:"shard1/192.168.8.50:27017,192.168.8.51:27017,192.168.8.52:27017"})' | mongo --port 30000 admin 
           echo 'db.runCommand({addshard:"shard2/192.168.8.50:27018,192.168.8.51:27018,192.168.8.52:27018"})' | mongo --port 30000 admin 
           echo 'db.runCommand({enablesharding:"test" })' | mongo --port 30000 admin 
           echo 'db.runCommand({shardcollection: "test.users", key: { _id:1 }})' | mongo --port 30000 admin 
   else
           exit 1
   fi


  #16.7 验证Sharding正常工作
  #       echo 'for(var i=1;i<=200000;i++) db.users.insert({id:i,addr_1:"Beijing",addr_2:"Shanghai"})' | mongo --port 30000 test
  #       echo 'db.users.stats()' | mongo --port 30000 test

  #16.8 问题
  #      非正常关机后，重启无法后台运行，删除锁文件mongod.lock
  #      mongos启动卡死，后台启动2个进程，杀死一个就行。kill
  #查看shard集群的当前状态：>sh.status()  >sh.help()
  #添加shard服务器至集群:>sh.addShard("config/192.168.8.53:27017")

  #16.9 集群分片需要密码认证
#openssl rand -base64 756 > /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/testKeyFile.file
#chmod 400 /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/testKeyFile.file
#scp -P22 /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/testKeyFile.file root@192.168.8.51:/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/
#scp -P22 /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/testKeyFile.file root@192.168.8.52:/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/

#echo 'db.createUser({user:"admin",pwd:"Adminqwe123",roles:[{role:"root",db:"admin"},{role:"clusterAdmin",db:"admin"}]})' | mongo --port 27017 admin
#echo 'db.createUser({user:"admin",pwd:"Adminqwe123",roles:[{role:"root",db:"admin"},{role:"clusterAdmin",db:"admin"}]})' | mongo --port 27018 admin
#echo 'db.createUser({user:"admin",pwd:"Adminqwe123",roles:[{role:"root",db:"admin"},{role:"clusterAdmin",db:"admin"}]})' | mongo --port 20000 admin
#echo 'db.createUser({user:"admin",pwd:"Adminqwe123",roles:[{role:"root",db:"admin"},{role:"clusterAdmin",db:"admin"}]})' | mongo --port 30000 admin

#sed -i 's|#auth=true|auth=true|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbshard1.conf
#sed -i 's|#auth=true|auth=true|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbshard2.conf
#sed -i 's|#auth=true|auth=true|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbconfigsvr.conf
#chown -R mongodb:mongodb /usr/local/mongodb
#sed -i 's|#keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/testKeyFile.file|keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/testKeyFile.file|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbshard1.conf
#sed -i 's|#keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/testKeyFile.file|keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/testKeyFile.file|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbshard2.conf
#sed -i 's|#keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/testKeyFile.file|keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/testKeyFile.file|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbconfigsvr.conf
#sed -i 's|#keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/testKeyFile.file|keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/testKeyFile.file|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbconfigdb.conf

#sed -i 's|#clusterAuthMode=keyFile|clusterAuthMode=keyFile|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbconfigdb.conf
#sed -i 's|#clusterAuthMode=keyFile|clusterAuthMode=keyFile|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbshard1.conf
#sed -i 's|#clusterAuthMode=keyFile|clusterAuthMode=keyFile|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbshard2.conf
#sed -i 's|#clusterAuthMode=keyFile|clusterAuthMode=keyFile|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/conf/mongodbconfigsvr.conf

#关闭集群:路由结点、分片结点、配置结点顺序
#systemctl stop mongodbconfigdb.service 
#systemctl stop mongodbshard1.service     
#systemctl stop mongodbshard2.service     
#systemctl stop mongodbconfigsvr.service

#重新启动集群
#systemctl start mongodbconfigsvr.service
#systemctl start mongodbshard1.service     
#systemctl start mongodbshard2.service     
#systemctl start mongodbconfigdb.service 

