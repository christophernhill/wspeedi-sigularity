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
  
  3. reconnect to virtual machine and install other packages needed to use singularity
  
  ```
  vagrant ssh
  ```
  
  ```

  sudo yum -y install gcc gcc-c++
  sudo yum -y install seccomp libseccomp libseccomp-devel
  sudo yum -y install glib2-devel
  sudo yum -y install epel-release
  sudo yum -y update
  sudo yum -y install htop
   50  yum install libseccomp
   51  yum install libseccomp-devel
   52  ./mconfig --prefix=/usr/local/singularity-ce-3.11.0
   53  yum install glib2-devel
   54  ./mconfig --prefix=/usr/local/singularity-ce-3.11.0
   55  cd builddir/
   56  make
   57  bg
   58  w
   59  ps auxxww
   60  htop
   61  yum install htop
   62  yum install epel-release
   63  yum update'
   64  yum update
   65  yum install htop

  ```
  
  3. reconnect to virtual machine and install singularity
  
  ```
  vagrant ssh
  ```
  
  ```
  sudo yum -y install git
  sudo yum -y install mksquashfs
  sudo yum -y install squashfs
  sudo yum -y install squashfs-tools
  mkdir singularity-install
  cd singularity-install
  git clone https://github.com/sylabs/singularity.git --recurse-submodules
  
  ```
