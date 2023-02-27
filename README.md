# Running WSPEEDI on a shared cluster

Learn how to configure the wspeedi WRF wrapper in Singularity.

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

 1. builidng the Singularity container.
