#!/usr/bin/env bash
sudo mysql -e "SHOW DATABASES;"
sudo mysql -e "CREATE USER 'replicator'@'%' identified by 'password';" 
sudo mysql -e "ALTER USER 'replicator'@'%' IDENTIFIED WITH mysql_native_password BY 'password';"
sudo mysql -e "grant replication slave on *.* to 'replicator'@'%';"
sudo mysql -e "show master status;"
sudo cp /vagrant/config/master1/replication.cnf /etc/mysql/mysql.conf.d/replication.cnf
sudo cp /vagrant/config/master1/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
sudo cp /vagrant/config/master1/keepalived.conf /etc/keepalived/keepalived.conf
sudo cp /vagrant/config/master1/mysqltest.sh /etc/keepalived/mysqltest.sh
sudo systemctl restart mysql
sudo mysql -e "show master status;"
sudo mysql -e "STOP SLAVE; CHANGE MASTER TO MASTER_HOST = '192.168.100.12', MASTER_USER = 'replicator', MASTER_PASSWORD = 'password', MASTER_LOG_FILE = 'mysql-bin.000001', MASTER_LOG_POS = 156; "
sudo mysql -e "START SLAVE;"
sudo systemctl restart mysql
sudo mysql -e "CREATE DATABASE k3s;"
sudo chmod 644 /etc/keepalived/keepalived.conf
sudo systemctl enable keepalived
sudo systemctl start keepalived
