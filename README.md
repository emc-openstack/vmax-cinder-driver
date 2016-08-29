# VMAX Cinder Driver

Copyright (c) 2016 EMC Corporation.
All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

# VMAX Driver (FC and iSCSI)

## Overview

This package consists of two drivers:
*	EMCVMAXFCDriver, based on the Cinder FibreChannelDriver 
*	EMCVMAXISCSIDriver, based on the Cinder ISCSIDriver 

These drivers support the use of EMC VMAX storage arrays under OpenStack Cinder block management.  They both provide equivalent functions and differ only in support for their respective host attachment methods. 

The drivers perform volume operations through use of the EMC SMI-S Provider, which is packaged with Solutions Enabler. The SMI-S Provider implements the SNIA Storage Management Initiative (SMI), an ANSI standard for storage management. 

EMC Cinder drivers also require PyWBEM, a client library written in Python that communicates with the SMI-S provider over HTTP. 

## OpenStack Release Support

This driver package supports the Juno and Kilo releases. Compared to previously released versions, enhancements include:
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

## Required Software Packages

### Install SMI-S Provider with Solutions Enabler
*	Required versions: 
		EMC SMI-S Provider 4.6.2.29(Solutions Enabler 7.6.2.67) for VMAX2
		Solutions Enabler 8.1.2 for VMAX2 and VMAX3
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
    emc_vmax_provision_v3.py
    emc_vmax_https.py
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

    OS-<shortHostName>-<poolName>-I-MV (for Masking Views using iSCSI)
    OS-<shortHostName>-<poolName>-F-MV (for Masking Views using FC)

### Initiator Group Names
For each host that is attached to VMAX volumes using the Cinder drivers, an initiator group is created or re-used (per attachment type). All initiators of appropriate type known for that host are included in the group. At each new attach volume operation, the VMAX driver retrieves the initiators (either WWNNs or IQNs) from OpenStack and adds or updates the contents of the Initiator Group as required. Names are of the format:

    OS-<shortHostName>-I-IG (for iSCSI initiators)
    OS-<shortHostName>-F-IG (for Fibre Channel initiators)

Note: Hosts attaching to VMAX storage managed by the OpenStack environment cannot also be attached to storage on the same VMAX not being managed by OpenStack. This is due to limitations on VMAX Initiator Group membership.

### FA Port Groups 
VMAX array FA ports to be used in a new masking view are chosen from the list provided in the EMC configuration file.  (See EMC-specific Configuration Files above)

### Storage Group Names
As volumes are attached to a host, they are either added to an existing storage group (if it exists) or a new storage group is created and the volume is then added. Storage groups contain volumes created from a pool (either single-pool or FAST-controlled), attached to a single host, over a single connection type (iSCSI or FC). Names are formed:

    OS-<shortHostName>-<poolName>-I-SG (attached over iSCSI)
    OS-<shortHostName>-<poolName>-F-SG (attached over Fibre Channel)

## Concatenated/Striped volumes
In order to support later expansion of created volumes, the VMAX Cinder drivers create concatenated volumes as the default layout. If later expansion is not required, users can opt to create striped volumes in order to optimize I/O performance.  

Below is an example of how to create striped volumes. First, create a volume type. Then define the extra spec for the volume type -- storagetype:stripecount  represents the number of strips you want to make up your volume. The example below means that all volumes created under the GoldStriped volume type will be striped and made up of 4 stripes  
   
        # cinder type-create GoldStriped
        # cinder type-key GoldStriped set volume_backend_name=GOLD_BACKEND
        # cinder type-key GoldStriped set storagetype:stripecount=4

## Over Subscription Support
Over subscription support requires the /etc/cinder/cinder.conf to be updated with two additional tags max_over_subscription_ratio and/or reserved_percentage.In the sample below the value of 2.0 for max_over_subscription_ratio means that the pools in oversubscribed by a factor of 2, or 200% over subscribed.
The reserved_percentage is the high water mark where by the physical remaining space cannot be exceeded.  For example, if there is only 4% of physical space left and the reserve percentage is 5, the free space will equate to zero.  This is a safety mechanism to prevent a scenario that a provisioning request failing due to insufficient raw space.

The parameter max_over_subscription_ratio and reserved_percentage are optional.

To set these parameter go to the configuration group of the volume type in /etc/cinder/cinder.conf

    [VMAX_ISCSI_SILVER]
    cinder_emc_config_file = /etc/cinder/cinder_emc_config_VMAX_ISCSI_SILVER.xml
    volume_driver = cinder.volume.drivers.emc.emc_vmax_iscsi.EMCVMAXISCSIDriver
    volume_backend_name = VMAX_ISCSI_SILVER
    max_over_subscription_ratio = 2.0
    reserved_percentage = 10

For the second iteration of over subscription we take into account the EMCMaxSubscriptionPercent property on the pool.  This value is the highest that a pool can be oversubscribed.

***Scenario 1*** - EMCMaxSubscriptionPercent is 200 and the user defined max_over_subscription_ratio is 2.5, the latter is ignored.   Oversubscription is 200%.

***Scenario 2*** - EMCMaxSubscriptionPercent is 200 and the user defined max_over_subscription_ratio is 1.5, 1.5 equates to 150% and is less than the value set on the pool.  Oversubscription is 150%

***Scenario 3*** - EMCMaxSubscriptionPercent is 0.  This means there is no upper limit on the pool.  The user defined max_over_subscription_ratio is 1.5.  Oversubscription is 150%

***Scenario 4*** - EMCMaxSubscriptionPercent is 0.  max_over_subscription_ratio is not set by the user.  We default to a hardcoded upper limit which is 150%

If FAST is set and multiple pools are associated with a FAST policy, then the same rules apply.  The difference is, the TotalManagedSpace and EMCSubscribedCapacity for each pool associated with the FAST policy are aggregated.

***Scenario 5*** - EMCMaxSubscriptionPercent is 200 on one pool.  It is 300 on another pool.  The user defined max_over_subscription_ratio is 2.5.  Oversubscription is 200% on the first pool and 250% on the other.

## FAST policy

We treat a FAST policy as a .virtual pool., comprised of the sum of capacities of the underlying physical pools. Because those physical pools could be associated with multiple FAST policies, we create a storage group for each FAST policy in order to distinguish among them.  It is the therefore name of the FAST policy and not the name of the Pool that is used to generate unique names.  Please note:

The format of the storage group name is:

    OS-<shortHostName>-<FastPolicyName>-FP-<Protocol>-SG
The format of the masking view name is:

    OS-<shortHostName>-<FastPolicyName>-FP-<Protocol>-MV
The FAST policy name must not exceed 14 characters, if it does we truncate it by using the first 7 and last 6 characters(like we do for pool)

There is nothing preventing the use of the same name for a FAST policy and a pool.  Therefore, we append -FP to the FAST policy name to ensure uniqueness

## QoS (Quality of Service) Support

Quality of service has traditionally been associated with network bandwidth usage. Network administrators set limitations on certain networks in terms of bandwidth usage for clients. This enables them provide a tiered level of service based on cost. The Cinder QOS offers similar functionality based on volume type setting limits on host storage bandwidth per service offering. Each volume type is tied to specific QOS attributes that are unique to each Storage vendor.  The VMAX3 plugin offers limits via the following attributes

* By I/O limit per second (IOPS)
* By limiting throughput per second (MB/S)
* Dynamic Distribution
* The VMAX3 offers modification of QOS at the Storage Group level

### USE CASE 1 - DEFAULT VALUES

Prerequisites - VMAX

* Host I/O Limit (MB/Sec) - 	No Limit
* Host I/O Limit (IO/Sec) - 	No Limit
* Set Dynamic Distribution -	NA

Prerequisites - Cinder Backend (Storage Group)

    Key               Value
    maxIOPS           4000
    maxMBPS           4000
    DistributionType  Always

#### Step 1.
Create QOS Specs with the prerequisite values above
cinder qos-create <name> <key=value> [<key=value> ...]

    # cinder qos-create silver maxIOPS=4000 maxMBPS=4000 DistributionType=Always

#### Step 2.
Associate qos specs with specified volume type
cinder qos-associate <qos_specs id> <volume_type_id>

    # cinder qos-associate 07767ad8-6170-4c71-abce-99e68702f051 224b1517-4a23-44b5-9035-8d9e2c18fb70

#### Step 3.
Create volume with the volume type indicated above
cinder create [--name <name>]  [--volume-type <volume-type>] size

    # cinder create --name test_volume --volume-type 224b1517-4a23-44b5-9035-8d9e2c18fb70 1

#### Outcome - VMAX (Storage Group)
* Host I/O Limit (MB/Sec) - 	4000
* Host I/O Limit (IO/Sec) - 	4000
* Set Dynamic Distribution -	Always

#### Outcome - Cinder
Volume is created against volume type and QOS is enforced with the parameters above

###USE CASE 2 - LIMITS PRESET

Prerequisites - VMAX

* Host I/O Limit (MB/Sec) - 	2000
* Host I/O Limit (IO/Sec) - 	2000
* Set Dynamic Distribution -	Never

Prerequisites - Cinder Backend (Storage Group)

    Key               Value
    maxIOPS           4000
    maxMBPS           4000
    DistributionType  Always

#### Step 1.
Create QOS Specs with the prerequisite values above
cinder qos-create <name> <key=value> [<key=value> ...]

    # cinder qos-create silver maxIOPS=4000 maxMBPS=4000 DistributionType=Always

#### Step 2.
Associate qos specs with specified volume type
cinder qos-associate <qos_specs id> <volume_type_id>

    # cinder qos-associate 07767ad8-6170-4c71-abce-99e68702f051 224b1517-4a23-44b5-9035-8d9e2c18fb70

#### Step 3.
Create volume with the volume type indicated above
cinder create [--name <name>]  [--volume-type <volume-type>] size

    #cinder create --name test_volume --volume-type 224b1517-4a23-44b5-9035-8d9e2c18fb70 1

#### Outcome - VMAX (Storage Group)
* Host I/O Limit (MB/Sec) -	4000
* Host I/O Limit (IO/Sec) - 	4000
* Set Dynamic Distribution -	Always

#### Outcome - Cinder
Volume is created against volume type and QOS is enforced with the parameters above


### USE CASE 3 - LIMITS PRE-SETs
Prerequisites - VMAX

* Host I/O Limit (MB/Sec) - 	No Limit
* Host I/O Limit (IO/Sec) - 	No Limit
* Set Dynamic Distribution -	NA

Prerequisites - Cinder Backend (Storage Group)

    Key               Value
    DistributionType  Always

#### Step 1.
Create QOS Specs with the prerequisite values above
cinder qos-create <name> <key=value> [<key=value> ...]

    # cinder qos-create silver DistributionType=Always

#### Step 2.
Associate qos specs with specified volume type
cinder qos-associate <qos_specs id> <volume_type_id>

    # cinder qos-associate 07767ad8-6170-4c71-abce-99e68702f051 224b1517-4a23-44b5-9035-8d9e2c18fb70

#### Step 3.
Create volume with the volume type indicated above
cinder create [--name <name>]  [--volume-type <volume-type>] size

    # cinder create --name test_volume --volume-type 224b1517-4a23-44b5-9035-8d9e2c18fb70 1

#### Outcome - VMAX (Storage Group)
* Host I/O Limit (MB/Sec) - 	No Limit
* Host I/O Limit (IO/Sec) - 	No Limit
* Set Dynamic Distribution -	NA

#### Outcome - Cinder
Volume is created against volume type and there is no QOS change

### USE CASE 4 - LIMITS PRE-SETs
Prerequisites - VMAX

* Host I/O Limit (MB/Sec) - 	No Limit
* Host I/O Limit (IO/Sec) - 	No Limit
* Set Dynamic Distribution -	NA

Prerequisites - Cinder Backend (Storage Group)

    Key               Value
    DistributionType  Always

#### Step 1.
Create QOS Specs with the prerequisite values above
cinder qos-create <name> <key=value> [<key=value> ...]

    # cinder qos-create silver DistributionType=Always

#### Step 2.
Associate qos specs with specified volume type
cinder qos-associate <qos_specs id> <volume_type_id>

    # cinder qos-associate 07767ad8-6170-4c71-abce-99e68702f051 224b1517-4a23-44b5-9035-8d9e2c18fb70

#### Step 3.
Create volume with the volume type indicated above
cinder create [--name <name>]  [--volume-type <volume-type>] size

    # cinder create --name test_volume --volume-type 224b1517-4a23-44b5-9035-8d9e2c18fb70 1

#### Outcome - VMAX (Storage Group)
* Host I/O Limit (MB/Sec) - 	No Limit
* Host I/O Limit (IO/Sec) - 	No Limit
* Set Dynamic Distribution -	NA

#### Outcome - Cinder
Volume is created against volume type and there is no QOS change
