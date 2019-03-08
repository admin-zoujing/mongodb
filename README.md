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


创建另一个用户"myuser": > db.createUser({user:"myuser",pwd:"myuser",roles:[{role:"readWrite",db:"mydb"}]})  
    
增删角色：
         #授予角色：db.grantRolesToUser("myuser",[{role:"dbOwner",db:"mydb"}])  
         #取消角色：db.revokeRolesFromUser("myuser",[{role:"readWrite",db:"mydb"}])  

3、MongoDB 查看数据库: >show dbs                     
           创建数据库：>use zoujing                              
           删除数据库: >use zoujing   >db.dropDatabase()

4、MongoDB 查看集合: >use zoujing  >show collections 
           创建集合: >use zoujing  >db.createCollection("runoob") 
           删除集合: >use zoujing  >db.runoob.drop()

5、MongoDB 查看文档；>db.runoob.find()
           插入文档：>db.runoob.insert({title: 'MongoDB 教程', description: 'MongoDB 是一个 Nosql 数据库', by: '菜鸟教程',url: 'http://www.runoob.com',tags: ['mongodb', 'database', 'NoSQL'],likes: 100})
                      db.collection.insertOne():向指定集合中插入一条文档数据
                      db.collection.insertMany():向指定集合中插入多条文档数据
                      insert() 或 save() 方法一样
           更新文档：>db.collection.update(<query>,<update>,{upsert: <boolean>,multi: <boolean>,writeConcern: <document>})
