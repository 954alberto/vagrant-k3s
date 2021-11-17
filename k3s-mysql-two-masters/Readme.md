# vagrant-k3s-mysql-keepalived

In this setup we use keepalived to move the IP 192.168.100.100 in case of mysql failover. By default the iP is first on master1 because it is bootstrapped first.

### After bootstrap
Since we need to be careful with mysql master-master replication, only when both nodes are ready enter master1 and run `systemctl start k3s`
then you can run:
`watch "kubectl get nodes; kubectl get pods -owide --all-namespaces"`

then enter master2 and run `systemctl start k3s` then run `watch "kubectl get nodes; kubectl get pods -owide --all-namespaces"`


when both nodes are in `STATUS=Ready` we are done.

### Testing Failover
I have prepared a shell script to check the cluster and start stop both k3s and mysql together.
For consistance I strongly recomment to use that command instead of individually running systemctl stop k3s and systemctl stop mysql...

```bash
root@master1:~# cluster status
Checking cluster...

● k3s.service - Lightweight Kubernetes
     Loaded: loaded (/etc/systemd/system/k3s.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2021-11-17 09:08:55 UTC; 13min ago

● mysql.service - MySQL Community Server
     Loaded: loaded (/lib/systemd/system/mysql.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2021-11-17 09:03:58 UTC; 18min ago

Looking for the VIP...
    inet 192.168.100.100/24 scope global secondary enp0s8
I have the IP
```

A graceful failover can by tested by running `cluster stop` on master1, this will stop k3s and then mysql, then keepalived on master2 will claim the VIP and the failover is completed.