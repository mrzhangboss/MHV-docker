CREATE USER 'slave'@'%' IDENTIFIED BY '123456';
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'slave'@'%';
FLUSH PRIVILEGES;

CREATE USER 'test'@'localhost' IDENTIFIED BY '123456';
REVOKE all ON *.* FROM 'test'@'localhost';
grant select,insert,update,delete on *.* to 'test'@'localhost' identified by '123456';

GRANT ALL ON *.* TO pr_muser@'%' IDENTIFIED BY 'pr_mpass';
GRANT ALL ON *.* TO pr_auser@'%' IDENTIFIED BY 'pr_apass';