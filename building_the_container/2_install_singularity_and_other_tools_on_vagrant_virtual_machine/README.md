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

  2. install the Go language compiler (Sigularity is implemented in Go) and disconnect from virtual machine

  ```
   mkdir singularity-install
   cd singularity-install/
   wget https://go.dev/dl/go1.20.1.linux-amd64.tar.gz
   sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.20.1.linux-amd64.tar.gz
   echo "pathmunge /usr/local/go/bin after" | sudo tee /etc/profile.d/golang.sh 
   exit
  ```
  
  3. install singularity
  
  ```
  
  ```
