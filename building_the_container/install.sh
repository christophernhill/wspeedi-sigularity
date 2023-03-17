#!/bin/sh

. ./config.dat

# These need to be a UID and GID for the end user on the target cluster
END_USER_GID=1006
END_USER_UID=1006

SRC_DIR=`pwd`

groupadd --gid ${END_USER_GID} ${DB_GROUP}
useradd  --uid ${END_USER_UID} -g ${DB_GROUP} ${DB_USER}

exit

#yum install -y epel-release
yum install -y "http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm"
yum -y update
yum install -y netcdf-cxx-devel netcdf-fortran-devel ncview GMT gshhg-gmt-nc4-full gshhg-gmt-nc4-high ghostscript wgrib wgrib2 tomcat openmpi openmpi-devel expect jasper-devel libpng-devel m4 tcsh gnuplot policycoreutils-python bc ipa-pgothic-fonts ipa-pmincho-fonts net-tools perl time ffmpeg zip nkf

#### SELINUX=`/sbin/getenforce`
#### 
#### if [ ${SELINUX} == Enforcing ]; then
#### #	semanage port -a -t http_port_t -p tcp ${DB_TOMCAT_PORT}
#### #	semanage port -a -t http_port_t -p tcp ${DB_TOMCAT_JAVA_PORT2}
#### #	semanage port -a -t mxi_port_t -p tcp ${DB_TOMCAT_JAVA_PORT1}
#### #	semanage port -a -t mxi_port_t -p udp ${DB_TOMCAT_JAVA_PORT1}
#### 	echo "selinux state chage to permissive"
#### 	setenforce 0
#### 	sed -i -e s/SELINUX=enforcing/SELINUX=permissive/ /etc/sysconfig/selinux
#### 	sed -i -e s/SELINUX=enforcing/SELINUX=permissive/ /etc/selinux/config
#### fi

#### FIREWALL=`systemctl is-enabled firewalld.service`

#### if [ ${FIREWALL} == enabled ]; then
#### 	echo "firewalld : open port ${DB_TOMCAT_PORT}"
#### 	firewall-cmd --add-port=${DB_TOMCAT_PORT}/tcp --zone=public --permanent
#### 	firewall-cmd --reload
#### fi

# ghostscript japanese fonts
cat ${SRC_DIR}/src/gs_font/add_cidfmap >> /usr/share/ghostscript/Resource/Init/cidfmap

# tomcat

tar zxf ${SRC_DIR}/src/wspeedi.tar.gz -C /var/lib/tomcats/

sed -i -e s/I_CPORT/${DB_TOMCAT_PORT}/ /var/lib/tomcats/wspeedi/conf/server.xml
sed -i -e s/I_JPORT1/${DB_TOMCAT_JAVA_PORT1}/ /var/lib/tomcats/wspeedi/conf/server.xml
sed -i -e s/I_JPORT2/${DB_TOMCAT_JAVA_PORT2}/ /var/lib/tomcats/wspeedi/conf/server.xml

chown -R ${DB_USER}:tomcat /var/lib/tomcats/wspeedi

DB_USER_HOME=`eval echo ~${DB_USER}`
WRF_VER=${WRF_SRC##*/}
WRF_VER=${WRF_VER%.tar.gz}
WRF_DIR=${WRF_INSTALL_DIR}/${WRF_VER}
WPS_VER=${WPS_SRC##*/}
WPS_VER=${WPS_VER%.tar.gz}
WPS_DIR=${WRF_INSTALL_DIR}/${WPS_VER}
GEOG_DIR=${WRF_INSTALL_DIR}/WPS_GEOG

CORE_NUM=`grep processor /proc/cpuinfo | wc -l`
if [ ${CORE_NUM} -ge 10 ]; then
	UCORE=8
elif [ ${CORE_NUM} -ge 6 ]; then
	UCORE=4
elif [ ${CORE_NUM} -ge 4 ]; then
        UCORE=2
else
        UCORE=1
fi

cp -r ${SRC_DIR}/src/wdb ${DB_USER_HOME}/.wdb
sed -i -e s/I_USER_HOME/${DB_USER_HOME//"/"/"\\/"}/ ${DB_USER_HOME}/.wdb/wdb_user.conf
sed -i -e s/I_WRF_DIR/${WRF_DIR//"/"/"\\/"}/ ${DB_USER_HOME}/.wdb/wdb_user.conf
sed -i -e s/I_WPS_DIR/${WPS_DIR//"/"/"\\/"}/ ${DB_USER_HOME}/.wdb/wdb_user.conf
sed -i -e s/I_GEOG_DIR/${GEOG_DIR//"/"/"\\/"}/ ${DB_USER_HOME}/.wdb/wdb_user.conf
sed -i -e s/I_UCORE/${UCORE//"/"/"\\/"}/ ${DB_USER_HOME}/.wdb/wdb_user.conf

if [ ${DB_SAMPLE_INSTALL} == yes ]; then
	tar zxf src/sampledb.tar.gz -C ${DB_USER_HOME}
	chown -R ${DB_USER}:${DB_GROUP} ${DB_USER_HOME}/sampledb
	sed -i -e s/I_USER_HOME/${DB_USER_HOME//"/"/"\\/"}/ ${DB_USER_HOME}/sampledb/DB/d3/DB_info/DB.conf
	sed -i -e s/I_USER_HOME/${DB_USER_HOME//"/"/"\\/"}/ ${DB_USER_HOME}/.wdb/DB_list.conf
	sed -i -e s/I_DB_NAME/sampledb/ ${DB_USER_HOME}/.wdb/wdb_user.conf
else
	rm -f ${DB_USER_HOME}/.wdb/DB_list.conf
	touch ${DB_USER_HOME}/.wdb/DB_list.conf
	sed -i -e s/I_DB_NAME/\ / ${DB_USER_HOME}/.wdb/wdb_user.conf
fi
chown -R ${DB_USER}:${DB_GROUP} ${DB_USER_HOME}/.wdb

cp src/tomcat/tomcat-wdb@sysconfig /etc/sysconfig/tomcat-wdb@${DB_USER}
sed -i -e s/I_USER_NAME/${DB_USER}/ /etc/sysconfig/tomcat-wdb@${DB_USER}
sed -i -e s/I_CPORT/${DB_TOMCAT_PORT}/ /etc/sysconfig/tomcat-wdb@${DB_USER}

cp src/tomcat/tomcat-wdb@.service /usr/lib/systemd/system/tomcat-wdb@.service

chown -R ${DB_USER} /var/cache/tomcat/work
chown -R ${DB_USER} /var/lib/tomcat/webapps
chown -R ${DB_USER} /var/cache/tomcat/temp
chown -R ${DB_USER} /var/log/tomcat
chown -R ${DB_USER} /usr/share/java/tomcat
chown -R ${DB_USER} /etc/tomcat
chown -R ${DB_USER} /var/cache/tomcat
chown -R ${DB_USER} /var/lib/tomcats


#### exit

#### systemctl daemon-reload
#### systemctl enable tomcat-wdb@${DB_USER}
#### systemctl start tomcat-wdb@${DB_USER}

# WRF

### NetCDF
mkdir -p ${LINK_FOR_WRF}
ln -s /usr/include/netcdf.inc /usr/lib64/gfortran/modules/netcdf.inc
ln -s /usr/lib64/gfortran/modules ${LINK_FOR_WRF}/include
ln -s /usr/lib64 ${LINK_FOR_WRF}/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${LINK_FOR_WRF}/lib
export LD_INCLUDE_PATH=$LD_INCLUDE_PATH:${LINK_FOR_WRF}/include
export NETCDF=${LINK_FOR_WRF}

### openmpi
export MPI=/usr/lib64/openmpi
export PATH=$PATH:$MPI/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MPI/lib

### Compiler
export FC=gfortran
#export F90=gfortran
#export F77=gfortran
export CC=gcc
export CXX=g++


if [ "${WRF_SRC:0:1}" != "/" ]; then
	WRF_SRC=${SRC_DIR}/${WRF_SRC}
fi
if [ "${WPS_SRC:0:1}" != "/" ]; then
	WPS_SRC=${SRC_DIR}/${WPS_SRC}
fi
if [ "${GEOG_SRC:0:1}" != "/" ]; then
	GEOG_SRC=${SRC_DIR}/${GEOG_SRC}
fi
replace_dir=${WRF_DIR//\//\\/}

mkdir -p ${WRF_INSTALL_DIR}
tar zxf ${WRF_SRC} -C ${WRF_INSTALL_DIR}/
tar zxf ${WPS_SRC} -C ${WRF_INSTALL_DIR}/
tar zxf ${GEOG_SRC} -C ${WRF_INSTALL_DIR}/

centOS_version=`cat /etc/redhat-release | awk -F'release' '{print $2}' | awk -F'.' '{print $1}' | sed -e 's/ //g'`

export WRF_DIR=${WRF_DIR}
export geog_data_dir=${GEOG_DIR}
# -----------------------------------
# WRF compile
# -----------------------------------
cd ${WRF_DIR}

# add Output Var
# 	EXCH_H
# 	CUTOP
# 	DFGDP
# 	VDFG
sed -i -e "/SCALAR EXCHANGE COEFFICIENTS/s/r\s*\"EXCH_H\"/rh \"EXCH_H\"/g" \
	-e "/TOP OF CONVECTION LEVEL FROM CUMULUS PAR/s/r\s*\"CUTOP\"/rh \"CUTOP\"/g" \
	-e "/Fog deposition during timestep/s/-\s*\"dfgdp\"/h \"dfgdp\"/g" \
	-e "/Deposition velocity of fog/s/-\s*\"vdfg\"/h \"vdfg\"/g" \
	Registry/Registry.EM_COMMON

# For CentOS7
LANG=C

expect ${SRC_DIR}/src/expect/configure_wrf.exp &> configure.log
if [ $? -gt 0 ]; then
	echo "Configuring WRF was failed."
	echo "Please see '$WRF_DIR/configure.log'."
	exit
fi
./compile em_real &> compile.log
if [ $? -gt 0 ]; then
	echo "Compiling WRF was failed."
	echo "Please see '$WRF_DIR/compile.log'."
	exit
else
	if [ -e main/ndown.exe -a -e main/real.exe -a -e main/wrf.exe -a -e main/tc.exe ]; then
		echo "Compiling WRF was successfully done."
	else
		echo "Compiling WRF was failed."
		echo "Please see '$WRF_DIR/compile.log'."
		exit
	fi
fi

# -----------------------------------
# WPS compile
# -----------------------------------
cd ${WPS_DIR}

# ungrib/src/read_namelist.F 
# gcc-4.4.7でallocatable属性とnamelist属性が競合するバグの対応。
# 競合しないgccを使用しているならばこの処理は必要ない。
unset result
result=`grep "allocatable :: new_plvl" ungrib/src/read_namelist.F`
if [ "${centOS_version}" = "6" ]; then
	if [ -n "${result}" ]; then
		# ungrib/src/ungrib.F内のmaxlvlに合わせて
		sed -i -e "s/real, dimension(:), allocatable :: new_plvl/real, dimension(250) :: new_plvl/" \
			-e "/allocate(new_plvl(size(new_plvl_in)))/d" \
			-e "/deallocate(new_plvl)/d" \
			ungrib/src/read_namelist.F
		echo "ungrib/src/read_namelist.F: new_plvl set 250"
	fi
fi

# MSMデータの変換に対応
unset result
result=`grep "& gfld%ipdtmpl(12) .eq. 15 .or." ungrib/src/rd_grib2.F`
if [ -z "${result}" ]; then
	insert_row=$((`grep -nE '! Height above ground \(m\)' ungrib/src/rd_grib2.F | sed -e 's/:.*//'` + 2))
	sed -i ${insert_row}i"\     & gfld%ipdtmpl(12) .eq. 15 .or." ungrib/src/rd_grib2.F
	echo "ungrib/src/rd_grib2.F at ${insert_row} :\"& gfld%ipdtmpl(12) .eq. 15 .or.\" add"
fi

expect ${SRC_DIR}/src/expect/configure_wps.exp &> configure.log
if [ $? -gt 0 ]; then
	echo "Configuring WPS was failed."
	echo "Please see '$WPS_DIR/configure.log'."
	exit
fi
# "WRF_DIR\s*="を含む全ての行を"<tab>WRF_DIR<tab>=<tab>$WRF_DIR"で置換
sed -i -e "/WRF_DIR\s*=/ s/.*/\tWRF_DIR\t=\t$replace_dir/" configure.wps
# WPSV4.0にて、(先頭に<tab>を含まない)"WRF_DIR\s*="を含む行が、ただ一行のみでなければ
# フルパスと判断してもらえない問題に対応
sed -i -e "0,/WRF_DIR\s*=/ s/\s*WRF_DIR\s*=.*/WRF_DIR\t=\t$replace_dir/" configure.wps
# "-libnetcdf" を "-libnetcdff -libnetcdf -lgomp" に置換
sed -i -e "/-L\$(NETCDF)\/lib/s/-lnetcdf/-lnetcdff -lnetcdf -lgomp/" configure.wps
./compile &> compile.log
if [ $? -gt 0 ]; then

	echo "Compiling WPS was failed."
	echo "Please see '$WPS_DIR/compile.log'."
	exit
else
	if [ -e geogrid.exe -a -e ungrib.exe -a -e metgrid.exe ]; then
		echo "Compiling WPS was successfully done."
		cp ${SRC_DIR}/src/WPS/METGRID.TBL.ARW.mod $WPS_DIR/metgrid/
		rm -f $WPS_DIR/metgrid/METGRID.TBL
		ln -s $WPS_DIR/metgrid/METGRID.TBL.ARW.mod $WPS_DIR/metgrid/METGRID.TBL
	else
		echo "Compiling WPS was failed."
		echo "Please see '$WPS_DIR/compile.log'."
		exit
	fi
fi
