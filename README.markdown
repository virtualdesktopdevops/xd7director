# xd7director #

This modules install a Citrix 7.x Director, which provides citrix deployment monitoring capabilities, and links it to the XenApp/XenDesktop site Delivery Controllers.
It configures Director for Kerberos SSO login, enhancing security level and speeding access to the monitoring interface.

Director can be deployed reduncdantly with load-balancing capabilities in front of two Director nodes.

The following options are available for a production-grade installation :
- Security : IIS SSL configuration to secure communications between Director and the client device.
- Resiliency : Deployment of a Director pool in a load-balanced environment with SPN setup and Kerberos SSO capability.

## Requirements ##

The minimum Windows Management Framework (PowerShell) version required is 5.0 or higher, which ships with Windows 10 or Windows Server 2016, but can also be installed on Windows 7 SP1, Windows 8.1, Windows Server 2008 R2 SP1, Windows Server 2012 and Windows Server 2012 R2.

This module requires a custom version of the puppetlabs-dsc module compiled with [XenDesktop7](https://github.com/VirtualEngine/XenDesktop7) Powershell DSC resource as a dependency. Ready to use virtualdesktopdevops/dsc v1.5.0 puppet module provided on [Puppet Forge](https://forge.puppet.com/virtualdesktopdevops/dsc).

## Change log ##

A full list of changes in each version can be found in the [change log](CHANGELOG.md).


## Integration informations ##
Citrix Director runs with service account to improve security and allow the deployment of multiple Director instances (Director Pool) configured for Kerberos SSO login behind a load-balancer.
All the Director nodes in a Director Pool must have their Director IIS ApplicationPool be configured with the same service account and the same SPN.

The module can be installed on a Standard, Datacenter version of Windows 2012R2 or Windows 2016. **Core version is not supported by Citrix for Director installation**.

Migrated puppet example code in README.md to future parser syntax (4.x). Impact on parameters refering to remote locations (file shares) which have to be prefixed with \\\\ instead of the classical \\. This is because of Puppet >= 4.x parsing \\ as a single \ in single-quoted strings. Use parser = future in puppet 3.x /etc/puppet/puppet.conf to use this new configuration in your Puppet 3.x and prepare Puppet 4.x migration.

## Usage ##
### xd7director ###
This class will install and configure IIS and Citrix Director.
- **`[String]` director_svc_username** _(Required)_: Director service account (on which Director IIS ApplicationPool will run). Use **username** format. **DO NOT** use DOMAIN\username format.
- **`[String]` director_svc_password** _(Required)_: Password of the Director service account. Should be encrypted with hiera-eyaml.
- **`[String]` setup_svc_username** _(Required)_: Privileged account used by Puppet for installing the software.
- **`[String]` setup_svc_password** _(Required)_: Password of the privileged account. Should be encrypted with hiera-eyaml.
- **`[String]` sourcepath** _(Required)_: Path of a folder containing the Xendesktop 7.x installer (unarchive the ISO image in this folder).
- **`[String]` deliverycontrollers** _(Required)_: List of Citrix Delivery Controllers of the XenDesktop7 site 'srv-cxdc01.domain.net, srv-cxdc012.domain.net'
- **`[Boolean]` loadbalandeddirector** _(Optional, default is false)_: Is Director deployed behind a load-balancer ? Default : false
- **`[String]` loadbalanceddirectorfqdn** _(Required, if loadbalandeddirector = true)_: FQDN of the Director pool associated to the virtual server IP configured on the loadbalancer
- **`[Boolean]` https** _(Optional, default is false)_: Deploy SSL certificate on IIS and activate SSL access to Storefront ? Default : false
- **`[String]` sslcertificatesourcepath** _(Required if https = true)_: Location of the SSL certificate (p12 / PFX format with private key). Can be local folder, UNC path, HTTP URL)
- **`[String]` sslcertificatepassword** _(Required if https = true)_: Password protecting the p12/pfx SSL certificate file.
- **`[String]` sslcertificatethumbprint** _(Required if https = true)_: Thumbprint of the SSL certificate (available in the SSL certificate).
- **`[String]` cacertificatesourcepath** _(Required if https = true)_: Location of the SSL Certification Autority root certificate (PEM or CER format). Can be local folder, UNC path, HTTP URL)
- **`[String]` cacertificatethumbprint** _(Required if https = true)_: Thumbprint of the SSL Certification Autority root certificate (available in the SSL certificate).

~~~puppet
node 'director' {
  class{'xd7director':
    director_svc_username    => 'svc-director',
    director_svc_password    => 'P@ssw0rd',
    setup_svc_username       => 'TESTLAB\svc-puppet',
    setup_svc_password       => 'P@ssw0rd',
    sourcepath               => '\\\\fileserver\\xendesktop715',
    deliverycontrollers      => 'srv-cxdc01.testlab.com, srv-cxdc02.testlab.com',
    loadbalandeddirector     => true,
    loadbalanceddirectorfqdn => 'director.testlab.com',
    https                    => true,
    sslcertificatesourcepath => '\\\\fileserver\\ssl\\cxdirector.pfx',
    sslcertificatepassword   => 'P@ssw0rd',
    sslcertificatethumbprint => '44cce73845feef4da4d369a37386c862eb3bd4e1',
    cacertificatesourcepath  => '\\\\fileserver\\ssl\\ca-root.pem',
    cacertificatethumbprint  => '48jise7dssdsd4da4d369a3738dsdsdeeb3sdiu3'
  }
}
~~~
