## Build a WSPEEDI singularity image

Once a vagrant Centos7 virtual machine using virtual box and with singularity installed has been deployed, the next step is to use those tools to build an image
file for WSPEEDI. This involves transferring various input files to the vagrant machine and then running singularity with a image definition file specified.

The input files are transferred to the vagrant virtual machine using `vagrant scp` from outside of the virtual machine. There are six files to transfer. 
The smaller configuration files ( `wspeedi.def`, `install.sh` and `plist-names.txt` ) can be taken from this github repository. The larger files
( `WPS-4.1.tar.gz`, `WRF-4.1.3.tar.gz`, `geog_high_res_mandatory.tar.gz` and `wspeedi-db_package-v1.1.4.tar.gz` ) are availabl from
the WSPEEDI developers. 

```
vagrant scp :WPS-4.1.tar.gz WPS-4.1.tar.gz
```
