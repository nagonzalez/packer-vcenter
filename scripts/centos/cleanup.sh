#!/usr/bin/env bash

set -e
set -x

# Stop services for cleanup
sudo service rsyslog stop
sudo service auditd stop

# Remove old kernels (doesn't work on CentOS 8)
# sudo package-cleanup -y --oldkernels --count=1

# clean out yum
sudo yum clean all
sudo rm -rf /var/cache/yum

# Force the logs to rotate & remove old logs we don’t need
sudo logrotate /etc/logrotate.conf --force
sudo rm -f /var/log/*-???????? /var/log/*.gz
sudo rm -f /var/log/dmesg.old
sudo rm -rf /var/log/anaconda

# Truncate the audit logs (and other logs we want to keep placeholders for)
sudo bash -c "cat /dev/null > /var/log/audit/audit.log"
sudo bash -c "cat /dev/null > /var/log/wtmp"
sudo bash -c "cat /dev/null > /var/log/lastlog"
sudo bash -c "cat /dev/null > /var/log/grubby"

# Remove the traces of the template MAC address and UUIDs
sudo sed -i '/^\(HWADDR\|UUID\)=/d' /etc/sysconfig/network-scripts/ifcfg-e*

# cleanup /tmp directories
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

# cleanup current ssh keys
sudo rm -f /etc/ssh/ssh_host_*

# reset hostname
sudo bash -c "cat /dev/null > /etc/hostname"

# cleanup shell history
history -cw
