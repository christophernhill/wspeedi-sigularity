# Building the Singularity container

Building Singulairty containers is a slightly convoluted process. 
For cases where it is warranted the process is helpful, but
it does involve a number of steps. 

The process requires using a root privileged session on a Linux systems.
A common approach is to use the tools, Vagrant and Virtual Box, that
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

The Vagrant tool is used to provide a linux Virtual Machine that supports root privileges for our
account. This meets a requirement for building a container, although other approaches a possible.
The Vagrant web site has details on how to work with Vagrant to run a virtual machine. Here we provide a short
summary.

#### If needed, download and install Virtual Box and Vagrant
The websites for these two products have instructions that should be followed. For a MacOS system
the relevant installation files are
```
$ wget https://download.virtualbox.org/virtualbox/7.0.6/VirtualBox-7.0.6-155176-OSX.dmg

```

