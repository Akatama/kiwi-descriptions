#!/bin/bash
#======================================
# kiwi helper functions
#--------------------------------------
test -f /.kconfig && . /.kconfig

set -euxo pipefail

declare kiwi_iname=${kiwi_iname}
declare kiwi_profiles=${kiwi_profiles}

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [${kiwi_iname}]-[${kiwi_profiles}]..."

#======================================
# Clear machine specific configuration
#--------------------------------------
## Clear machine-id on pre generated images
rm -f /etc/machine-id
echo 'uninitialized' > /etc/machine-id
## remove random seed, the newly installed instance should make its own
rm -f /var/lib/systemd/random-seed

#======================================
# !Container: Setup default target
#--------------------------------------
if [[ "$kiwi_profiles" != *"Container"* ]]; then
	if [[ "$kiwi_profiles" == *"Desktop"* ]]; then
		systemctl set-default graphical.target
	else
		systemctl set-default multi-user.target
	fi
fi

#======================================
# !Container: Set SELinux booleans
#--------------------------------------
if [[ "$kiwi_profiles" != *"Container"* ]]; then
	## Fixes KDE Plasma, see rhbz#2058657
	setsebool -P selinuxuser_execmod 1
fi

#======================================
# Cloud|Live: Delete & lock root user
#--------------------------------------
if [[ "$kiwi_profiles" == *"Cloud"* ]] || [[ "$kiwi_profiles" == *"Live"* ]]; then
	passwd -d root
	passwd -l root
fi

#======================================
# Cloud: Setup default customizations
#--------------------------------------
if [[ "$kiwi_profiles" == *"Cloud"* ]]; then
	# dracut disable hostonly
	mkdir -p /etc/dracut.conf.d
	echo 'hostonly="no"' > /etc/dracut.conf.d/02-generic-image.conf

	# cloud mandatory services
	for service in \
		sshd \
		chronyd \
		NetworkManager
	do
		systemctl enable "${service}"
	done

	# cloud-init services if config is present
	if [ -e /etc/cloud/cloud.cfg ];then
		for service in \
			cloud-init-local \
			cloud-init \
			cloud-config \
			cloud-final
		do
			systemctl enable "${service}"
		done
	fi
fi

#======================================
# Azure: Setup
#--------------------------------------
if [[ "$kiwi_profiles" == *"Azure"* ]]; then
	cat > /etc/ssh/sshd_config.d/50-client-alive-interval.conf <<- EOF
	ClientAliveInterval 120
	EOF

	cat >> /etc/chrony.conf <<- EOF
	# Azure's virtual time source:
	# https://docs.microsoft.com/en-us/azure/virtual-machines/linux/time-sync#check-for-ptp-clock-source
	refclock PHC /dev/ptp_hyperv poll 3 dpoll -2 offset 0
	EOF

	# Support Azure's accelerated networking feature;
	# without this the network fails to come up. It may need
	# adjustments for additional drivers in the future.
	cat > /etc/NetworkManager/conf.d/99-azure-unmanaged-devices.conf <<- EOF
	# Ignore SR-IOV interface on Azure, since it's transparently bonded
	# to the synthetic interface
	[keyfile]
	unmanaged-devices=driver:mlx4_core;driver:mlx5_core
	EOF

	# dhcp should not set the hostname, waagent does that
	baseUpdateSysConfig /etc/sysconfig/network/dhcp DHCLIENT_SET_HOSTNAME "no"

	# included from azure-scripts
	# Implement password policy
	# Length: 6-72 characters long
	# Contain any combination of 3 of the following:
	#   - a lowercase character
	#   - an uppercase character
	#   - a number
	#   - a special character
	pwd_policy="minlen=6 dcredit=1 ucredit=1 lcredit=1 ocredit=1 minclass=3"
	sed -i -e "s/pam_cracklib.so/pam_cracklib.so $pwd_policy/" \
		/etc/pam.d/common-password-pc

	# ssh: ClientAliveInterval 180sec
	sed -i -e 's/#ClientAliveInterval 0/ClientAliveInterval 180/' \
		/usr/etc/ssh/sshd_config

	# ssh: ChallengeResponseAuthentication no
	sed -i -e "s/#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/" \
		/usr/etc/ssh/sshd_config

	# Keep the default kernel log level (bsc#1169201)
	sed -i -e 's/$klogConsoleLogLevel/#$klogConsoleLogLevel/' /etc/rsyslog.conf

	# dhcp timeout 300sec
	dc=/etc/dhclient.conf
	if grep -qE '^timeout' $dc ; then
		sed -r -i 's/^timeout.*/timeout 300;/' $dc
	else
		echo 'timeout 300;' >> $dc
	fi

    # Azure agent
    systemctl enable waagent
fi

#======================================
# GCE: Setup
#--------------------------------------
if [[ "$kiwi_profiles" == *"GCE"* ]]; then
	cat > /etc/NetworkManager/conf.d/gcp-mtu.conf <<- EOF
	# In GCP it is recommended to use 1460 as the MTU.
	# Set it to 1460 for all connections.
	# https://cloud.google.com/network-connectivity/docs/vpn/concepts/mtu-considerations
	[connection]
	ethernet.mtu = 1460
	EOF
fi
