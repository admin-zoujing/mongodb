#!/bin/bash
#安装centos7+mongodb脚本 
#图形客户端下载地址：https://robomongo.org/download
sourceinstall=/usr/local/src/mongodb
chmod -R 777 $sourceinstall

#时间时区同步，修改主机名
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
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
tar -zxvf mongodb-linux-x86_64-rhel70-3.6.9.tgz -C /usr/local/mongodb
mkdir -pv /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/{data,logs}
chown -R mongodb:mongodb /usr/local/mongodb


#2:configure配置安装
#touch /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/logs/mongodb.log
#/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/bin/mongod --dbpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/ --logpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/logs/mongodb.log --fork
#CentOS7 内存的设置方法为：systemctl set-property mongod1 MemoryLimit=10G
#echo 3 > /proc/sys/vm/drop_caches
cat > /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/mongodb.conf <<EOF
dbpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/data/
journal=true
directoryperdb=true
wiredTigerDirectoryForIndexes=true
#wiredTigerCacheSizeGB=3
#这个数字是你设置的(limit-1G)*0.5,最小1.5G。
logpath=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/logs/mongodb.log
logappend=true
port=27017
fork=true
#auth=true
bind_ip=0.0.0.0
#configsvr=true 
#replSet=rs0    #（2台以上集群）
maxConns=20000
EOF
chmod 755 /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/mongodb.conf
echo 'export PATH=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/bin:$PATH' > /etc/profile.d/mongodb.sh 
source /etc/profile.d/mongodb.sh 
chown -R mongodb:mongodb /usr/local/mongodb

#3：服务随机启动
#/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/bin/mongod -f /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/mongo.conf
#echo '/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/bin/mongod -f /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/mongo.conf' >> /etc/rc.d/rc.local
#chmod +x /etc/rc.d/rc.local
cat > /usr/lib/systemd/system/mongodb.service <<EOF
[Unit]
Description=High-performance, schema-free document-oriented database
After=syslog.target network.target

[Service]
Group=mongodb
User=mongodb
Type=forking
ExecStart=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/bin/mongod -f /usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/mongodb.conf
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
#/usr/local/mongodb/mongodb-linux-x86_64-rhel70-3.6.9/bin/mongo
ps aux |grep mongodb
sleep 30
cd
rm -rf $sourceinstall



#cgexec -g memory:DBLimitedGroup 限制内存

# 数据备份与恢复
# mongodump --db learn --out backup
# mongorestore --collection unicorns backup/learn/unicorns.bson

# 导入导出
# mongoexport --db learn --collection unicorns
# mongoexport --db learn --collection unicorns --csv -fields name,weight,vampires

#sshpass -p Root123456 scp /home/redis_backup/* root@192.168.1.101:/home/redis_backup

#CentOS7 内存的设置方法为：systemctl set-property mongodb MemoryLimit=4G


#设置副本集集群  :>use admin 
#>db.runCommand({"replSetInitiate":{"_id":"rs0","members":[{"_id":0,"host":"192.168.8.50:27017"},{"_id":1,"host":"192.168.8.51:27017"},]}})
#>rs.add("192.168.8.51:27017")
#查看复制集状态:          >rs.status()        >rs.isMaster()        >rs.conf()
#查看从库状态:            >db.printSlaveReplicationInfo()
#设置从库可查询:          >db.getMongo().setSlaveOk()
#删除节点:主节点上面执行：>rs.remove("ip:port")
#看数据库连接数:          >db.serverStatus().connections
#查看oplog：>use local  >show collections  >db.oplog.rs.find()   >db.printReplicationInfo()
    
