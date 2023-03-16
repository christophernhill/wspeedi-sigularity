## Transferring Vagrant and virtual box Singularity setup to cluster

At this point the vagrant session for the proxy account created should include a sub-directory called `bmnts` and 
singularity image file called wspeedi.sif. These need to be copied to the target cluster.

```
vagrant ssh
sudo bash
su -l cnh
tar -cvf to_cluster.tar wspeedi.sif bmnts/
exit
exit
sudo cp /home/cnh/to_cluster.tar .
exit
vagrant scp :to_cluster.tar to_cluster.tar
scp to_cluster.tar ACCOUNT@CLUSTER_ADDRESS:CLUSTER_DIRECTORY
```

On cluster
```
```
