# Building the Singularity container

Building Singulairty containers can be a slightly convoluted process at
the moment.
For cases where it is warranted the process is helpful, but
it does involve a number of steps. 
Here we document the most common process that should be compatible
with most clusters. Recent improvements in the Linux kernel mean that
on some systems root prvileges are no longer needed. This simplifies the 
container building process. The simplified process is described after the more
common, and slightly more involved, process.

The most common process for container building requires using a root privileged session 
on a Linux system. A widely used approach is to use the tools, Vagrant and Virtual Box, that
togethr can provide one systematic recipe for building containers.

Both tools are freely availble downloads for x86 computers. Virtual Box
can be downloaded from https://www.virtualbox.org, Vagrant can be downloaded
from https://www.vagrantup.com. Virtual Box has a beta mode for supporting
M1/M2 Mac Arm computers.

The Carpentries training organization ( https://carpentries.org ) has a draft set of
educational material that provides a hands-on set of lessons in the workings
of Singularity https://carpentries-incubator.github.io/singularity-introduction/index.html.
The official Singularity product reference documentation is available 
at https://docs.sylabs.io/guides/latest/user-guide/.

Here we focus on the specific application of these tools to getting WSPEEDI to work on
a shared cluster. For this we start from a so-called Singularity definition file 
that specifies a virtual configuration for a Singularity container image.
From this definition we can build a container image that can be used on our Slurm cluster.
The definition file, [wspeedi.def](./wspeedi.def), describes what software needs to be 
installed into the container image.

## Overview of build steps

Once we have a definition file we can use the Singulaity tool to create a container.
The Singularity workflow is slightly idiosyncratic. In particualr 

 1. we create the
container on a system where we have root privileges, and then transfer the container
to our cluster. On the cluster the container is executed under a regular account and
any privileged actions will fail. 

 2. once created the container is read-only. Any directories that need to be writable must **bind** to
    to cluster directories that are writable by the account running the container. Singularity
    provides command options to specify these bindings.

Creating a Singularity container for an existing tool like WSPEEDI requires a little experimentation
to understand which directories need to be writable when the tool is used. In practice we do this
by building the container under a prvileged account locally (on a laptop for example) 
and then iterating with running the container under a non-privileged account and resolving write access
problems that may arise.

## Commands to build

In the end, building the container amounts to executing a series of commands that utilize
the tools Vgrant and Singularity and operate on the [wspeedi.def](./wspeedi.def) defintiion 
file. 

### Part 1 Vagrant and virtual box configuration pre-step

A pre-step for using singularity is a Linux environment providing prvileged root access. The steps
in this seciton are a widely used approach for creating that environment. There are not needed
if you already have access to a suitable environment. The steps are also not needed on a more 
recent Linux system which supports the Apptainer/Singularity standards for building containers
without a privileged account. Rocky 8 Linux systms support these standards by default.
In this pre-step the toola Vagrant and Virtual Box are used.

The Vagrant tool is used to provide a linux Virtual Machine that supports root privileges for our
account. This meets a requirement for building a container, although other approaches a possible.
The Vagrant web site has details on how to work with Vagrant to run a virtual machine. Here we provide a short
summary.

#### 1. If needed, download and install Virtual Box and Vagrant
The websites for these two products have instructions that should be followed. 
For a MacOS system, for example,
the relevant installation files are
```
wget https://download.virtualbox.org/virtualbox/7.0.6/VirtualBox-7.0.6-155176-OSX.dmg
brew install hashicorp/tap/hashicorp-vagrant
```
Note: the Vagrant MacOS installation uses the homebrew ( https://brew.sh ) package system.

#### 2. Lauch a Vagrant virtual machine and connect to it

To launch a Vagrant virtual machine we first set two environment variables that control
where Vagrant and Virtual Box store their working information. This is not strictly needed, 
but it helps manage disk usage associated with this workflow. The two environment variables 
are

```
VAGRANT_DOTFILE_PATH
VAGRANT_HOME
```

The `VAGRANT_HOME` directory path is the location where large image files associated with
using Vagrant and Virtual Box are stored. The `VAGRANT_DOTFILE_PATH` directory is where
various bookeeping files are stored. Setting these variables to a project specific location helps
clean-up of potentially large temporary files.

The next step to using Vargrant/Virtual Box involves downloading an image file for the
approapriate operating system image, in this case CentOS/7. The command for this is

```
vagrant box add centos/7
```
when run this command prompts for the virtual machine provider to use. In this example the `virtualbox` prvoder is used.


The machine can then be launched and accessed using the commands 
```
vagrant init centos/7
vagrant up
vagrant ssh
```
The final command `vagrant ssh` logs in to a terminal shell on the virtual machine.
From that shell privileged access can be activated with the command `sudo bash`. Privileged
access is the current approach for building Singularity container for widely used 
Linux cluster environments like CentOS. To exit the terminal session use the command `exit`.

##### 2.1 Customizing the virtual machine for this project

The preceeding commands will launch the machine in a default configuration. For building a WSPEEDI 
container the Vagrant/Virtual Box virtual machine needs a larger default memory and disk size. Enabling copying files to
and from the vagrant virtual machine is also needed for this project.

These features can be enabled by modifying the file called `Vagrantfile` that is generated by the
`vagrant init` command, and adding some plugins and updating the virtual machine. 

* First, two plugins are installed using the commands

  ```
  vagrant plugin install vagrant-disksize
  vagrant plugin install vagrant-scp
  ```

* Next, to increase the memory of the Vagrant/Virtual Box virtual machine, the line containing
  the assignment `vb.memory` needs to be changed to read.

  `
      vb.memory = "8192"
  `
  in the default `Vagrantfile` this line may be commented out using a `#` at the beginning of the line
  which needs to be deleted. The Ruby language loop bracketing the `vb.memory` should also be uncommented. These are
  two lines that read
  ```
    config.vm.provider "virtualbox" do |vb|
  ```
  and
  ```
    end
  ```

* In addition, file `Vagrantfile` also needs editing to allocate a larger virtual disk to the virtual
  machine. Thist change involves inserting the line 
  ```
  config.disksize.size = '500GB'
  ```
  directly after an existing line, that reads `  config.vm.box = "centos/7"`. 

* Finally, in some cases, one other change
  may be needed. The default `Vagrantfile` has a commented out line that reads
  ```
  #   config.vm.network "private_network", ip: "192.168.33.10"
  ```
  for local testing of the Sigularity build of WSPEEDI it is useful to uncommnt this line. On some systems
  the network address `192.168.33.10` may already be in use. In this case the address should be changed to an
  unused address, for example `192.168.33.23`. The final digits in this address can be any number, that is not
  already in use, between `10` and `254`.

* At this point the virtual machine can be restarted and accessed using the commands
  ```
  vagrant halt
  vagrant up
  vagrant ssh
  ```

* To finish configuration the formatted disk within the virtual machine needs to be _resized_. Within the virtual machine running the command
  ```
  $ lsblk
  [vagrant@localhost ~]$ lsblk
  NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
  sda      8:0    0  500G  0 disk 
  └─sda1   8:1    0   40G  0 part /

  ```
  shows that the virtual machine has a disk that is now 500GB in size, but that the formatted partition `sda1` that is   available is still the default 40GB. To increase the partition size use the following commands within the virtual machine
 
  ```
  sudo yum install -y e2fsprogs lvm2
  sudo yum install cloud-utils-growpart gdisk -y
  sudo growpart /dev/sda 1
  sudo xfs_growfs -d /dev/sda1
  ```
  
  after running these commands the `lsblk` command should show
   ```
   [vagrant@localhost ~]$ lsblk
   NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
   sda      8:0    0  500G  0 disk 
   └─sda1   8:1    0  500G  0 part /
   ```
   
At this point the virtual machine has a bas configuration for use to build an WSPEEDI singularity image.






