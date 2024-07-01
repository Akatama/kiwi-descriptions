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
	# Azure agent sshd_config fix
	cp -a /usr/etc/ssh/sshd_config /etc/ssh/sshd_config

	# Azure time
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

	# SSH config overlay
	cat > /usr/etc/ssh/sshd_config.d/40-azure.conf <<- EOF
	ClientAliveInterval 180
	ChallengeResponseAuthentication no
	PasswordAuthentication no
	UsePAM yes
	EOF

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
