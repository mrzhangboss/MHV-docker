# MySQL主从（使用ProxySQL进行读写分离）


- 部署 

          docker-compose up -d

  
- 进入获取启动同步master_log_file 和 master_log_pos

    


        docker exec -it master-slave-proxysql_mysql_master_1 /bin/bash -c "mysql -uroot -p123456 -e 'show master status;'"




- 执行同步
  
  进入容器
  

      docker exec -it master-slave-proxysql_mysql_slave_1 /bin/bash -c "mysql -uroot -p123456"


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

      docker exec -it master-slave-proxysql_mysql_master_1 /bin/bash -c "mysql -uroot -p123456"
  

  执行任意SQL，如创建数据库，创建表，插入内容等

  eg：


    create database if not exists testing;
    use testing;
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


### 检测使用读写分类

安装 sysbench


    sudo apt-get install sysbench


- 运行sysbench


    sysbench /usr/share/sysbench/oltp_read_write.lua  --threads=5 --max-requests=0 --time=36 --db-driver=mysql --mysql-user=pr_auser --mysql-password='pr_apass' --mysql-port=60330  --mysql-host=127.0.0.1  --mysql-db=testing --report-interval=1 prepare
    sysbench /usr/share/sysbench/oltp_read_write.lua  --threads=5 --max-requests=0 --time=36 --db-driver=mysql --mysql-user=pr_auser --mysql-password='pr_apass' --mysql-port=60330  --mysql-host=127.0.0.1  --mysql-db=testing --report-interval=1 run
    
- 查看结果（登录 proxysql 管理平台）


    
    mysql -u admin2 -padmin2 -h 127.0.0.1 -P60320

    select * from stats_mysql_query_digest  \G;


如果看到  查询是 `hostgroup: 1` 和 插入是 `hostgroup: 0` 说明读写分离成功

- 验证登录


        mysql -upr_auser  -P60330 -h 127.0.0.1 -ppr_apass

使用上述命令可以登录mysql执行SQL