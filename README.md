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
   >db.col.find({},{"title":1,_id:0}).limit(1).skip(1)

10、MongoDB 排序(1为升序，-1是降序)
   >db.col.find({},{"title":1,_id:0}).sort({"likes":-1})
   skip(), limilt(), sort()三个放在一起执行的时候，执行的顺序是先 sort(), 然后是 skip()，最后是显示的 limit()

11、MongoDB 索引
    创建索引:     >db.col.createIndex({"title":1})
    复合索引:     >db.col.createIndex({"title":1,"description":-1})

    查看集合索引: >db.col.getIndexes()
    查看集合索引大小: >db.col.totalIndexSize()
    删除集合所有索引: >db.col.dropIndexes()
    删除集合指定索引: >db.col.dropIndex("索引名称")
