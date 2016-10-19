# VMAX Cinder Driver

Copyright (c) 2016 EMC Corporation.
All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0


# EMC VMAX FC and iSCSI drivers

## Overview
The EMC VMAX drivers, *EMCVMAXISCSIDriver* and *EMCVMAXFCDriver*, support
the use of EMC VMAX storage arrays with Block Storage. They both provide
equivalent functions and differ only in support for their respective host
attachment methods.

The drivers perform volume operations by communicating with the back-end VMAX
storage. It uses a CIM client in Python called *PyWBEM* to perform CIM
operations over HTTP.

The EMC CIM Object Manager (ECOM) is packaged with the EMC SMI-S provider. It
is a CIM server that enables CIM clients to perform CIM operations over HTTP by
using SMI-S in the back end for VMAX storage operations.

The EMC SMI-S Provider supports the SNIA Storage Management Initiative (SMI),
an ANSI standard for storage management. It supports the VMAX storage system.

## System requirements
The Cinder driver supports both VMAX-2 and VMAX-3 series.

For VMAX-2 series, SMI-S version V4.6.2.29 (Solutions Enabler 7.6.2.67)
or Solutions Enabler 8.1.2 is required.

For VMAX-3 series, Solutions Enabler 8.3 is required. This is SSL only.
Refer to section below *SSL support*.

When installing Solutions Enabler, make sure you explicitly add the SMI-S
component.

You can download SMI-S from the EMC's support web site (login is required).
See the EMC SMI-S Provider release notes for installation instructions.

Ensure that there is only one SMI-S (ECOM) server active on the same VMAX
array.

Support Matrix:

  Microcode      | Solutions Enabler | VMAX2               | VMAX3 Hybrid     | VMAX All Flash      |
  -------------  | :---------------: | :-----------------: | :--------------: | :----------------:  |
    5977.250.189 |  SE7.6.2.64       |   Yes               |  No              |   No                |
    5977.813.785 |  SE8.1.2          |   Yes               |  Yes             |   No                |
    5977.944.890 |  SE8.3.0.1        |   No                |  Yes             |   Yes               |


## Required VMAX software suites for OpenStack
There are five Software Suites available for the VMAX All Flash and Hybrid:

* Base Suite
* Advanced Suite
* Local Replication Suite
* Remote Replication Suite
* Total Productivity Pack

Openstack requires the Advanced Suite and the Local Replication Suite
or the Total Productivity Pack (it includes the Advanced Suite and the
Local Replication Suite) for the VMAX All Flash and Hybrid.

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

OpenStack requires TimeFinder for VMAX10K for the VMAX2.

Each are licensed separately. For further details on how to get the
relevant license(s), reference eLicensing Support below.

## eLicensing support
To activate your entitlements and obtain your VMAX license files, visit the
Service Center on [EMC support website](https://support.emc.com), as directed on your License
Authorization Code (LAC) letter emailed to you.

*  For help with missing or incorrect entitlements after activation
   (that is, expected functionality remains unavailable because it is not
   licensed), contact your EMC account representative or authorized reseller.

*  For help with any errors applying license files through Solutions Enabler,
   contact the EMC Customer Support Center.

*  If you are missing a LAC letter or require further instructions on
   activating your licenses through the Online Support site, contact EMC's
   worldwide Licensing team at *licensing@emc.com* or call:

   North America, Latin America, APJK, Australia, New Zealand: SVC4EMC
   (800-782-4362) and follow the voice prompts.

   EMEA: +353 (0) 21 4879862 and follow the voice prompts.

## OpenStack Release Support

This driver package supports the Juno and Kilo releases. Compared to previously released versions, enhancements include:
* Support for VMAX All Flash.
* Oversubscription
* Consistency Group
* iSCSI multipath 

## Supported Operations

*  Create, list, delete, attach, and detach volumes
*  Create, list, and delete volume snapshots
*  Copy an image to a volume
*  Copy a volume to an image
*  Clone a volume
*  Extend a volume
*  Retype a volume (Host assisted volume migration only)
*  Create a volume from a snapshot
*  Create and delete consistency group
*  Create and delete consistency group snapshot
*  Modify consistency group (add/remove volumes)
*  Create consistency group from source (source can only be a CG snapshot)

VMAX drivers also support the following features:

*  Dynamic masking view creation
*  Dynamic determination of the target iSCSI IP address
*  iSCSI multipath support

VMAX2:

*  FAST automated storage tiering policy
*  Striped volume creation

VMAX All Flash and Hybrid:

*  Service Level support
*  SnapVX support
*  All Flash support


## Setup VMAX drivers

### Install PyWBEM

Ubuntu14.04(LTS),Ubuntu16.04(LTS),Red Hat Enterprise Linux, CentOS and Fedora:

  PyWBEM version | Python2 pip     | Python2 Native      | Python3 pip      | Python3 Native      |
  -------------  | :-------------: | :-----------------: | :--------------: | :----------------:  |
    0.9.0        |  No             |   N/A               |  Yes             |   N/A               |
    0.8.4        |  No             |   N/A               |  Yes             |   N/A               |
    0.7.0        |  No             |   Yes               |  No              |   Yes               |

Note:
On Python2, use the updated distro version, for example:

      # apt-get install python-pywbem

Note:

     On Python3, use the official pywbem version (V0.9.0 or v0.8.4).


Install the *python-pywbem* package for your distributution.
* Install for Ubuntu:
    
      # apt-get install python-pywbem

* Install on openSUSE:
    
      # zypper install python-pywbem
            
* Install on Red Hat Enterprise Linuxm Centos, and Fedora:

      # yum install pywbem

Install iSCSI Utilities (iSCSI driver only).

Download and configure the Cinder node as an iSCSI initiator
Install the *open-iscsi* package.

* Install for Ubuntu:

      # apt-get install open-iscsi

* Install on openSUSE:

      # zypper install ope-iscsi

* Install on Red Hat Enterprise Linuxm Centos, and Fedora:

      # yum install scsi-target-utils.x86_64

Enable the iSCSI driver to start automatically.

Download Solutions Enabler with SMI-S from [EMC support website](https://support.emc.com) 
and install it. Add your VMAX arrays to SMI-S.

You can install SMI-S on a non-OpenStack host. Supported platforms include
different flavors of Windows, Red Hat, and SUSE Linux. SMI-S can be
installed on a physical server or a VM hosted by an ESX server. Note that
the supported hypervisor for a VM running SMI-S is ESX only. See the EMC
SMI-S Provider release notes for more information on supported platforms and
installation instructions.

Note:

      You must discover storage arrays on the SMI-S server before you can use
      the VMAX drivers. Follow instructions in the SMI-S release notes.

SMI-S is usually installed at */opt/emc/ECIM/ECOM/bin* on Linux and
*C:\Program Files\EMC\ECIM\ECOM\bin* on Windows. After you install and
configure SMI-S, go to that directory and type *TestSmiProvider.exe*
for windows and *./TestSmiProvider* for linux

Use *addsys* in *TestSmiProvider* to add an array. Use *dv* and
examine the output after the array is added. Make sure that the arrays are
recognized by the SMI-S server before using the EMC VMAX drivers.

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

VMAX2:

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

VMAX All Flash and Hybrid:

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
         <SLO>Gold</SLO>
         <Workload>OLTP</Workload>
       </EMC>


**EcomServerIp**
    IP address of the ECOM server which is packaged with SMI-S.

**EcomServerPort**
    Port number of the ECOM server which is packaged with SMI-S.

**EcomUserName** and **EcomPassword**
    Cedentials for the ECOM server.

**PortGroups**
    Supplies the names of VMAX port groups that have been pre-configured to
    expose volumes managed by this backend. Each supplied port group should
    have sufficient number and distribution of ports (across directors and
    switches) as to ensure adequate bandwidth and failure protection for the
    volume connections. PortGroups can contain one or more port groups of
    either iSCSI or FC ports. When a dynamic masking view is created by the
    VMAX driver, the port group is chosen randomly from the PortGroup list, to
    evenly distribute load across the set of groups provided. Make sure that
    the PortGroups set contains either all FC or all iSCSI port groups (for a
    given back end), as appropriate for the configured driver (iSCSI or FC).

**Array**
    Unique VMAX array serial number.

**Pool**
    Unique pool name within a given array. For back ends not using FAST
    automated tiering, the pool is a single pool that has been created by the
    administrator. For back ends exposing FAST policy automated tiering, the
    pool is the bind pool to be used with the FAST policy.

**FastPolicy**
    VMAX2 only. Name of the FAST Policy to be used. By including this tag,
    volumes managed by this back end are treated as under FAST control.
    Omitting the ``FastPolicy`` tag means FAST is not enabled on the provided
    storage pool.

**SLO**
    VMAX All Flash and Hybrid only. The Service Level Objective (SLO) that
    manages the underlying storage to provide expected performance. Omitting
    the ``SLO`` tag means that non FAST storage groups will be created instead
    (storage groups not associated with any service level).

**Workload**
    VMAX All Flash and Hybrid only. When a workload type is added, the latency
    range is reduced due to the added information. Omitting the ``Workload``
    tag means the latency range will be the widest for its SLO type.
  
 

### FC Zoning with VMAX
Zone Manager is required when there is a fabric between the host and array.
This is necessary for larger configurations where pre-zoning would be too
complex and open-zoning would raise security concerns.

### iSCSI with VMAX
*  Make sure the *iscsi-initiator-utils* package is installed on all Compute
   nodes.

Note:

    You can only ping the VMAX iSCSI target ports when there is a valid masking
    view. An attach operation creates this masking view.


## VMAX Masking View and Group Naming Info

### Masking View Names
Masking views are dynamically created by the VMAX FC and iSCSI drivers using
the following naming conventions. **[protocol]** is either **I** for volumes
attached over iSCSI or **F** for volumes attached over Fiber Channel.

VMAX2:

    OS-[shortHostName]-[poolName]-[protocol]-MV

VMAX2 (where FAST policy is used):

    OS-[shortHostName]-[fastPolicy]-[protocol]-MV

VMAX All Flash and Hybrid:

    OS-[shortHostName]-[SRP]-[SLO]-[workload]-[protocol]-MV

### Initiator Group Names
For each host that is attached to VMAX volumes using the drivers, an initiator
group is created or re-used (per attachment type). All initiators of the
appropriate type known for that host are included in the group. At each new
attach volume operation, the VMAX driver retrieves the initiators (either WWNNs
or IQNs) from OpenStack and adds or updates the contents of the Initiator Group
as required. Names are of the following format. **[protocol]** is either **I**
for volumes attached over iSCSI or **F** for volumes attached over Fiber
Channel.

    OS-[shortHostName]-[protocol]-IG

Note:

    Hosts attaching to OpenStack managed VMAX storage cannot also attach to
    storage on the same VMAX that are not managed by OpenStack.

### FA Port Groups 
VMAX array FA ports to be used in a new masking view are chosen from the list
provided in the EMC configuration file.

### Storage Group Names
As volumes are attached to a host, they are either added to an existing storage
group (if it exists) or a new storage group is created and the volume is then
added. Storage groups contain volumes created from a pool (either single-pool
or FAST-controlled), attached to a single host, over a single connection type
(iSCSI or FC). **[protocol]** is either **I** for volumes attached over iSCSI
or **F** for volumes attached over Fiber Channel.

VMAX2:

    OS-[shortHostName]-[poolName]-[protocol]-SG

VMAX2 (where FAST policy is used):

    OS-[shortHostName]-[fastPolicy]-[protocol]-SG

VMAX All Flash and Hybrid:

    OS-[shortHostName]-[SRP]-[SLO]-[Workload]-[protocol]-SG

## VMAX2 concatenated/Striped volumes
In order to support later expansion of created volumes, the VMAX Block Storage
drivers create concatenated volumes as the default layout. If later expansion
is not required, users can opt to create striped volumes in order to optimize
I/O performance.

Below is an example of how to create striped volumes. First, create a volume
type. Then define the extra spec for the volume type
*storagetype:stripecount* representing the number of meta members in the
striped volume. The example below means that each volume created under the
*GoldStriped* volume type will be striped and made up of 4 meta members.  

        # cinder type-create GoldStriped
        # cinder type-key GoldStriped set volume_backend_name=GOLD_BACKEND
        # cinder type-key GoldStriped set storagetype:stripecount=4

## SSL support
Note:

    The ECOM component in Solutions Enabler enforces SSL in 8.3.
    By default, this port is 5989.

1. Get the CA certificate of the ECOM server. This pulls the CA cert file and
   saves it as .pem file. *my_ecom_host* is the ip address or hostname of the
   ECOM server. *ca_cert.pem* is the sample name of the .pem:

        # openssl s_client -showcerts -connect my_ecom_host:5989 </dev/null 2>/dev/null|openssl x509 -outform PEM >ca_cert.pem

2.  Copy the pem file to the system certificate directory:

        # cp cp ca_cert.pem /usr/share/ca-certificates/ca_cert.crt

3. Update CA certificate database with the following commands:

        # dpkg-reconfigure ca-certificates

Note:

        Check that the new *ca_cert.crt* is going to be activiated by selecting
        *ask* on the dialog. If it is not enabled for activation, down/up
        key to select and space key to enable/disable.

        # sudo update-ca-certificates

4. Update */etc/cinder/cinder.conf* to reflect SSL functionality by
   adding the following to the back end block. *my_location* is the location
   of the .pem file generated in step 1.:

        driver_ssl_cert_verify = False
        driver_use_ssl = True

   If step 2 and 3 are skipped you must add the location of you .pem file.

        driver_ssl_cert_verify = False
        driver_use_ssl = True
        driver_ssl_cert_path = /my_location/ca_cert.pem

5.  Update EcomServerIp to ECOM host name and EcomServerPort to secure port
    (5989 by default) in */etc/cinder/cinder_emc_config_<conf_group>.xml*.

## iSCSI multipathing support

* Install open-iscsi on all nodes on your system
* Do not install EMC PowerPath as they cannot co-exist with native multipath
  software
* Multipath tools must be installed on all nova compute nodes

On Ubuntu:

        # apt-get install open-iscsi           #ensure iSCSI is installed
        # apt-get install multipath-tools      #multipath modules
        # apt-get install sysfsutils sg3-utils #file system utilities
        # apt-get install scsitools            #SCSI tools

On openSUSE and SUSE Linux Enterprise Server:

        # zipper install open-iscsi           #ensure iSCSI is installed
        # zipper install multipath-tools      #multipath modules
        # zipper install sysfsutils sg3-utils #file system utilities
        # zipper install scsitools            #SCSI tools

On Red Hat Enterprise Linux and CentOS:

        # yum install iscsi-initiator-utils   #ensure iSCSI is installed
        # yum install device-mapper-multipath #multipath modules
        # yum install sysfsutils sg3-utils    #file system utilities
        # yum install scsitools               #SCSI tools

### Multipath configuration file

The multipath configuration file may be edited for better management and
performance. Log in as a privileged user and make the following changes to
*/etc/multipath.conf* on the  Compute (nova) node(s).


        devices {
        # Device attributed for EMC VMAX
             device {
                    vendor "EMC"
                    product "SYMMETRIX"
                    path_grouping_policy multibus
                    getuid_callout "/lib/udev/scsi_id --page=pre-spc3-83 --whitelisted --device=/dev/%n"
                    path_selector "round-robin 0"
                    path_checker tur
                    features "0"
                    hardware_handler "0"
                    prio const
                    rr_weight uniform
                    no_path_retry 6
                    rr_min_io 1000
                    rr_min_io_rq 1
            }
        } 

You may need to reboot the host after installing the MPIO tools or restart
iSCSI and multipath services.

On Ubuntu:

        # service open-iscsi restart
        # service multipath-tools restart

On On openSUSE, SUSE Linux Enterprise Server, Red Hat Enterprise Linux, and
CentOS:

        # systemctl restart open-iscsi
        # systemctl restart multipath-tools


        $ lsblk
        NAME                                       MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
        sda                                          8:0    0     1G  0 disk
        ..360000970000196701868533030303235 (dm-6) 252:6    0     1G  0 mpath
        sdb                                          8:16   0     1G  0 disk
        ..360000970000196701868533030303235 (dm-6) 252:6    0     1G  0 mpath
        vda                                        253:0    0     1T  0 disk

### OpenStack configurations

On Compute (nova) node, add the following flag in the *[libvirt]* section of
*/etc/nova/nova.conf*:

        iscsi_use_multipath = True

On cinder controller node, set the multipath flag to true in
*/etc/cinder.conf*:

        use_multipath_for_image_xfer = True

Restart *nova-compute* and *cinder-volume* services after the change.

### Verify you have multiple initiators available on the compute node for I/O

* Create a 3GB VMAX volume.
* Create an instance from image out of native LVM storage or from VMAX
  storage, for example, from a bootable volume
* Attach the 3GB volume to the new instance:

         # multipath -ll
         mpath102 (360000970000196700531533030383039) dm-3 EMC,SYMMETRIX
         size=3G features='1 queue_if_no_path' hwhandler='0' wp=rw
         '-+- policy='round-robin 0' prio=1 status=active
         33:0:0:1 sdb 8:16 active ready running
         '- 34:0:0:1 sdc 8:32 active ready running

* Use the *lsblk* command to see the multipath device:

         # lsblk
         NAME                                       MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
         sdb                                          8:0    0     3G  0 disk
         ..360000970000196700531533030383039 (dm-6) 252:6    0     3G  0 mpath
         sdc                                          8:16   0     3G  0 disk
         ..360000970000196700531533030383039 (dm-6) 252:6    0     3G  0 mpath
         vda

## Consistency group support

Consistency Groups operations are performed through the CLI using v2 of
the cinder API.

*/etc/cinder/policy.json* may need to be updated to enable new API calls
for Consistency groups.

Note:
   Even though the terminology is 'Consistency Group' in OpenStack, a Storage
   Group is created on the VMAX, and should not be confused with a VMAX
   Consistency Group which is an SRDF construct. The Storage Group is not
   associated with any FAST policy.

### Operations

* Create a Consistency Group:

      cinder --os-volume-api-version 2 consisgroup-create [--name <name>]
      [--description <description>] [--availability-zone <availability-zone>]
      <volume-types>

          # cinder --os-volume-api-version 2 consisgroup-create --name bronzeCG2 volume_type_1

* List Consistency Groups:

      cinder consisgroup-list [--all-tenants [<0|1>]]

          # cinder consisgroup-list

* Show a Consistency Group:

      cinder consisgroup-show <consistencygroup>

          # cinder consisgroup-show 38a604b7-06eb-4202-8651-dbf2610a0827

* Update a consistency Group:

      cinder consisgroup-update [--name <name>] [--description <description>]
      [--add-volumes <uuid1,uuid2,......>] [--remove-volumes <uuid3,uuid4,......>]
      <consistencygroup>

      Change name:

          # cinder consisgroup-update --name updated_name 38a604b7-06eb-4202-8651-dbf2610a0827

      Add volume(s) to a Consistency Group:

          # cinder consisgroup-update --add-volumes af1ae89b-564b-4c7f-92d9-c54a2243a5fe 38a604b7-06eb-4202-8651-dbf2610a0827

      Delete volume(s) from a Consistency Group:

          # cinder consisgroup-update --remove-volumes af1ae89b-564b-4c7f-92d9-c54a2243a5fe 38a604b7-06eb-4202-8651-dbf2610a0827

* Create a snapshot of a Consistency Group:

      cinder cgsnapshot-create [--name <name>] [--description <description>]
      <consistencygroup>

          # cinder cgsnapshot-create 618d962d-2917-4cca-a3ee-9699373e6625

* Delete a snapshot of a Consistency Group:

      cinder cgsnapshot-delete <cgsnapshot> [<cgsnapshot> ...]

          # cinder cgsnapshot-delete 618d962d-2917-4cca-a3ee-9699373e6625

* Delete a Consistency Group:

      cinder consisgroup-delete [--force] <consistencygroup> [<consistencygroup> ...]

          # cinder consisgroup-delete --force 618d962d-2917-4cca-a3ee-9699373e6625

* You can also create a volume in a consistency group in one step:

      cinder create [--consisgroup-id <consistencygroup-id>] [--name <name>]
      [--description <description>] [--volume-type <volume-type>]
      [--availability-zone <availability-zone>] <size>

          # cinder create --volume-type volume_type_1 --name cgBronzeVol --consisgroup-id 1de80c27-3b2f-47a6-91a7-e867cbe36462 1

## Workload Planner (WLP)

VMAX Hybrid allows you to manage application storage by using Service Level
Objectives (SLO) using policy based automation rather than the tiering in the
VMAX2. The VMAX Hybrid comes with up to 6 SLO policies defined. Each has a
set of workload characteristics that determine the drive types and mixes
which will be used for the SLO. All storage in the VMAX Array is virtually
provisioned, and all of the pools are created in containers called Storage
Resource Pools (SRP). Typically there is only one SRP, however there can be
more. Therefore, it is the same pool we will provision to but we can provide
different SLO/Workload combinations.

The SLO capacity is retrieved by interfacing with Unisphere Workload Planner
(WLP). If you do not set up this relationship then the capacity retrieved is
that of the entire SRP. This can cause issues as it can never be an accurate
representation of what storage is available for any given SLO and Workload
combination.

### Enabling WLP on Unisphere

1. To enable WLP on Unisphere, click on the
   *array-->Performance-->Settings*.
2. Set both the *Real Time* and the *Root Cause Analysis*.
3. Click *Register*.

Note:
   This should be set up ahead of time (allowing for several hours of data
   collection), so that the Unisphere for VMAX Performance Analyzer can
   collect rated metrics for each of the supported element types.

### Using TestSmiProvider to add statistics access point

After enabling WLP you must then enable SMI-S to gain access to the WLP data:

1. Connect to the SMI-S Provider using TestSmiProvider.
2. Navigate to the *Active* menu.
3. Type *reg* and enter the noted responses to the questions:

           (EMCProvider:5989) ? reg
           Current list of statistics Access Points: ?
           Note: The current list will be empty if there are no existing Access Points.
           Add Statistics Access Point {y|n} [n]: y
           HostID [l2se0060.lss.emc.com]: ?
           Note: Enter the Unisphere for VMAX location using a fully qualified Host ID.
           Port [8443]: ?
           Note: The Port default is the Unisphere for VMAX default secure port. If the secure port
           is different for your Unisphere for VMAX setup, adjust this value accordingly.
           User [smc]: ?
           Note: Enter the Unisphere for VMAX username.
           Password [smc]: ?
           Note: Enter the Unisphere for VMAX password.

4. Type *reg* again to view the current list:

           (EMCProvider:5988) ? reg
           Current list of statistics Access Points:
           HostIDs:
           l2se0060.lss.emc.com
           PortNumbers:
           8443
           Users:
           smc
           Add Statistics Access Point {y|n} [n]: n
