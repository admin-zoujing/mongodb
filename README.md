图形客户端下载地址：https://robomongo.org/download
mongodb基本操作

1、MongoDB 登录数据库：mongo  
           关闭数据库：mongod -f /usr/local/mongodb/mongodb-linux-x86_64-rhel62-3.4.5/mongodb.conf --shutdown    
           开启数据库：mongod -f /usr/local/mongodb/mongodb-linux-x86_64-rhel62-3.4.5/mongodb.conf

2、MongoDB 查询zoujing用户: >use admin   >db.system.users.find();
           创建zoujing用户: >use zoujing >db.createUser({user:"zoujing",pwd:"123456",roles:[{role:"dbOwner",db:"zoujing"}]});
           修改zoujing密码: >use zoujing >db.changeUserPassword('zoujing','123');
           删除zoujing用户：>use zoujing >db.dropUser('zoujing'); 
           创建管理员用户： >use admin   >db.createUser({user:"admin",pwd:"Adminqwe",roles:["root"]});

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
           删除文档：>db.runoob.remove({'title':'MongoDB'})

6、MongoDB 查询文档；>db.runoob.find().pretty() 

MongoDB 与 RDBMS Where 语句比较
操作               格式                     范例                                      RDBMS中的类似语句
等于        {<key>:<value>}          db.col.find({"by":"菜鸟教程"}).pretty()          where by = '菜鸟教程'
小于        {<key>:{$lt:<value>}}    db.col.find({"likes":{$lt:50}}).pretty()         where likes < 50
小于或等于  {<key>:{$lte:<value>}}   db.col.find({"likes":{$lte:50}}).pretty()        where likes <= 50
大于        {<key>:{$gt:<value>}}    db.col.find({"likes":{$gt:50}}).pretty()         where likes > 50
大于或等于  {<key>:{$gte:<value>}}   db.col.find({"likes":{$gte:50}}).pretty()        where likes >= 50
不等于      {<key>:{$ne:<value>}}    db.col.find({"likes":{$ne:50}}).pretty()         where likes != 50

MongoDB AND条件         >db.runoob.find({"by":"菜鸟教程", "title":"MongoDB 教程"}).pretty()
MongoDB OR条件          >db.runoob.find({$or:[{"by":"菜鸟教程"},{"title": "MongoDB 教程"}]}).pretty()
MongoDB AND和OR联合使用 >db.runoob.find({"likes": {$gt:50}, $or: [{"by": "菜鸟教程"},{"title": "MongoDB 教程"}]}).pretty()
