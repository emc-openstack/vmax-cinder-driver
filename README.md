# VMAX Driver (FC and iSCSI)

Copyright (c) 2014 EMC Corporation.
All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

## Overview

This package consists of two drivers:
*	EMCVMAXFCDriver, based on the Cinder FibreChannelDriver 
*	EMCVMAXISCSIDriver, based on the Cinder ISCSIDriver 

These drivers support the use of EMC VMAX storage arrays under OpenStack Cinder block management.  They both provide equivalent functions and differ only in support for their respective host attachment methods. 

The drivers perform volume operations through use of the EMC SMI-S Provider, which is packaged with Solutions Enabler. The SMI-S Provider implements the SNIA Storage Management Initiative (SMI), an ANSI standard for storage management. 

EMC Cinder drivers also require PyWBEM, a client library written in Python that communicates with the SMI-S provider over HTTP. 

## OpenStack Release Support

This driver package supports the Havana release. Compared to previously released versions, enhancements include:
*	Support for multiple VMAX arrays
*	Support for per-array ECOM servers
*	Multiple Pool Support
*	FAST automated storage tiering policy support
*	Dynamic masking view creation (FC and iSCSI)
*	Striped volume creation
*	Storage-Assisted Volume Migration

## Supported Operations

The following operations are supported on VMAX arrays:
*	Create volume
*	Delete volume
*	Extend volume
*	Attach volume
*	Detach volume
*	Retype volume
*	Create snapshot
*	Delete snapshot
*	Create volume from snapshot
*	Create cloned volume
*	Copy Image to Volume
*	Copy Volume to Image

## Required Software Packages

### Install SMI-S Provider with Solutions Enabler
*	Required version: EMC SMI-S Provider 4.6.2.9 or higher 
*	SMI-S Provider is available from available from [EMC’s support website](https://support.emc.com)
*	The SMI-S Provider with Solutions Enabler can be installed as a vApp, or on a Windows or Linux host

### Install PyWBEM
* Required version: PyWBEM 0.7
* Available from [Sourceforge](http://sourceforge.net/projects/pywbem), or using the following commands:
    * Install for Ubuntu:
    
            # apt-get install python-pywbem

    * Install on openSUSE:
    
            # zypper install python-pywbem
            
    * Install on Fedora:

            # yum install pywbem

### Verify the EMC VMAX Cinder driver files
EMC VMAX Drivers provided in the installer package consists of seven python files:

    emc_vmax_fc.py
    emc_vmax_iscsi.py
    emc_vmax_common.py
    emc_vmax_masking.py
    emc_vmax_fast.py
    emc_vmax_provision.py
    emc_vmax_utils.py

These files are located in the ../cinder/volume/drivers/emc/ directory of OpenStack node(s) where cinder-volume is running.

## Cinder Backend Configuration

The EMC VMAX drivers are written to support multiple types of storage, as configured by the OpenStack Cinder administrator. Each storage type is implemented by configuring one or more Cinder backends mapped to that type. If multiple storage types are desired, multi-backend support must be enabled in the cinder.conf file as shown:

[DEFAULT]

    enabled_backends=CONF_GROUP_ISCSI, CONF_GROUP_FC

    [CONF_GROUP_ISCSI]
    iscsi_ip_address = 10.10.0.50
    volume_driver=cinder.volume.drivers.emc.emc_vmax_iscsi.EMCVMAXISCSIDriver
    cinder_emc_config_file=/etc/cinder/cinder_emc_config_CONF_GROUP_ISCSI.xml
    volume_backend_name=ISCSI_backend

    [CONF_GROUP_FC]
    volume_driver=cinder.volume.drivers.emc.emc_vmax_fc.EMCVMAXFCDriver
    cinder_emc_config_file=/etc/cinder/cinder_emc_config_CONF_GROUP_FC.xml
    volume_backend_name=FC_backend

 
NOTE: iscsi_ip_address is required in an ISCSI configuration.  This is the IP Address of the VMAX iscsi target.

In this example, two backend configuration groups are enabled: CONF_GROUP_ISCSI and CONF_GROUP_FC. Each configuration group has a section describing unique parameters for connections, drivers, the volume_backend_name, and the name of the EMC-specific configuration file containing additional settings. Note that the file name is in the format /etc/cinder/cinder_emc_config_<confGroup>.xml.  See the section below for a description of the file contents.

Once the cinder.conf and EMC-specific configuration files have been created, cinder commands need to be issued in order to create and associate OpenStack volume types with the declared volume_backend_names:
  
        # cinder type-create VMAX_ISCSI
        # cinder type-key VMAX_ISCSI set volume_backend_name=ISCSI_backend
        # cinder type-create VMAX_FC
        # cinder type-key VMAX_FC set volume_backend_name=FC_backend

By issuing these commands, the Cinder volume type VMAX_ISCSI is associated with the ISCSI_backend, and the type VMAX_FC associated with FC_backend

For more details on multi-backend configuration, see [OpenStack Administration Guide](http://docs.openstack.org/admin-guide-cloud/content/multi_backend.html).

## EMC-specific Configuration Files

Each enabled backend is configured via parameters contained in an EMC-specific configuration file. The default EMC configuration file is named /etc/cinder/cinder_emc config.xml, and is configured for the iSCSI driver by default. When multiple backends are configured in cinder.conf, the names of each configuration group’s file is explicitly provided in the cinder_emc_config_file parameter.

Here is an example and description of the contents:

    <?xml version='1.0' encoding='UTF-8'?>
    <EMC>
       <EcomServerIp>10.108.246.202</EcomServerIp>
       <EcomServerPort>5988</EcomServerPort>
       <EcomUserName>admin</EcomUserName>
       <EcomPassword>#1Password</EcomPassword>
       <PortGroups>
           <PortGroup>OS-PORTGROUP1-PG</PortGroup>
	   <PortGroup>OS-PORTGROUP2-PG</PortGroup>
       </PortGroups>
       <Array>000198700439</Array>
       <Pool>FC_GOLD1</Pool>
       <FastPolicy>GOLD1</FastPolicy>
    </EMC>
  
EcomServerIp, EcomServerPort, EcomUserName and EcomPassword identify the ECOM (EMC SMI-S Provider) server to be used, and provide logon credentials.

PortGroups supplies the names of VMAX port groups that have been pre-configured to expose volumes managed by this Backend. Each supplied port group should have sufficient number and distribution of ports (across directors and switches) as to ensure adequate bandwidth and failure protection for the volume connections. PortGroups can contain one or more port groups of either iSCSI or FC ports. When a dynamic masking view is created by the VMAX driver, the port group is chosen randomly from the list above, to evenly distribute load across the set of groups provided.  

NOTE:  Make sure that the PortGroups set contains either all FC or all iSCSI port groups (for a given backend), as appropriate for the configured driver (iSCSI or FC).

The Array tag holds the unique VMAX array serial number.

The Pool tag holds the unique pool name within a given array. 

NOTE: For this version of the driver, we do not support over subscription of pools. Creating a pool with max_subs_percent greater than 100 is not recommended.

For backends not using FAST automated tiering, the pool is a single pool that has been created by the admin. 

For backends exposing FAST policy automated tiering, the pool name is the bind pool to be used with the FAST policy.

The FastPolicy tag conveys the name of the FAST Policy to be used. By including this tag, volumes managed by this backend are treated as under FAST control.  Omitting the FastPolicy tag means FAST is not enabled on the provided storage pool. 
 
## Configuring Connectivity

### FC Zoning with VMAX

With the Icehouse release of OpenStack, a Zone Manager has been added to automate Fibre Channel zone management. Havana does not support this functionality.  It is recommended to upgrade to the Juno release if you require FC zoning.

### iSCSI with VMAX
*	Make sure the “iscsi-initiator-utils” package is installed on the host (use apt-get, zypper or yum, depending on Linux flavor)
*	Verify host is able to ping VMAX iSCSI target ports

## VMAX Masking View and Group Naming Info

### Masking View Names
Masking views for the VMAX FC and iSCSI drivers are now dynamically created by the VMAX Cinder driver using the following naming conventions:

    OS-<shortHostName><poolName>-I-MV (for Masking Views using iSCSI)
    OS-<shortHostName><poolName>-F-MV (for Masking Views using FC)

### Initiator Group Names
For each host that is attached to VMAX volumes using the Cinder drivers, an initiator group is created or re-used (per attachment type). All initiators of appropriate type known for that host are included in the group. At each new attach volume operation, the VMAX driver retrieves the initiators (either WWNNs or IQNs) from OpenStack and adds or updates the contents of the Initiator Group as required. Names are of the format:

    OS-<shortHostName>-I-IG (for iSCSI initiators)
    OS-<shortHostName>-F-IG (for Fibre Channel initiators)

Note: Hosts attaching to VMAX storage managed by the OpenStack environment cannot also be attached to storage on the same VMAX not being managed by OpenStack. This is due to limitations on VMAX Initiator Group membership.

### FA Port Groups 
VMAX array FA ports to be used in a new masking view are chosen from the list provided in the EMC configuration file.  (See EMC-specific Configuration Files above)

### Storage Group Names
As volumes are attached to a host, they are either added to an existing storage group (if it exists) or a new storage group is created and the volume is then added. Storage groups contain volumes created from a pool (either single-pool or FAST-controlled), attached to a single host, over a single connection type (iSCSI or FC). Names are formed:

    OS-<shortHostName><poolName>-I-SG (attached over iSCSI)
    OS-<shortHostName><poolName>-F-SG (attached over Fibre Channel)

## Concatenated/Striped volumes
In order to support later expansion of created volumes, the VMAX Cinder drivers create concatenated volumes as the default layout. If later expansion is not required, users can opt to create striped volumes in order to optimize I/O performance.  

Below is an example of how to create striped volumes. First, create a volume type. Then define the extra spec for the volume type -- storagetype:stripecount  represents the number of strips you want to make up your volume. The example below means that all volumes created under the GoldStriped volume type will be striped and made up of 4 stripes  
   
        # cinder type-create GoldStriped
        # cinder type-key GoldStriped set volume_backend_name=GOLD_BACKEND
        # cinder type-key GoldStriped set storagetype:stripecount=4

