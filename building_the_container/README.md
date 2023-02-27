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
a shared cluster. For this we start from a Singularity definition file 
