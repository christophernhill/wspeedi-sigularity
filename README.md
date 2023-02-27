# Running WSPEEDI on a shared cluster

Learn how to configure the wspeedi WRF wrapper in Singularity. This allows
the WSPEEDI tomcat web interface to execute on a Slurm cluster so that
multiple setups can be executed and a farm of compute nodes can
be leveraged.

## Introduction

This example shows the building of a Singularity image for running a tool called
WSPEEDI that simulates atmospheric transport of chemical species. The tool uses
the WRF atmospheric model to simulate transports. WSPEEDI adds a tomcat web server
front end. The web server allows plotting and analysis of transport results as
well as configuration of transport simulations.

Singularity is a system for creating and running containers on a shared cluster.
A sigularity container can be useful for configuring a complex tool that has
been developed for a particular environment. A container can be used to create
a replica of the required environmnt on a shared cluster. 

This example shows create a container and then using the container to run
the web interface driven tool in concert with a shared cluster Slurm scheduler.

## Steps

 1. building the Singularity container.

 2. configuring the container on our cluster

 3. accessing the container in a Slurm job usinf an ssh tunnel

## Background material

Several tools are used and general techniques are used to make this system work.
The notes here contain links to more detailed material on the general use of these
tools and techniques. These notes focus on the rapid application of the tools to
a specific case and so some background information is not covered in detail.
