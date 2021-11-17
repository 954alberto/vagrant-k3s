#!/usr/bin/env bash
#apt-get update
#apt-get remove docker docker-engine docker.io containerd runc
#apt-get install -y ca-certificates curl gnupg lsb-release
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
#echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
#apt-get update
#apt-get install -y docker-ce docker-ce-cli containerd.io
#apt-get install -y mysql-server mysql-client mysql-common keepalived && mysqladmin version
#ufw allow 3306/tcp
#sysctl -w net.ipv4.vs.conntrack=1
#sysctl -w net.ipv4.ip_nonlocal_bind=1
#sysctl -w net.ipv4.ip_forward=1
mysql -e "SHOW DATABASES;"
mysql -e "CREATE USER 'replicator'@'%' identified by 'password';"
mysql -e "ALTER USER 'replicator'@'%' IDENTIFIED WITH mysql_native_password BY 'password';"
mysql -e "grant replication slave on *.* to 'replicator'@'%';"
mysql -e "show master status;"
cp /vagrant/config/master2/replication.cnf /etc/mysql/mysql.conf.d/replication.cnf
cp /vagrant/config/master2/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
cp /vagrant/config/master2/keepalived.conf /etc/keepalived/keepalived.conf
cp /vagrant/config/master2/mysqltest.sh /etc/keepalived/mysqltest.sh
cp /vagrant/config/cluster /usr/local/bin/cluster
chmod +x /usr/local/bin/cluster
systemctl restart mysql
mysql -e "show master status;"
mysql -e "STOP SLAVE; CHANGE MASTER TO MASTER_HOST = '192.168.100.101', MASTER_USER = 'replicator', MASTER_PASSWORD = 'password', MASTER_LOG_FILE = 'mysql-bin.000001', MASTER_LOG_POS = 156; "
mysql -e "START SLAVE;"
systemctl restart mysql
mysql -e "SHOW DATABASES;"
mysql -e "CREATE USER 'k3s'@'192.168.100.100' IDENTIFIED BY 'k3s';"
mysql -e "CREATE USER 'k3s'@'192.168.100.101' IDENTIFIED BY 'k3s';"
mysql -e "CREATE USER 'k3s'@'192.168.100.102' IDENTIFIED BY 'k3s';"
mysql -e "GRANT ALL PRIVILEGES ON k3s.* TO 'k3s'@'192.168.100.100';"
mysql -e "GRANT ALL PRIVILEGES ON k3s.* TO 'k3s'@'192.168.100.101';"
mysql -e "GRANT ALL PRIVILEGES ON k3s.* TO 'k3s'@'192.168.100.102';"
chmod 644 /etc/keepalived/keepalived.conf
systemctl enable keepalived
systemctl start keepalived
