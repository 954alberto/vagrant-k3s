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

you can do a graceful test by using:

`cluster stop`