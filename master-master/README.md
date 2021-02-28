# 主主


- 部署 

          docker-compose up -d

  
- 进入master获取启动同步master_log_file 和 master_log_pos

    


        docker exec -it master-master_mysql_master_1 /bin/bash -c "mysql -uroot -p123456 -e 'show master status;'"




- 执行父子同步
  
  进入容器
  

      docker exec -it master-master_mysql_slave_1 /bin/bash -c "mysql -uroot -p123456"


  执行同步（修改master_log_file 和 master_log_pos 在上一步中获取到的）


      change master to master_host='mysql_master', master_user='slave', master_password='123456', master_port=3306, master_log_file='mysql-bin.000003', master_log_pos=154, master_connect_retry=30;  
      start slave;
      select sleep(5);
      show slave status \G;



  如果显示


    Slave_IO_Running: Yes
    Slave_SQL_Running: Yes


  则运行成功

- 进入slave获取启动同步master_log_file 和 master_log_pos




        docker exec -it master-master_mysql_slave_1 /bin/bash -c "mysql -uroot -p123456 -e 'show master status;'"



- 执行子父同步

  进入master容器


      docker exec -it master-master_mysql_master_1 /bin/bash -c "mysql -uroot -p123456"


执行同步（修改master_log_file 和 master_log_pos 在上一步中获取到的）


      change master to master_host='mysql_slave', master_user='slave', master_password='123456', master_port=3306, master_log_file='mysql-bin.000003', master_log_pos=154, master_connect_retry=30;  
      start slave;
      select sleep(5);
      show slave status \G;



如果显示


    Slave_IO_Running: Yes
    Slave_SQL_Running: Yes


则运行成功


## 测试父子同步


  进入容器

      docker exec -it master-master_mysql_master_1 /bin/bash -c "mysql -uroot -p123456"
  

  执行任意SQL，如创建数据库，创建表，插入内容等

  eg：


    create database if not exists test;
    use test;
    create table tb( id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, data char(8));
    insert into tb(data) values ('1');

### 检测是否同步


进入slave容器

    docker exec -it master-master_mysql_slave_1 /bin/bash -c "mysql -utest -p123456"


执行SQL验证：

    use test;
    select * from tb;
    insert into tb(data) values ('1');



如果查询到了结果，而且从库插入成功而且 master 查询成功 成功，则说明主主备份成功
PS: master 主键是奇数，slave 是偶数