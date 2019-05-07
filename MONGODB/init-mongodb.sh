#!/bin/bash
#安装centos7+mongodb脚本 
#图形客户端下载地址：https://robomongo.org/download
#http://www.runoob.com/mongodb
sourceinstall=/usr/local/src/mongodb
chmod -R 777 $sourceinstall

#时间时区同步，修改主机名
ntpdate ntp1.aliyun.com
hwclock --systohc
echo "*/30 * * * * root ntpdate -s ntp1.aliyun.com" >> /etc/crontab
rm -rf /var/run/yum.pid 
rm -rf /var/run/yum.pid

#sed -i 's|SELINUX=.*|SELINUX=disabled|' /etc/selinux/config
#sed -i 's|SELINUXTYPE=.*|#SELINUXTYPE=targeted|' /etc/selinux/config
#sed -i 's|SELINUX=.*|SELINUX=disabled|' /etc/sysconfig/selinux 
#sed -i 's|SELINUXTYPE=.*|#SELINUXTYPE=targeted|' /etc/sysconfig/selinux 
#setenforce 0 && systemctl stop firewalld && systemctl disable firewalld

#1:解压
groupadd mongodb
useradd -g mongodb -s /sbin/nologin mongodb
cd $sourceinstall
mkdir -pv /usr/local/mongodb
tar -zxvf mongodb-linux-x86_64-rhel70-4.0.6.tgz -C /usr/local/mongodb
mkdir -pv /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/{data,logs}
chown -R mongodb:mongodb /usr/local/mongodb

#2:configure配置安装
#touch /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/logs/mongodb.log
#/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/bin/mongod --dbpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/ --logpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/logs/mongodb.log --fork
#CentOS7 内存的设置方法为：systemctl set-property mongod1 MemoryLimit=10G
#echo 3 > /proc/sys/vm/drop_caches
cat > /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/mongodb.conf <<EOF
dbpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/
journal=true
directoryperdb=true
wiredTigerDirectoryForIndexes=true
#wiredTigerCacheSizeGB=3
#这个数字是你设置的(limit-1G)*0.5,最小1.5G。
logpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/logs/mongodb.log
logappend=true
port=27017
fork=true
bind_ip=0.0.0.0
#auth=true
#replSet=rs0
#oplogSize=10240
#clusterAuthMode=keyFile
#keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/testKeyFile.file  
maxConns=20000
EOF
chmod 755 /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/mongodb.conf
echo 'export PATH=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/bin:$PATH' > /etc/profile.d/mongodb.sh 
source /etc/profile.d/mongodb.sh 
chown -R mongodb:mongodb /usr/local/mongodb

#3：服务随机启动
#/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/bin/mongod -f /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/mongo.conf
#echo '/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/bin/mongod -f /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/mongo.conf' >> /etc/rc.d/rc.local
#chmod +x /etc/rc.d/rc.local
cat > /usr/lib/systemd/system/mongodb.service <<EOF
[Unit]
Description=High-performance, schema-free document-oriented database
After=syslog.target network.target

[Service]
Group=mongodb
User=mongodb
Type=forking
ExecStart=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/bin/mongod -f /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/mongodb.conf
LimitNOFILE=64000
TimeoutStartSec=180
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload 
systemctl enable mongodb.service 
#优化了系统参数
sed -i 's|4096|32000|' /etc/security/limits.d/20-nproc.conf 
sed -i 's|#DefaultLimitNOFILE=|DefaultLimitNOFILE=32000|' /etc/systemd/system.conf 
sed -i 's|#DefaultLimitNPROC=|DefaultLimitNPROC=32000|' /etc/systemd/system.conf 

echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' >> /etc/rc.d/rc.local
echo 'echo never > /sys/kernel/mm/transparent_hugepage/defrag' >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag
systemctl restart mongodb.service 

firewall-cmd --permanent --zone=public --add-port=27017/tcp --permanent
firewall-cmd --permanent --query-port=27017/tcp
firewall-cmd --reload

#4：客户端连接验证
#/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/bin/mongo
ps aux |grep mongodb
sleep 10
cd
rm -rf $sourceinstall

echo 'db.createUser({user:"admin",pwd:"Adminqwe123",roles:[{role:"root",db:"admin"},{role:"clusterAdmin",db:"admin"}]})' | mongo admin

# echo 'db.dropUser("admin")' | mongo admin
sed -i 's|#auth=true|auth=true|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/mongodb.conf
systemctl restart mongodb.service 

#cgexec -g memory:DBLimitedGroup 限制内存
#CentOS7 内存的设置方法为：systemctl set-property mongodb MemoryLimit=4G

#sshpass -p Root123456 scp /home/redis_backup/* root@192.168.1.101:/home/redis_backup

#备份全库：mongodump -u username -p password -h 127.0.0.1:27017 -o db
#备份单库：mongodump -u username -p password -h 127.0.0.1:27017 -d dbname -o db
#备份集合：mongodump -u username -p password -h 127.0.0.1:27017 -d dbname -c collection -o db

#恢复全库：mongorestore -u username -p password -h 127.0.0.1:27017 --dir=<directory-name>  
#恢复单库：mongorestore -u username -p password -h 127.0.0.1:27017 -d dbname --dir=<directory-name>  
#恢复集合：mongorestore -u username -p password -h 127.0.0.1:27017 -d dbname -c collection --dir=<directory-name>  

#设置副本集集群密码认证:
#openssl rand -base64 756 > /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/testKeyFile.file
#chmod 400 /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/testKeyFile.file
#scp -P22 /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/testKeyFile.file root@192.168.8.51:/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/
#scp -P22 /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/testKeyFile.file root@192.168.8.52:/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/

#sed -i 's|#replSet=rs0|replSet=rs0|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/mongodb.conf
#sed -i 's|#keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/testKeyFile.file|keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/testKeyFile.file|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/mongodb.conf
#sed -i 's|#clusterAuthMode=keyFile|clusterAuthMode=keyFile|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/mongodb.conf
#sed -i 's|#oplogSize=10240|oplogSize=10240|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/mongodb.conf


#oplogSize=10G  
#chown -R mongodb:mongodb /usr/local/mongodb
#systemctl restart mongodb.service    
#echo 'db.runCommand({"replSetInitiate":{"_id":"rs0","members":[{"_id":0,"host":"192.168.8.50:27017"},{"_id":1,"host":"192.168.8.51:27017"},]}})' | mongo -u admin -p Adminqwe123 --port 27017 admin

#>use admin 
#>db.runCommand({"replSetInitiate":{"_id":"rs0","members":[{"_id":0,"host":"192.168.8.50:27017"},{"_id":1,"host":"192.168.8.51:27017"},]}})
#>rs.add("192.168.8.51:27017")
#查看复制集状态:          >rs.status()        >rs.isMaster()        >rs.conf()
#查看从库状态:            >db.printSlaveReplicationInfo()
#设置从库可查询:          >db.getMongo().setSlaveOk()
#删除节点:主节点上面执行：>rs.remove("ip:port")
#看数据库连接数:          >db.serverStatus().connections
#查看oplog：>use local  >show collections  >db.oplog.rs.find()   >db.printReplicationInfo()
    
#Replica Set集群的备份：针对全库    
#1每天晚上备份：mongodump -u admin -p Adminqwe123 -h "rs0/192.168.8.50,192.168.8.51" --oplog -o mongodbback
#2立即导出日志(去掉认证)：mongodump -h "rs0/192.168.8.50,192.168.8.51" -d local -c oplog.rs -o mongodbback/config
#3找到发生误删除的时间点
#bsondump mongodbback/config/local/oplog.rs.bson |egrep "\"op\":\"d\"\,\"ns\":\"test\.oplog\"" |head -1 "t":1553238789,"i":1
#4复制oplog到备份目录
#cp  mongodbback/config/local/oplog.rs.bson   mongodbback/oplog.bson
#5进行恢复，添加之前找到的误删除的点（limt）
#mongorestore -u admin -p Adminqwe123 --oplogReplay --oplogLimit "1553234987:1"  mongodbback

