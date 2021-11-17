#!/usr/bin/env bash
mysql -e "SHOW DATABASES;"
mysql -e "CREATE USER 'replicator'@'%' identified by 'password';" 
mysql -e "ALTER USER 'replicator'@'%' IDENTIFIED WITH mysql_native_password BY 'password';"
mysql -e "grant replication slave on *.* to 'replicator'@'%';"
mysql -e "show master status;"
cp /vagrant/config/${HOSTNAME}/mysql/replication.cnf /etc/mysql/mysql.conf.d/replication.cnf
cp /vagrant/config/${HOSTNAME}/mysql/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
cp /vagrant/config/${HOSTNAME}/keepalived/keepalived.conf /etc/keepalived/keepalived.conf
cp /vagrant/config/${HOSTNAME}/mysql/mysqltest.sh /etc/keepalived/mysqltest.sh
cp /vagrant/config/cluster /usr/local/bin/cluster
chmod +x /usr/local/bin/cluster
systemctl restart mysql
mysql -e "show master status;"
mysql -e "STOP SLAVE; CHANGE MASTER TO MASTER_HOST = '192.168.100.102', MASTER_USER = 'replicator', MASTER_PASSWORD = 'password', MASTER_LOG_FILE = 'mysql-bin.000001', MASTER_LOG_POS = 156; "
mysql -e "START SLAVE;"
systemctl restart mysql
mysql -e "CREATE DATABASE k3s;"
chmod 644 /etc/keepalived/keepalived.conf
systemctl enable keepalived
systemctl start keepalived
