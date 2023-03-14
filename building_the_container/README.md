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
vagrant init
vagrant up
vagrant ssh
```
The final command `vagrant ssh` logs in to a terminal shell on the virtual machine.
From that shell privileged access can be activated with the command `sudo bash`. Privileged
access is the current approach for building Singularity container for widely used 
Linux cluster environments like CentOS.

The preceeding commands will launch the machine in a default configuration. For building a WSPEEDI 
container the Vagrant/Virtual Box virtual machine needs a larger default memory and disk size.
This can be set by modifying the file called `Vagrantfile` that is generated by the
`vagrant init` command. 

To increase the memory of the Vagrant/Virtual Box virtual machine, the line containing
the assignment `vb.memory` needs to be changed to read.

`
      vb.memory = "8192"
`






```
  555  vagrant box add centos/7
  556  vagrant init
  560  vagrant up
  561  vagrant ssh
  564  vagrant ssh
  567  vagrant ssh
  569  vagrant reload
  570  vagrant ssh
  572  vagrant ssh
  576  vagrant scp :/vagrant/'WRF*' .
  577  vagrant scp :/vagrant/'WPS*' .
  580  vagrant plugin install vagrant-disksize
  582  vagrant halt
  583  vagrant up
  584  vagrant ssh
  585  vagrant help
  587  history | grep vagrant

export VAGRANT_DOTFILE_PATH=/Users/chrishill/projects/snow_tickets/ali_ayoub_wspeedi/.vagrant
export VAGRANT_HOME=/Users/chrishill/projects/snow_tickets/ali_ayoub_wspeedi/.vagrant.d
```

