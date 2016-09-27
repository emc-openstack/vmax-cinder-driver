#!/bin/bash
export OPENSTACK_HOME=/opt/stack
echo 'Openstack home is '
echo ${OPENSTACK_HOME}
find . -type f -exec dos2unix {} \;
cp -r os_brick ${OPENSTACK_HOME}/nova/nova/.
cp ${OPENSTACK_HOME}/nova/nova/virt/libvirt/volume.py volume.py.bak
cp volume.py ${OPENSTACK_HOME}/nova/nova/virt/libvirt/volume.py
