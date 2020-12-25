#!/usr/bin/env bash

set -x

OS=''

OMSA_SH='/opt/dell/srvadmin/sbin/srvadmin-services.sh'

get_os ()
{
	if [ -e '/etc/debian_release' ]; then
		OS=0
		return
	elif [ -e '/etc/debian_version' ]; then
    	OS=0
    	return
	elif [ -e '/etc/redhat_release' ]; then
		OS=1
		return
	else
		echo "System unrecognized!"
		exit 1
	fi
}

install_omsa_proxmox ()
{
	cat <<- _EOF_ > /etc/apt/sources.list.d/linux.dell.com.sources.list
	deb http://linux.dell.com/repo/community/openmanage/930/bionic bionic main
	_EOF_

	gpg --keyserver pool.sks-keyservers.net --recv-key 1285491434D8786F && gpg -a --export 1285491434D8786F | apt-key add -

	apt update

	TMP_DIR='tmp_dir'
	mkdir $TMP_DIR
	cd $TMP_DIR

	cat <<- _EOF_ > debs
	http://archive.ubuntu.com/ubuntu/pool/universe/o/openwsman/libwsman-curl-client-transport1_2.6.5-0ubuntu3_amd64.deb
	http://archive.ubuntu.com/ubuntu/pool/universe/o/openwsman/libwsman-client4_2.6.5-0ubuntu3_amd64.deb
	http://archive.ubuntu.com/ubuntu/pool/universe/o/openwsman/libwsman1_2.6.5-0ubuntu3_amd64.deb
	http://archive.ubuntu.com/ubuntu/pool/universe/o/openwsman/libwsman-server1_2.6.5-0ubuntu3_amd64.deb
	http://archive.ubuntu.com/ubuntu/pool/universe/s/sblim-sfcc/libcimcclient0_2.2.8-0ubuntu2_amd64.deb
	http://archive.ubuntu.com/ubuntu/pool/universe/o/openwsman/openwsman_2.6.5-0ubuntu3_amd64.deb
	http://archive.ubuntu.com/ubuntu/pool/multiverse/c/cim-schema/cim-schema_2.48.0-0ubuntu1_all.deb
	http://archive.ubuntu.com/ubuntu/pool/universe/s/sblim-sfc-common/libsfcutil0_1.0.1-0ubuntu4_amd64.deb
	http://archive.ubuntu.com/ubuntu/pool/multiverse/s/sblim-sfcb/sfcb_1.4.9-0ubuntu5_amd64.deb
	http://archive.ubuntu.com/ubuntu/pool/universe/s/sblim-cmpi-devel/libcmpicppimpl0_2.0.3-0ubuntu2_amd64.deb
	_EOF_

	while read DEB; do wget $DEB; done < debs
	
    rm debs
	ls -1 > packets
	
    while read PACK; do dpkg -i $PACK; done < packets

	cd ..
	rm -rf $TMP_DIR
	
    apt update
	apt install srvadmin-all libncurses5

	$OMSA_SH start
	touch /opt/dell/srvadmin/lib64/openmanage/IGNORE_GENERATION
	$OMSA_SH restart
}

install_omsa_centOS ()
{
	curl -s http://linux.dell.com/repo/hardware/dsu/bootstrap.cgi | bash
	yum install srvadmin-all
	
    $OMSA_SH start

	cat <<- _EOF_ > /etc/systemd/dell-omsa.service
	[Unit]
	Description=Dell OpenManage Server Administrator
	Wants=network-online.target
	After=network-online.target

	[Service]
	Type=oneshot
	User=root
	Group=root
	RemainAfterExit=true
	ExecStart=/opt/dell/srvadmin/sbin/srvadmin-services.sh start
	ExecStop=/opt/dell/srvadmin/sbin/srvadmin-services.sh stop
	ExecReload=/opt/dell/srvadmin/sbin/srvadmin-services.sh restart

	[Install]
	WantedBy=multi-user.target
	_EOF_

    systemctl status dell-omsa.service
    if [ $? == 0 ]; then
    	systemctl enable dell-omsa.service
    fi
}

get_os

[ $OS -gt 0 ] && install_omsa_centOS || install_omsa_proxmox

exit 0
