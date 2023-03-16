## Build a WSPEEDI singularity image

Once a vagrant Centos7 virtual machine using virtual box and with singularity installed has been deployed, the next step is to use those tools to build an image
file for WSPEEDI. This involves transferring various input files to the vagrant machine and then running singularity with a image definition file specified.

The input files are transferred to the vagrant virtual machine using `vagrant scp` from outside of the virtual machine. There are seven files to transfer. 
The smaller configuration files ( `wspeedi.def`, `install.sh` and `plist-names.txt` ) can be taken from this github repository. The larger files
( `WPS-4.1.tar.gz`, `WRF-4.1.3.tar.gz`, `geog_high_res_mandatory.tar.gz` and `wspeedi-db_package-v1.1.4.tar.gz` ) are availabl from
the WSPEEDI developers. TOtransfer the files use the following commands.

```
vagrant scp WPS-4.1.tar.gz :/vagrant/WPS-4.1.tar.gz 
vagrant scp WRF-4.1.3.tar.gz :/vagrant/WRF-4.1.3.tar.gz 
vagrant scp geog_high_res_mandatory.tar.gz :/vagrant/geog_high_res_mandatory.tar.gz 
vagrant scp wspeedi-db_package-v1.1.4.tar.gz :/vagrant/wspeedi-db_package-v1.1.4.tar.gz 
vagrant scp plist-names.txt :/vagrant/plist-names.txt 
vagrant scp install.sh :/vagrant/install.sh 
vagrant scp wspeedi.spec :/vagrant/wspeedi.spec 
```

Once files are transferred the vagrant virtula machine can be used to generate a singularity image

```
vagrant ssh
sudo /usr/local/singularity-ce-3.11.0/bin/singularity build  wspeedi.sif wspeedi.spec
```

This command will take some time to complete. At the end it should produce a Singularity image file called `wspeedi.sif`. The final messages printed
to the terminal during the build should read
```
  :
  :
Complete!
Compiling WRF was successfully done.
ungrib/src/rd_grib2.F at 772 :"& gfld%ipdtmpl(12) .eq. 15 .or." add
Compiling WPS was successfully done.
INFO:    Creating SIF file...
INFO:    Build complete: wspeedi.sif
```

The `wspeedi.sif` image file can be used to launch a WSPEEDI session in a container. However, the image file is entirely read-only, so before
it can be used for a WSPEEDI session a few more steps are needed to setup override locations that
WSPEEDI need to have read-write permissions. The steps involve a few more commands:

  1. Create a proxy account with the same UID and GID as target cluster account and copy image file across. Here we
  are using the username `cnh` with UID of `1006` and GID of `1006`. This should be cutomized for the
  target account
  ```
  sudo groupadd --gid 1006 cnh
  sudo useradd --uid 1006 -g cnh cnh
  sudo cp wspeedi.sif /home/cnh
  ```

  2. Under the target user proxy account create location for holding writable overrides of key directories. Here again the use name `cnh` should be cutomized to match the actual target account.
  ```
  sudo bash
  su -l cnh
  mkdir bmnts
  ```

  3. Launch a terminal in the container
 
  ```
  /usr/local/singularity-ce-3.11.0/bin/singularity shell  wspeedi.sif 
  ```
  (the shell prompt should change to read `Singularity> ` ).

  4. Create wriitable override duplicate of the `/var/lib/tomcats` directory tree.
  ```
  cd /var/lib/
  tar -cvf ~/var_lib_tomcats.tar tomcats
  exit
  ```
  (the shell prompt should revert to `[vagrant@localhost ~]$ ` ).
  ```
  mkdir -p bmnts/vat/lib
  (cd bmnts/var/lib; tar -xvf ~/var_lib_tomcats.tar )
  ```
  
  5. Create wriitable override duplicate of the `/home/wspeedi` directory tree.
  ```
  /usr/local/singularity-ce-3.11.0/bin/singularity shell  wspeedi.sif 
  cd /home
  tar -cvf ~/home_wspeedi.tar wspeedi/
  exit
  mkdir -p bmnts/home
  (cd bmnts/home; tar -xvf ~/home_wspeedi.tar )
  ```
  6. Customize default language setting to US. This is done by editing the line
  ```
  SD_Lang=JP
  ```
  to read
  ```
  SD_Lang=US
  ```
  in the file
  ```
  bmnts/home/wspeedi/.wdb/wdb_user.conf
  ```

  
  The configuration can now be tested by launching a container for the Sigularity image with the two
  read-write sub-directory overrides. 
  
  ```
  /usr/local/singularity-ce-3.11.0/bin/singularity shell \
       --bind bmnts/var/lib/tomcats:/var/lib/tomcats     \
       --bind bmnts/home/wspeedi:/home/wspeedi wspeedi.sif
  ```
  
  within this container a WSPEEDI session can be started
  
  ```
  . /etc/sysconfig/tomcat-wdb\@wspeedi
  export NAME=wspeedi
  /usr/libexec/tomcat/server start
  ```
  
  a web browser on the machine hosting the vagrant session should then be able to connect to the URL
  ```
  http://192.168.33.11/wspeedi_db
  ```
  
  
  
  
  
  
  
  
