# VMAX Cinder Driver

Copyright (c) 2016 EMC Corporation.
All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

## Contents

    emc_vmax_fc.py
    emc_vmax_iscsi.py
    emc_vmax_common.py
    emc_vmax_masking.py
    emc_vmax_fast.py
    emc_vmax_provision.py
    emc_vmax_provision_v3.py
    emc_vmax_https.py
    emc_vmax_utils.py
    test_emc_vmax.py

* README.md is the documentation for this patch

# VMAX Driver (FC and iSCSI)

## Overview

This package consists of two drivers:
*	EMCVMAXFCDriver, based on the Cinder FibreChannelDriver 
*	EMCVMAXISCSIDriver, based on the Cinder ISCSIDriver 

These drivers support the use of EMC VMAX storage arrays under OpenStack Cinder block management.  They both provide equivalent functions and differ only in support for their respective host attachment methods. 

The drivers perform volume operations through use of the EMC SMI-S Provider, which is packaged with Solutions Enabler. The SMI-S Provider implements the SNIA Storage Management Initiative (SMI), an ANSI standard for storage management. 

EMC Cinder drivers also require PyWBEM, a client library written in Python that communicates with the SMI-S provider over HTTP. 

## OpenStack Release Support

This driver package supports the Mitaka release. Compared to previously released versions, enhancements include:
*	Support for consistency groups.
*	Support for live migration.
*	Use lookup service in FC auto zoning. 

## Supported Operations

The following operations are supported on VMAX arrays:
*	Create volume
*	Delete volume
*	Extend volume
*	Attach volume
*	Detach volume
*	Create snapshot
*	Delete snapshot
*	Create volume from snapshot
*	Create cloned volume
*	Copy image to volume
*	Copy volume to image
*	Create consistency group
*	Delete consistency group
*	Create Cgsnapshot (snapshot of a consistency group)
*	Delete Cgsnapshot

VMAX drivers also support the following features:
*  Dynamic masking view creation.
*  Dynamic determination of the target iSCSI IP address.

VMAX2
*  FAST automated storage tiering policy.
*  Striped volume creation.

VMAX3
*  SLO support.
*  Dynamic masking view creation.
*  SnapVX support.
*  Extend volume and iSCSI support.

## Required Software Packages

### Install SMI-S Provider with Solutions Enabler 
*	EMC SMI-S Provider 4.6.2.29(Solutions Enabler 7.6.2.67) for VMAX2
*	Solutions Enabler 8.1.2(with SMI-S component) for VMAX2 and VMAX3
*	SMI-S Provider is available from available from [EMC’s support website](https://support.emc.com)
*	The SMI-S Provider with Solutions Enabler can be installed as a vApp, or on a Windows or Linux host
*       Ensure that there is only one SMI-S (ECOM) server active on the same VMAX array.

### Required VMAX Software Suites for OpenStack
There are five Software Suites available for the VMAX3:

* Base Suite
* Advanced Suite
* Local Replication Suite
* Remote Replication Suite
* Total Productivity Pack

Openstack requires the Advanced Suite and the Local Replication Suite
or the Total Productivity Pack (it includes the Advanced Suite and the
Local Replication Suite) for the VMAX3.

There are four bundled Software Suites for the VMAX2:

* Advanced Software Suite
* Base Software Suite
* Enginuity Suite
* Symmetrix Management Suite

OpenStack requires the Advanced Software Bundle for the VMAX2.

or

The VMAX2 Optional Software are:

* EMC Storage Analytics (ESA)
* FAST VP
* Ionix ControlCenter and ProSphere Package
* Open Replicator for Symmetrix
* PowerPath
* RecoverPoint EX
* SRDF for VMAX 10K
* Storage Configuration Advisor
* TimeFinder for VMAX10K

### eLicensing Support
OpenStack requires TimeFinder for VMAX10K for the VMAX2.

Each are licensed separately. For further details on how to get the
relevant license(s), reference eLicensing Support below.

To activate your entitlements and obtain your VMAX license files, visit the
Service Center on ``https://support.emc.com``, as directed on your License
Authorization Code (LAC) letter emailed to you.

-  For help with missing or incorrect entitlements after activation
   (that is, expected functionality remains unavailable because it is not
   licensed), contact your EMC account representative or authorized reseller.

-  For help with any errors applying license files through Solutions Enabler,
   contact the EMC Customer Support Center.

-  If you are missing a LAC letter or require further instructions on
   activating your licenses through the Online Support site, contact EMC's
   worldwide Licensing team at ``licensing@emc.com`` or call:

   North America, Latin America, APJK, Australia, New Zealand: SVC4EMC
   (800-782-4362) and follow the voice prompts.

   EMEA: +353 (0) 21 4879862 and follow the voice prompts.

### Install PyWBEM
* Required version: PyWBEM 0.7 only
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
    emc_vmax_provision_v3.py
    emc_vmax_https.py
    emc_vmax_utils.py

These files are located in the ../cinder/volume/drivers/emc/ directory of OpenStack node(s) where cinder-volume is running.

## Cinder Backend Configuration

The EMC VMAX drivers are written to support multiple types of storage, as configured by the OpenStack Cinder administrator. Each storage type is implemented by configuring one or more Cinder backends mapped to that type. If multiple storage types are desired, multi-backend support must be enabled in the cinder.conf file as shown:

    [DEFAULT]

        enabled_backends=CONF_GROUP_ISCSI, CONF_GROUP_FC

        [CONF_GROUP_ISCSI]
        volume_driver=cinder.volume.drivers.emc.emc_vmax_iscsi.EMCVMAXISCSIDriver
        cinder_emc_config_file=/etc/cinder/cinder_emc_config_CONF_GROUP_ISCSI.xml
        volume_backend_name=ISCSI_backend

        [CONF_GROUP_FC]
        volume_driver=cinder.volume.drivers.emc.emc_vmax_fc.EMCVMAXFCDriver
        cinder_emc_config_file=/etc/cinder/cinder_emc_config_CONF_GROUP_FC.xml
        volume_backend_name=FC_backend

 
In this example, two backend configuration groups are enabled: CONF_GROUP_ISCSI and CONF_GROUP_FC. Each configuration group has a section describing unique parameters for connections, drivers, the volume_backend_name, and the name of the EMC-specific configuration file containing additional settings. Note that the file name is in the format /etc/cinder/cinder_emc_config_<confGroup>.xml.  See the section below for a description of the file contents.

Once the cinder.conf and EMC-specific configuration files have been created, cinder commands need to be issued in order to create and associate OpenStack volume types with the declared volume_backend_names:
  
        # cinder type-create VMAX_ISCSI
        # cinder type-key VMAX_ISCSI set volume_backend_name=ISCSI_backend
        # cinder type-create VMAX_FC
        # cinder type-key VMAX_FC set volume_backend_name=FC_backend

By issuing these commands, the Cinder volume type VMAX_ISCSI is associated with the ISCSI_backend, and the type VMAX_FC associated with FC_backend

For more details on multi-backend configuration, see [OpenStack Administration Guide](http://docs.openstack.org/admin-guide-cloud/content/multi_backend.html).

## EMC-specific Configuration Files

Each enabled backend is configured via parameters contained in an EMC-specific configuration file. The default EMC configuration file is named /etc/cinder/cinder_emc config.xml, and is configured for the iSCSI driver by default. When multiple backends are configured in cinder.conf, the names of each configuration groups file is explicitly provided in the cinder_emc_config_file parameter.

Here is an example and description of the contents:

VMAX2

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

VMAX3

    <?xml version="1.0" encoding="UTF-8" ?>
    <EMC>
         <EcomServerIp>1.1.1.1</EcomServerIp>
         <EcomServerPort>00</EcomServerPort>
         <EcomUserName>user1</EcomUserName>
         <EcomPassword>password1</EcomPassword>
         <PortGroups>
           <PortGroup>OS-PORTGROUP1-PG</PortGroup>
           <PortGroup>OS-PORTGROUP2-PG</PortGroup>
         </PortGroups>
         <Array>111111111111</Array>
         <Pool>SRP_1</Pool>
         <Slo>Gold</Slo>
         <Workload>OLTP</Workload>
    </EMC>

 
***EcomServerIp*** - IP address of the ECOM server which is packaged with SMI-S.

***EcomServerPort*** - Port number of the ECOM server which is packaged with SMI-S.

***EcomUserName*** and ***EcomPassword*** - Credentials for the ECOM server.

***PortGroups*** - Supplies the names of VMAX port groups that have been pre-configured to
    expose volumes managed by this backend. Each supplied port group should
    have sufficient number and distribution of ports (across directors and
    switches) as to ensure adequate bandwidth and failure protection for the
    volume connections. PortGroups can contain one or more port groups of
    either iSCSI or FC ports. When a dynamic masking view is created by the
    VMAX driver, the port group is chosen randomly from the PortGroup list, to
    evenly distribute load across the set of groups provided. Make sure that
    the PortGroups set contains either all FC or all iSCSI port groups (for a
    given back end), as appropriate for the configured driver (iSCSI or FC).

***Array*** - Unique VMAX array serial number.

***Pool*** - Unique pool name within a given array. For back ends not using FAST
    automated tiering, the pool is a single pool that has been created by the
    administrator. For back ends exposing FAST policy automated tiering, the
    pool is the bind pool to be used with the FAST policy.

VMAX2 ***FastPolicy*** - Name of the FAST Policy to be used. By including this tag, volumes managed
    by this back end are treated as under FAST control. Omitting the
    ***FastPolicy*** tag means FAST is not enabled on the provided storage pool.

VMAX3 ***Slo*** - The Service Level Objective (SLO) that manages the underlying storage to
    provide expected performance. Omitting the ***Slo*** tag means ***Optimised***
    SLO will be used instead.

VMAX3 ***Workload*** - When a workload type is added, the latency range is reduced due to the
    added information. Omitting the ***Workload*** tag means the latency
    range will be the widest for its SLO type. 

## Configuring Connectivity

### FC Zoning with VMAX

Zone Manager is required when there is a fabric between the host and array. This
is necessary for larger configurations where pre-zoning would be too complex and
open-zoning would raise security concerns.

### iSCSI with VMAX
*	Make sure the iscsi-initiator-utils is installed on the all nodes (compute and controller)
*	You can only ping the VMAX iSCSI target ports when there is a valid masking view. An attach operation creates this masking view.

## VMAX Masking View and Group Naming Info

### Masking View Names
Masking views for the VMAX FC and iSCSI drivers are now dynamically created by the VMAX Cinder driver using the following naming conventions:

VMAX2

    OS-<shortHostName>-<poolName>-I-MV (for Masking Views using iSCSI)
    OS-<shortHostName>-<poolName>-F-MV (for Masking Views using FC)

or
 
    OS-<shortHostName>-<FastPolicyName>-FP-<Protocol>-MV

VMAX3

    OS-<shortHostName>-<SRP>-<SLO>-<Workload>-<Protocol>-MV
    

### Initiator Group Names
For each host that is attached to VMAX volumes using the Cinder drivers, an initiator group is created or re-used (per attachment type). All initiators of appropriate type known for that host are included in the group. At each new attach volume operation, the VMAX driver retrieves the initiators (either WWNNs or IQNs) from OpenStack and adds or updates the contents of the Initiator Group as required. Names are of the format:

    OS-<shortHostName>-I-IG (for iSCSI initiators)
    OS-<shortHostName>-F-IG (for Fibre Channel initiators)

Note: Hosts attaching to VMAX storage managed by the OpenStack environment cannot also be attached to storage on the same VMAX not being managed by OpenStack. This is due to limitations on VMAX Initiator Group membership.

### FA Port Groups 
VMAX array FA ports to be used in a new masking view are chosen from the list provided in the EMC configuration file.  (See EMC-specific Configuration Files above)

### Storage Group Names
As volumes are attached to a host, they are either added to an existing storage group (if it exists) or a new storage group is created and the volume is then added. Storage groups contain volumes created from a pool (either single-pool or FAST-controlled), attached to a single host, over a single connection type (iSCSI or FC). Names are formed:

VMAX2

    OS-<shortHostName>-<poolName>-I-SG (attached over iSCSI)
    OS-<shortHostName>-<poolName>-F-SG (attached over Fibre Channel)

or

    OS-<shortHostName>-<FastPolicyName>-FP-<Protocol>-SG

VMAX3

    OS-<shortHostName>-<SRP>-<SLO>-<Workload>-<Protocol>-SG

## Concatenated/Striped volumes
In order to support later expansion of created volumes, the VMAX Cinder drivers create concatenated volumes as the default layout. If later expansion is not required, users can opt to create striped volumes in order to optimize I/O performance.  

Below is an example of how to create striped volumes. First, create a volume type. Then define the extra spec for the volume type -- storagetype:stripecount  represents the number of strips you want to make up your volume. The example below means that all volumes created under the GoldStriped volume type will be striped and made up of 4 stripes  
   
        # cinder type-create GoldStriped
        # cinder type-key GoldStriped set volume_backend_name=GOLD_BACKEND
        # cinder type-key GoldStriped set storagetype:stripecount=4

