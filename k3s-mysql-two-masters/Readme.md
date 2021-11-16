# vagrant-k3s-mysql

In this setup we use keepalived to move the IP 192.168.100.13 in case of mysql failover. By defdault the iP is first on master1.

### After bootstrap
on node master1 run the following commnads
```bash
mysql -e "CREATE USER 'k3s'@'192.168.100.11' IDENTIFIED BY 'k3s';"
mysql -e "CREATE USER 'k3s'@'192.168.100.12' IDENTIFIED BY 'k3s';"
mysql -e "CREATE USER 'k3s'@'192.168.100.13' IDENTIFIED BY 'k3s';"
mysql -e "GRANT ALL PRIVILEGES ON k3s.* TO 'k3s'@'192.168.100.11';"
mysql -e "GRANT ALL PRIVILEGES ON k3s.* TO 'k3s'@'192.168.100.12';"
mysql -e "GRANT ALL PRIVILEGES ON k3s.* TO 'k3s'@'192.168.100.13';"
```

The run the k3s installation command
```bash
curl -sfL https://get.k3s.io | sh -s - server \ --datastore-endpoint="mysql://k3s:k3s@tcp(192.168.100.13:3306)/k3s" \
--tls-san 192.168.100.13 \
--node-ip="192.168.100.11"
```




When master1 is ready and the pods in kube-system are running lets register the second master, master2. 

```bash
export K3S_TOKEN=$(cat /var/lib/rancher/k3s/server/token)K106b481f422463b62e5165b57c255847b02806a71bcd3ed9af615a68b9baf12b55::server:c3ba0899e211caeb3a09aa8f01ee67e6 

curl -sfL https://get.k3s.io -o /usr/local/bin/k3s
chmod 755 /usr/local/bin/k3s
k3s server --server="https://192.168.100.13:6443" --datastore-endpoint="mysql://k3s:k3s@tcp(192.168.100.13:3306)/k3s" --node-ip="192.168.100.12"
```

kubectl get nodes should show two nodes like:
```bash
root@master1:~# kubectl get nodes
NAME      STATUS   ROLES                  AGE   VERSION
master2   Ready    control-plane,master   12h   v1.21.5+k3s2
master1   Ready    control-plane,master   19h   v1.21.5+k3s2
```

### To improve

the use of configuration file for k3s bootstrapping as described here:
https://rancher.com/docs/k3s/latest/en/installation/install-options/#configuration-file


export K3S_CONFIG_FILE=/etc/rancher/k3s/config.yaml


 "--kubelet-arg 'node-status-update-frequency=4s'",
    "--kube-controller-manager-arg 'node-monitor-period=2s'",
    "--kube-controller-manager-arg 'node-monitor-grace-period=16s'",
    "--kube-apiserver-arg 'default-not-ready-toleration-seconds=20'",
    "--kube-apiserver-arg 'default-unreachable-toleration-seconds=20'"

--kubelet-arg 'node-status-update-frequency=4s' --kube-controller-manager-arg 'node-monitor-period=2s' --kube-controller-manager-arg 'node-monitor-grace-period=16s' --kube-apiserver-arg 'default-not-ready-toleration-seconds=20' --kube-apiserver-arg 'default-unreachable-toleration-seconds=20'


 "--kubelet-arg 'node-status-update-frequency=4s'",
    "--kube-controller-manager-arg 'node-monitor-period=2s'",
    "--kube-controller-manager-arg 'node-monitor-grace-period=16s'",
    "--kube-apiserver-arg 'default-not-ready-toleration-seconds=20'",
    "--kube-apiserver-arg 'default-unreachable-toleration-seconds=20'"



    server \
        '--config=/etc/rancher/k3s/config.yaml' \
        '--kubelet-arg 'node-status-update-frequency=4s' \
        '--kube-controller-manager-arg 'node-monitor-period=2s' \
        '--kube-controller-manager-arg 'node-monitor-grace-period=16s' \
        '--kube-apiserver-arg 'default-not-ready-toleration-seconds=20' \
        '--kube-apiserver-arg 'default-unreachable-toleration-seconds=20' \