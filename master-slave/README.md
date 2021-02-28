# 主从


- 部署 

      docker-compose up -d

- 进入 master 获取 log 位置


  
- 进入获取启动同步master_log_file 和 master_log_pos
  

    docker exec -it master-slave_mysql_master_1 /bin/bash -c "mysql -uroot -p123456 -e 'show master status;'"

- 执行同步
  
  进入容器
  

      docker exec -it master-slave_mysql_slave_1 /bin/bash -c "mysql -uroot -p123456"


  执行同步（修改master_log_file 和 master_log_pos 在上一步中获取到的）


      change master to master_host='master', master_user='slave', master_password='123456', master_port=3306, master_log_file='edu-mysql-bin.000003', master_log_pos=154, master_connect_retry=30;  
      start slave;
      select sleep(5);
      show slave status \G;



  如果显示


    Slave_IO_Running: Yes
    Slave_SQL_Running: Yes


  则运行成功


## 测试同步


  进入容器

      docker exec -it master-slave_mysql_master_1 /bin/bash -c "mysql -uroot -p123456"
  

  执行任意SQL，如创建数据库，创建表，插入内容等

  eg：


    create database if not exists test;
    use test;
    create table tb(data char(8));
    insert into tb values ('1');

### 检测是否同步


进入slave容器

    docker exec -it master-slave_mysql_slave_1 /bin/bash -c "mysql -utest -p123456"


执行SQL验证：

    use test;
    select * from tb;
    insert into tb values ('1');


如果查询到了结果，而且从库插入报错则 master slave 成功