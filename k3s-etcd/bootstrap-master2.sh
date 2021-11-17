#!/usr/bin/env bash
#sudo apt-get update
#sudo apt-get remove docker docker-engine docker.io containerd runc
#sudo apt-get install -y ca-certificates curl gnupg lsb-release
#sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
#sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
#sudo apt-get update
#sudo apt-get install -y docker-ce docker-ce-cli containerd.io
#sudo apt-get install -y mysql-server mysql-client mysql-common keepalived && sudo mysqladmin version
#sudo ufw allow 3306/tcp
#sudo sysctl -w net.ipv4.vs.conntrack=1
#sudo sysctl -w net.ipv4.ip_nonlocal_bind=1
#sudo sysctl -w net.ipv4.ip_forward=1
sudo mysql -e "SHOW DATABASES;"
sudo mysql -e "CREATE USER 'replicator'@'%' identified by 'password';"
sudo mysql -e "ALTER USER 'replicator'@'%' IDENTIFIED WITH mysql_native_password BY 'password';"
sudo mysql -e "grant replication slave on *.* to 'replicator'@'%';"
sudo mysql -e "show master status;"
sudo cp /vagrant/config/master2/replication.cnf /etc/mysql/mysql.conf.d/replication.cnf
sudo cp /vagrant/config/master2/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
sudo cp /vagrant/config/master2/keepalived.conf /etc/keepalived/keepalived.conf
sudo cp /vagrant/config/master2/mysqltest.sh /etc/keepalived/mysqltest.sh
sudo systemctl restart mysql
sudo mysql -e "show master status;"
sudo mysql -e "STOP SLAVE; CHANGE MASTER TO MASTER_HOST = '192.168.100.11', MASTER_USER = 'replicator', MASTER_PASSWORD = 'password', MASTER_LOG_FILE = 'mysql-bin.000001', MASTER_LOG_POS = 156; "
sudo mysql -e "START SLAVE;"
sudo systemctl restart mysql
sudo mysql -e "SHOW DATABASES;"
sudo mysql -e "CREATE USER 'k3s'@'192.168.100.11' IDENTIFIED BY 'k3s';"
sudo mysql -e "CREATE USER 'k3s'@'192.168.100.12' IDENTIFIED BY 'k3s';"
sudo mysql -e "CREATE USER 'k3s'@'192.168.100.13' IDENTIFIED BY 'k3s';"
sudo mysql -e "GRANT ALL PRIVILEGES ON k3s.* TO 'k3s'@'192.168.100.11';"
sudo mysql -e "GRANT ALL PRIVILEGES ON k3s.* TO 'k3s'@'192.168.100.12';"
sudo mysql -e "GRANT ALL PRIVILEGES ON k3s.* TO 'k3s'@'192.168.100.13';"
sudo chmod 644 /etc/keepalived/keepalived.conf
sudo systemctl enable keepalived
sudo systemctl start keepalived
