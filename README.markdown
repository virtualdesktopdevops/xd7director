# xd7director #

This modules install a Citrix 7.x Director, which provides citrix deployment monitoring capabilities, and links it to the XenApp/XenDesktop site Delivery Controllers.
It configures Director for Kerberos SSO login, enhancing security level and speeding access to the monitoring interface.

Director can be deployed reduncdantly with load-balancing capabilities in front of two Director nodes.

The following options are available for a production-grade installation :
- Security : IIS SSL configuration to secure communications between Director and the client device.
- Resiliency : Deployment of a Director pool in a load-balanced environment with SPN setup and Kerberos SSO capability.



## Integration informations
Director runs with service account to improve security and allow the deployment of multiple Director instances (Director Pool) configured for Kerberos SSO login behind a load-balancer.
All the Director nodes in a Director Pool must have their Director IIS ApplicationPool be configured with the same service account and the same SPN.

The module can be installed on a Standard, Datacenter version of Windows 2012R2 or Windows 2016. **Core version is not supported by Citrix for Director installation**.

Migrated puppet example code in README.md to future parser syntax (4.x). Impact on parameters refering to remote locations (file shares) which have to be prefixed with \\\\ instead of the classical \\. This is because of Puppet >= 4.x parsing \\ as a single \ in single-quoted strings. Use parser = future in puppet 3.x /etc/puppet/puppet.conf to use this new configuration in your Puppet 3.x and prepare Puppet 4.x migration.

## Usage
### xd7director
This class will install and configure IIS and Citrix Director.
- **director_svc_username** : (string format username) : Director service account (on which Director IIS ApplicationPool will run). Use **username** format. **DO NOT** use DOMAIN\username format.
- **director_svc_password** : Password of the Director service account. Should be encrypted with hiera-eyaml.
- **setup_svc_username** : (string) Privileged account used by Puppet for installing the software.
- **setup_svc_password** : (string) Password of the privileged account. Should be encrypted with hiera-eyaml.
- **sourcePath** : (string) Path of a folder containing the Xendesktop 7.x installer (unarchive the ISO image in this folder).
- **deliveryControllers** : (String) List of Citrix Delivery Controllers of the XenDesktop7 site 'srv-cxdc01.domain.net, srv-cxdc012.domain.net'
- **loadbalandedDirector** : true or false. Is Director deployed behind a load-balancer ? Default : false
- **loadbalancedDirectorFqdn** (string)(optionnal) FQDN of the Director pool associated to the virtual server IP configured on the loadbalancer
- **https** : (boolean) : true or false. Deploy SSL certificate on IIS and activate SSL access to Storefront ? Default : false
- **sslCertificateSourcePath** : (string) Location of the SSL certificate (p12 / PFX format with private key). Can be local folder, UNC path, HTTP URL)
- **sslCertificatePassword** : (string) Password protecting the p12/pfx SSL certificate file.
- **sslCertificateThumbprint** : (string) Thumbprint of the SSL certificate (available in the SSL certificate).
- **caCertificateSourcePath** : (string) Location of the SSL Certification Autority root certificate (PEM or CER format). Can be local folder, UNC path, HTTP URL)
- **caCertificateThumbprint** : (string) Thumbprint of the SSL Certification Autority root certificate (available in the SSL certificate).

~~~puppet
node 'director' {
	class{'xd7director':
	  director_svc_username => 'svc-director',
	  director_svc_password => 'P@ssw0rd',
	  setup_svc_username => 'TESTLAB\svc-puppet',
	  setup_svc_password => 'P@ssw0rd',
	  sourcepath => '\\\\fileserver\\xendesktop715',
	  deliverycontrollers => 'srv-cxdc01.testlab.com, srv-cxdc02.testlab.com',
	  domainName => 'TESTLAB.COM',
	  domainNetbiosName=> 'TESTLAB',
	  loadbalandedDirector => true,
	  loadbalancedDirectorFqdn => 'director.testlab.com',
	  https => true,
	  sslCertificateSourcePath => '\\\\fileserver\\ssl\\cxdirector.pfx',
	  sslCertificatePassword => 'P@ssw0rd',
	  sslCertificateThumbprint => '44cce73845feef4da4d369a37386c862eb3bd4e1',
	  caCertificateSourcePath => '\\\\fileserver\\ssl\\ca-root.pem',
	  caCertificateThumbprint => '48jise7dssdsd4da4d369a3738dsdsdeeb3sdiu3'
	}
}
~~~
