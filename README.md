图形客户端下载地址：https://robomongo.org/download
http://www.runoob.com/mongodb

mongodb基本操作

1、MongoDB 登录数据库：mongo  
           关闭数据库：mongod -f /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/mongodb.conf --shutdown    
                       >use admin >db.shutdownServer()
           开启数据库：mongod -f /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/mongodb.conf

2、MongoDB 查询zoujing用户: >use admin   >db.system.users.find();
           创建zoujing用户: >use zoujing >db.createUser({user:"zoujing",pwd:"123456",roles:[{role:"dbOwner",db:"zoujing"}]});
           修改zoujing密码: >use zoujing >db.changeUserPassword('zoujing','123');
           删除zoujing用户：>use zoujing >db.dropUser('zoujing'); 
           创建管理员用户： >use admin   >db.createUser({user:"admin",pwd:"Adminqwe123",roles:[{role:"root",db:"admin"},{role:"clusterAdmin",db:"admin"}]});
           >db.auth('admin','Adminqwe123') 

3、MongoDB 查看数据库: >show dbs                     
           创建数据库：>use zoujing                              
           删除数据库: >use zoujing   >db.dropDatabase()

4、MongoDB 查看集合: >use zoujing  >show collections 
           创建集合: >use zoujing  >db.createCollection("runoob") 
           删除集合: >use zoujing  >db.runoob.drop()

5、MongoDB 查看文档；>db.runoob.find()
           插入文档：>db.runoob.insert({title: 'MongoDB 教程', description: 'MongoDB 是一个 Nosql 数据库', by: '菜鸟教程',url: 'http://www.runoob.com',tags: ['mongodb', 'database', 'NoSQL'],likes: 100})
                      db.runoob.insertOne():向指定集合中插入一条文档数据
                      db.runoob.insertMany():向指定集合中插入多条文档数据
                      insert() 或 save() 方法一样
           更新文档：>db.runoob.update({'title':'MongoDB 教程'},{$set:{'title':'MongoDB'}},{multi:true})
           删除文档： 删除集合下全部文档：            >db.runoob.deleteMany({})
                      删除title等于MongoDB的全部文档: >db.runoob.deleteMany({'title':'MongoDB'})
                      删除title等于MongoDB的一个文档：>db.runoob.deleteOne({'title':'MongoDB'})

                     remove方法过时,不会释放空间,执行回收磁盘空间。  
                     >db.runoob.remove({'title':'MongoDB'})                    
                     >db.repairDatabase() 
                  
6、MongoDB 查询文档；>db.runoob.find().pretty() 
           清空文档：>db.runoob.remove({})

   MongoDB AND条件   >db.runoob.find({"by":"菜鸟教程", "title":"MongoDB 教程"}).pretty()
   MongoDB OR条件    >db.runoob.find({$or:[{"by":"菜鸟教程"},{"title": "MongoDB 教程"}]}).pretty()
   MongoDB AND和OR   >db.runoob.find({"likes": {$gt:50}, $or: [{"by": "菜鸟教程"},{"title": "MongoDB 教程"}]}).pretty()

7、MongoDB 条件操作符

MongoDB 与 RDBMS Where 语句比较
操作               格式                     范例                                      RDBMS中的类似语句
等于        {<key>:<value>}          db.col.find({"by":"菜鸟教程"}).pretty()          where by = '菜鸟教程'
小于        {<key>:{$lt:<value>}}    db.col.find({"likes":{$lt:50}}).pretty()         where likes < 50
小于或等于  {<key>:{$lte:<value>}}   db.col.find({"likes":{$lte:50}}).pretty()        where likes <= 50
大于        {<key>:{$gt:<value>}}    db.col.find({"likes":{$gt:50}}).pretty()         where likes > 50
大于或等于  {<key>:{$gte:<value>}}   db.col.find({"likes":{$gte:50}}).pretty()        where likes >= 50
不等于      {<key>:{$ne:<value>}}    db.col.find({"likes":{$ne:50}}).pretty()         where likes != 50

>db.col.insert({title:'PHP教程',description:'PHP是一种创建动态交互性站点的强有力的服务器端脚本语言.',by:'菜鸟教程',url:'http://www.runoob.com',tags:['php'],likes:200})
>db.col.insert({title:'Java教程',description:'Java是由Sun Microsystems公司于1995年5月推出的高级程序设计语言.',by:'菜鸟教程',url:'http://www.runoob.com',tags:['java'],likes:150})
>db.col.insert({title:'MongoDB教程',description:'MongoDB是一个Nosql数据库.',by:'菜鸟教程',url:'http://www.runoob.com',tags:['mongodb'],likes:100})
> db.col.find()

MongoDB (>)      >db.col.find({likes:{$gt:100}})
MongoDB（>=）    >db.col.find({likes:{$gte:100}})
MongoDB (<)      >db.col.find({likes:{$lt:150}})
MongoDB (<=)     >db.col.find({likes:{$lte:150}})
MongoDB (<)和(>) >db.col.find({likes:{$lt:200,$gt:100}})

模糊查询
查询title包含"教"字的文档：        >db.col.find({title:/教/})
查询title字段以"教"字开头的文档：  >db.col.find({title:/^教/})
查询 titl e字段以"教"字结尾的文档：>db.col.find({title:/教$/})

8、MongoDB $type 操作符
类型                    数字                备注
Double                    1        双精度浮点值。用于存储浮点值。
String                    2        字符串。存储数据常用的数据类型。在MongoDB中UTF-8编码的字符串才是合法的。
Object                    3        用于内嵌文档。
Array                     4        用于将数组或列表或多个值存储为一个键。
Binary data               5        二进制数据。用于存储二进制数据。
Object id                 7        对象 ID。用于创建文档的 ID。
Boolean                   8        布尔值。用于存储布尔值（真/假）。
Date                      9        日期时间。用 UNIX 时间格式来存储当前日期或时间。你可以指定自己的日期时间：创建 Date 对象，传入年月日信息
Null                     10        用于创建空值。
Regular Expression       11        正则表达式类型。用于存储正则表达式。
JavaScript               13        
Symbol                   14        符号。该数据类型基本上等同于字符串类型，但不同的是，它一般用于采用特殊符号类型的语言。
JavaScript (with scope)  15   
32-bit integer           16        整型数值。用于存储数值。
Timestamp                17        时间戳。记录文档修改或添加的具体时间。
64-bit integer           18        整型数值。用于存储数值。
Min key                  255       将一个值与 BSON（二进制的 JSON）元素的最低值和最高值相对比。
Max key                  127       将一个值与 BSON（二进制的 JSON）元素的最低值和最高值相对比。

db.col.find({"title":{$type:2}})
db.col.find({"title":{$type:'string'}})

9、MongoDB Limit与Skip方法
   >db.col.find({},{"title":1,_id:0}).limit(2)
   >db.col.find({},{"title":1,_id:0}).limit(1).skip(1)  #skip影响效率,不要轻易使用

10、MongoDB 排序(1为升序，-1是降序)
   >db.col.find({},{"title":1,_id:0}).sort({"likes":-1})
   skip(), limilt(), sort()三个放在一起执行的时候，执行的顺序是先 sort(), 然后是 skip()，最后是显示的 limit()

11、MongoDB 聚合
    计算总和：>db.mycol.aggregate([{$group:{_id:"$by_user",num_tutorial:{$sum:"$likes"}}}])
    计算平均值：>db.mycol.aggregate([{$group:{_id:"$by_user",num_tutorial:{$avg:"$likes"}}}])
    获取集合中所有文档对应值得最小值：            db.mycol.aggregate([{$group:{_id:"$by_user",num_tutorial:{$min:"$likes"}}}])
    获取集合中所有文档对应值得最大值：            db.mycol.aggregate([{$group:{_id:"$by_user",num_tutorial:{$max:"$likes"}}}])
    在结果文档中插入值到一个数组中：              db.mycol.aggregate([{$group:{_id:"$by_user",url:{$push:"$url"}}}])
    在结果文档中插入值到一个数组中，但不创建副本：db.mycol.aggregate([{$group:{_id:"$by_user",url:{$addToSet:"$url"}}}])
    根据资源文档的排序获取第一个文档数据：        db.mycol.aggregate([{$group:{_id:"$by_user",first_url:{$first:"$url"}}}])
    根据资源文档的排序获取最后一个文档数据：      db.mycol.aggregate([{$group:{_id:"$by_user",last_url:{$last:"$url"}}}])

    $project：修改输入文档的结构。可以用来重命名、增加或删除域，也可以用于创建计算结果以及嵌套文档。
    $match：用于过滤数据，只输出符合条件的文档。$match使用MongoDB的标准查询操作。
    $limit：用来限制MongoDB聚合管道返回的文档数。
    $skip：在聚合管道中跳过指定数量的文档，并返回余下的文档。
    $unwind：将文档中的某一个数组类型字段拆分成多条，每条包含数组中的一个值。
    $group：将集合中的文档分组，可用于统计结果。
    $sort：将输入文档排序后输出。
    $geoNear：输出接近某一地理位置的有序文档。

    $project实例: >db.article.aggregate({$project:{_id:0,title:1,author:1}});
      $match实例: >db.articles.aggregate([{$match:{score:{$gt:70,$lte:90}}},{$group:{_id:null,count:{$sum:1}}}]);
       $skip实例: >db.article.aggregate({$skip:5});
    count()函数很慢,解决方案就是用MongoCursor.Size()方法

12、MongoDB 索引
    创建索引:     >db.col.createIndex({"title":1})
    复合索引:     >db.col.createIndex({"title":1,"description":-1})

    查看集合索引: >db.col.getIndexes()
    查看集合索引大小: >db.col.totalIndexSize()
    删除集合所有索引: >db.col.dropIndexes()
    删除集合指定索引: >db.col.dropIndex("索引名称")

13、MongoDB 复制（副本集）
    #设置副本集集群密码认证:
    #sed -i 's|#replSet=rs0 |replSet=rs0 |' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/mongodb.conf
    #sed -i 's|#keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/testKeyFile.file|keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/testKeyFile.file|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/mongodb.conf
    #sed -i 's|#clusterAuthMode=keyFile|clusterAuthMode=keyFile|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/mongodb.conf

    #openssl rand -base64 756 > /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/testKeyFile.file
    #chmod 400 /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/testKeyFile.file
    #scp -P22 /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/testKeyFile.file root@192.168.8.51:/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/
    #scp -P22 /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/testKeyFile.file root@192.168.8.51:/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/
    #chown -R mongodb:mongodb /usr/local/mongodb
    #systemctl restart mongodb.service    
    #echo 'db.runCommand({"replSetInitiate":{"_id":"rs0","members":[{"_id":0,"host":"192.168.8.50:27017"},{"_id":1,"host":"192.168.8.51:27017"},]}})' | mongo -u admin -p Adminqwe123 --port 27017 admin


    #replSet=rs0
    #设置副本集集群  :>use admin 
    #>db.runCommand({"replSetInitiate":{"_id":"rs0","members":[{"_id":0,"host":"192.168.8.50:27017"},{"_id":1,"host":"192.168.8.51:27017"},]}})
    #>rs.add("192.168.8.51:27017")
    #查看复制集状态:          >rs.status()        >rs.isMaster()        >rs.conf()
    #查看从库状态:            >db.printSlaveReplicationInfo()
    #设置从库可查询:          >db.getMongo().setSlaveOk()  或者 >rs.slaveOk()
    #删除节点:主节点上面执行：>rs.remove("ip:port")
    #看数据库连接数:          >db.serverStatus().connections
    #查看oplog：>use local  >show collections  >db.oplog.rs.find()   >db.printReplicationInfo()
    
14、MongoDB 数据备份
    #备份全库：mongodump -u username -p password -h 127.0.0.1:27017 -o db
    #备份单库：mongodump -u username -p password -h 127.0.0.1:27017 -d dbname -o db
    #备份集合：mongodump -u username -p password -h 127.0.0.1:27017 -d dbname -c collection -o db

    #恢复全库：mongorestore -u username -p password -h 127.0.0.1:27017 --dir=<directory-name>  
    #恢复单库：mongorestore -u username -p password -h 127.0.0.1:27017 -d dbname --dir=<directory-name>  
    #恢复集合：mongorestore -u username -p password -h 127.0.0.1:27017 -d dbname -c collection --dir=<directory-name>  

15、MongoDB 监控
    # mongostat  mongotop

16、MongoDB 分片
    #3台服务器上各安装Shard,Config,Route服务
    主机              IP                 服务及端口
  Server A      192.168.8.50         mongod shard1_1:27017 
                                     mongod shard2_1:27018 
                                     mongod config1:20000 
                                     mongs1:30000 
  Server B      192.168.8.51         mongod shard1_2:27017 
                                     mongod shard2_2:27018 
                                     mongod config2:20000 
                                     mongs2:30000 
  Server C      192.168.5.52         mongod shard1_3:27017 
                                     mongod shard2_3:27018 
                                     mongod config3:20000 
                                     mongs3:30000 
  #16.1 创建数据目录
    Server A: mkdir -pv /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/{shard1_1,shard2_1,config}
              chown -R root:root /usr/local/mongodb/
    Server B: mkdir -pv /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/{shard1_2,shard2_2,config}
              chown -R root:root /usr/local/mongodb/
    Server C：mkdir -pv /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/{shard1_3,shard2_3,config}
              chown -R root:root /usr/local/mongodb/

              firewall-cmd --permanent --zone=public --add-port=27017/tcp --permanent
              firewall-cmd --permanent --zone=public --add-port=27018/tcp --permanent
              firewall-cmd --permanent --zone=public --add-port=20000/tcp --permanent
              firewall-cmd --permanent --zone=public --add-port=30000/tcp --permanent
              firewall-cmd --permanent --query-port=27017/tcp
              firewall-cmd --permanent --query-port=27018/tcp
              firewall-cmd --permanent --query-port=20000/tcp
              firewall-cmd --permanent --query-port=30000/tcp
              firewall-cmd --reload


  #16.2 配置shard1所用到的Replica Sets 
    Server A: mongod --shardsvr --replSet shard1 --port 27017 --dbpath /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/shard1_1 --logpath /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/shard1_1/shard1_1.log --logappend --directoryperdb --wiredTigerDirectoryForIndexes --wiredTigerCacheSizeGB 16 --bind_ip_all --fork  
    Server B: mongod --shardsvr --replSet shard1 --port 27017 --dbpath /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/shard1_2 --logpath /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/shard1_2/shard1_2.log --logappend --directoryperdb --wiredTigerDirectoryForIndexes --wiredTigerCacheSizeGB 16 --bind_ip_all --fork  
    Server C：mongod --shardsvr --replSet shard1 --port 27017 --dbpath /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/shard1_3 --logpath /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/shard1_3/shard1_3.log --logappend --directoryperdb --wiredTigerDirectoryForIndexes --wiredTigerCacheSizeGB 16 --bind_ip_all --fork  

     
     echo 'db.runCommand({"replSetInitiate":{"_id":"shard1","members":[{"_id":0,"host":"192.168.8.50:27017"},{"_id":1,"host":"192.168.8.51:27017"},{"_id":2,"host":"192.168.8.52:27017"},]}})' | mongo --port 27017 admin    

  #16.3 配置shard2所用到的Replica Sets 
    Server A: mongod --shardsvr --replSet shard2 --port 27018 --dbpath /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/shard2_1 --logpath /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/shard2_1/shard2_1.log --logappend --directoryperdb --wiredTigerDirectoryForIndexes --wiredTigerCacheSizeGB 16 --bind_ip_all --fork  
    Server B: mongod --shardsvr --replSet shard2 --port 27018 --dbpath /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/shard2_2 --logpath /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/shard2_2/shard2_2.log --directoryperdb --wiredTigerDirectoryForIndexes --wiredTigerCacheSizeGB 16 --logappend --bind_ip_all --fork  
    Server C：mongod --shardsvr --replSet shard2 --port 27018 --dbpath /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/shard2_3 --logpath /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/shard2_3/shard2_3.log --directoryperdb --wiredTigerDirectoryForIndexes --wiredTigerCacheSizeGB 16 --logappend --bind_ip_all --fork  


    echo 'db.runCommand({"replSetInitiate":{"_id":"shard2","members":[{"_id":0,"host":"192.168.8.50:27018"},{"_id":1,"host":"192.168.8.51:27018"},{"_id":2,"host":"192.168.8.52:27018"},]}})' | mongo --port 27018 admin

  #16.4 配置3台Config Server
    Server A: mongod --configsvr --replSet config --port 20000 --dbpath /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/config --logpath /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/config/config.log --directoryperdb --wiredTigerDirectoryForIndexes --wiredTigerCacheSizeGB 16 --logappend --bind_ip_all --fork 
    Server B: mongod --configsvr --replSet config --port 20000 --dbpath /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/config --logpath /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/config/config.log --directoryperdb --wiredTigerDirectoryForIndexes --wiredTigerCacheSizeGB 16 --logappend --bind_ip_all --fork 
    Server C：mongod --configsvr --replSet config --port 20000 --dbpath /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/config --logpath /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/config/config.log --directoryperdb --wiredTigerDirectoryForIndexes --wiredTigerCacheSizeGB 16 --logappend --bind_ip_all --fork 


     echo 'db.runCommand({"replSetInitiate":{"_id":"config","members":[{"_id":0,"host":"192.168.8.50:20000"},{"_id":1,"host":"192.168.8.51:20000"},{"_id":2,"host":"192.168.8.52:20000"},]}})' | mongo --port 20000 admin    

  #16.5 配置3台Route Process 
    Server A: mongos --configdb config/192.168.8.50:20000,192.168.8.51:20000,192.168.8.52:20000 --port 30000 --logpath /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/mongos.log --logappend --bind_ip_all --fork 
    Server B: mongos --configdb config/192.168.8.50:20000,192.168.8.51:20000,192.168.8.52:20000 --port 30000 --logpath /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/mongos.log --logappend --bind_ip_all --fork 
    Server C：mongos --configdb config/192.168.8.50:20000,192.168.8.51:20000,192.168.8.52:20000 --port 30000 --logpath /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/mongos.log --logappend --bind_ip_all --fork 

  #16.6 配置Shard Cluster 
      echo 'db.runCommand({addshard:"shard1/192.168.8.50:27017,192.168.8.51:27017,192.168.8.52:27017"})' | mongo --port 30000 admin 
      echo 'db.runCommand({addshard:"shard2/192.168.8.50:27018,192.168.8.51:27018,192.168.8.52:27018"})' | mongo --port 30000 admin 
      echo 'db.runCommand({enablesharding:"test" })' | mongo --port 30000 admin 
      echo 'db.runCommand({shardcollection: "test.users", key: { _id:1 }})' | mongo --port 30000 admin 

  #16.7 验证Sharding正常工作
        echo 'for(var i=1;i<=200000;i++) db.users.insert({id:i,addr_1:"Beijing",addr_2:"Shanghai"})' | mongo --port 30000 test
        echo 'db.users.stats()' | mongo --port 30000 test

  #16.8 问题
        非正常关机后，重启无法后台运行，删除锁文件mongod.lock
        mongos启动卡死，后台启动2个进程，杀死一个就行。kill
        #查看shard集群的当前状态：>sh.status()
        #添加shard服务器至集群:>sh.addShard("config/192.168.8.53:27017")

  #16.9 集群分片需要密码认证
        #echo 'db.createUser({user:"admin",pwd:"Adminqwe123",roles:[{role:"root",db:"admin"},{role:"clusterAdmin",db:"admin"}]})' | mongo --port 27017 admin
        #echo 'db.createUser({user:"admin",pwd:"Adminqwe123",roles:[{role:"root",db:"admin"},{role:"clusterAdmin",db:"admin"}]})' | mongo --port 27018 admin
        #echo 'db.createUser({user:"admin",pwd:"Adminqwe123",roles:[{role:"root",db:"admin"},{role:"clusterAdmin",db:"admin"}]})' | mongo --port 20000 admin

        #openssl rand -base64 756 > /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/testKeyFile.file
        #chmod 400 /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/testKeyFile.file
        #scp -P22 /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/testKeyFile.file root@192.168.8.51:/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/
        #scp -P22 /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/testKeyFile.file root@192.168.8.52:/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/

        #sed -i 's|#auth=true|auth=true|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/conf/mongodbshard1.conf
        #sed -i 's|#auth=true|auth=true|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/conf/mongodbshard2.conf
        #sed -i 's|#auth=true|auth=true|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/conf/mongodbconfigsvr.conf
        #chown -R mongodb:mongodb /usr/local/mongodb
        #sed -i 's|#keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/testKeyFile.file|keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/testKeyFile.file|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/conf/mongodbshard1.conf
        #sed -i 's|#keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/testKeyFile.file|keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/testKeyFile.file|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/conf/mongodbshard2.conf
        #sed -i 's|#keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/testKeyFile.file|keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/testKeyFile.file|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/conf/mongodbconfigsvr.conf
        #sed -i 's|#keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/testKeyFile.file|keyFile=/usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/testKeyFile.file|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/conf/mongodbconfigdb.conf

        #sed -i 's|#clusterAuthMode=keyFile|clusterAuthMode=keyFile|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/conf/mongodbconfigdb.conf
        #sed -i 's|#clusterAuthMode=keyFile|clusterAuthMode=keyFile|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/conf/mongodbshard1.conf
        #sed -i 's|#clusterAuthMode=keyFile|clusterAuthMode=keyFile|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/conf/mongodbshard2.conf
        #sed -i 's|#clusterAuthMode=keyFile|clusterAuthMode=keyFile|' /usr/local/mongodb/mongodb-linux-x86_64-rhel70-4.0.6/data/conf/mongodbconfigsvr.conf

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


------------------------------------------------------------------------------------------------------------------

                                                      华丽分割

------------------------------------------------------------------------------------------------------------------

创建另一个用户"myuser": > db.createUser({user:"myuser",pwd:"myuser",roles:[{role:"readWrite",db:"mydb"}]})  
    
#自定义角色
    #db.dropRole("testRole")
    >use mydb  
    >db.createRole({role:"testRole",privileges:[{resource:{db:"mydb",collection:""},actions:["find"]}],roles:[]})  

#查看角色
    >use admin  >show collections  >db.system.roles.find();  
   
#创建用户并授予角色
    #db.dropUser("userkk")
    >use mydb       
    >db.createUser({ user:"userkk",pwd:"userkk",roles:[{role:"testRole",db:"mydb"}]})  

#给角色添加3个权限："update", "insert", "remove"
    >use mydb      
    >db.grantPrivilegesToRole("testRole",[{resource:{db:"mydb",collection:""},actions:["update","insert","remove"]}])             
 
#更新角色roles，同样Privileges也可以更新替换   
    >use mydb       
    >db.updateRole("testRole",{ roles:[{ role:"readWrite",db:"mydb"}]},{w:"majority"})    

#增删角色：
         #授予角色：>db.grantRolesToUser("myuser",[{role:"dbOwner",db:"mydb"}])  
         #取消角色：>db.revokeRolesFromUser("myuser",[{role:"readWrite",db:"mydb"}])          


关于角色，参考官方文档提取总结如下：

角色分类                         角色                   权限及角色（本文大小写可能有些变化，使用时请参考官方文档）

Database User Roles             read	                 CollStats,dbHash,dbStats,find,killCursors,listIndexes,listCollections
数据库用户角色                  readWrite               CollStats,ConvertToCapped,CreateCollection,DbHash,DbStats,
                                                        DropCollection,CreateIndex,DropIndex,Emptycapped,Find,
                                                        Insert,KillCursors,ListIndexes,ListCollections,Remove,
                                                        RenameCollectionSameDB,update
Database Administration Roles   dbAdmin                 collStats,dbHash,dbStats,find,killCursors,listIndexes,listCollections,
数据库管理角色                                          dropCollection 和 createCollection 在 system.profile
                                dbOwner                 角色：readWrite, dbAdmin,userAdmin
                                userAdmin               ChangeCustomData,ChangePassword,CreateRole,CreateUser,
                                                        DropRole,DropUser,GrantRole,RevokeRole,ViewRole,viewUser
Cluster Administration Roles    clusterAdmin           角色：clusterManager, clusterMonitor, hostManager
集群管理角色                    clusterManager         AddShard,ApplicationMessage,CleanupOrphaned,FlushRouterConfig,
                                                       ListShards,RemoveShard,ReplSetConfigure,ReplSetGetStatus,
                                                       ReplSetStateChange,Resync,
                                                       EnableSharding,MoveChunk,SplitChunk,splitVector
                                clusterMonitor         connPoolStats,cursorInfo,getCmdLineOpts,getLog,getParameter,
                                                       getShardMap,hostInfo,inprog,listDatabases,listShards,netstat,
                                                       replSetGetStatus,serverStatus,shardingState,top
                                                       collStats,dbStats,getShardVersion
                                hostManager            applicationMessage,closeAllDatabases,connPoolSync,cpuProfiler,
                                                       diagLogging,flushRouterConfig,fsync,invalidateUserCache,killop,
                                                       logRotate,resync,setParameter,shutdown,touch,unlock
Backup and Restoration Roles    backup            	   提供在admin数据库mms.backup文档中insert,update权限
备份和还原角色                                         列出所有数据库：listDatabases
                                                       列出所有集合索引：listIndexes
                                                       对以下提供查询操作：find
                                                       *非系统集合
                                                       *系统集合：system.indexes, system.namespaces, system.js
                                                       *集合：admin.system.users 和 admin.system.roles
                                restore                非系统集合、system.js，admin.system.users 和 admin.system.roles及2.6版本的system.users提供以下权限：
                                                       collMod,createCollection,createIndex,dropCollection,insert
                                                       列出所有数据库：listDatabases
                                                       system.users ：find,remove,update
All-Database Roles              readAnyDatabase        提供所有数据库中只读权限：read
跨库角色                                               列出集群所有数据库：listDatabases
                                readWriteAnyDatabase   提供所有数据库读写权限：readWrite
                                                       列出集群所有数据库：listDatabases
                                userAdminAnyDatabase   提供所有用户数据管理权限：userAdmin
                                                       Cluster：authSchemaUpgrade,invalidateUserCache,listDatabases
                                                       admin.system.users和admin.system.roles：
                                                       collStats,dbHash,dbStats,find,killCursors,planCacheRead
                                                       createIndex,dropIndex
                                dbAdminAnyDatabase     提供所有数据库管理员权限：dbAdmin
                                                       列出集群所有数据库：listDatabases
Superuser Roles                 root                   角色：dbOwner，userAdmin，userAdminAnyDatabase
                                                       readWriteAnyDatabase, dbAdminAnyDatabase,
                                                       userAdminAnyDatabase，clusterAdmin
Internal Role                   __system               集群中对任何数据库采取任何操作


数据库用户角色： read：授予User只读数据的权限
                 readWrite：授予User读写数据的权限

数据库管理角色： dbAdmin：在当前dB中执行管理操作
                 dbOwner：在当前DB中执行任意操作
                 userAdmin：在当前DB中管理User

备份和还原角色： backup
                 restore

跨库角色：       readAnyDatabase：授予在所有数据库上读取数据的权限
                 readWriteAnyDatabase：授予在所有数据库上读写数据的权限
                 userAdminAnyDatabase：授予在所有数据库上管理User的权限
                 dbAdminAnyDatabase：授予管理所有数据库的权限

集群管理角色：   clusterAdmin：授予管理集群的最高权限
                 clusterManager：授予管理和监控集群的权限
                 clusterMonitor：授予监控集群的权限，对监控工具具有readonly的权限
                 hostManager：管理Server




