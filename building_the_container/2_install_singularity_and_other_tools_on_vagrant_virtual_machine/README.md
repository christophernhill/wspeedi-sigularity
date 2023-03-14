## Installing base software (including singularity) onto vagrant virtual machine

One the vagrant virtual machine has been configured appropriately the Singularity software tool needs to be installed.
This involves connecting to the vagrant virtual machine using the command

```
vagrant ssh
```

and then installing a small number of other software packages as well as follows:

  1. install wget for web downloads
  
   ```
   sudo yum -y install wget 
   ```
