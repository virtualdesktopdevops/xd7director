# Class: xd7director
#
# This module manages xd7director
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class xd7director (
  String $director_svc_username,
  String $director_svc_password,
  String $setup_svc_username,
  String $setup_svc_password,
  String $sourcepath,
  String $deliverycontrollers,
  Optional[Boolean] $loadbalandeddirector    = false,
  Optional[String] $loadbalanceddirectorfqdn = '',
  Optional[Boolean] $https                   = false,
  Optional[String] $sslcertificatesourcepath = '',
  Optional[String] $sslcertificatepassword   = '',
  Optional[String] $sslcertificatethumbprint = '',
  Optional[String] $cacertificatesourcepath  = '',
  Optional[String] $cacertificatethumbprint  = ''
)

{
  contain xd7director::install
  contain xd7director::serviceaccounts
  contain xd7director::config
  contain xd7director::sslconfig

  #Install Director & IIS before configuring the service account (IIS_IUSRS group needed in serviceaccounts.pp)
  Class['::xd7director::install']
->Class['::xd7director::serviceaccounts']
->Class['::xd7director::config']
->Class['::xd7director::sslconfig']

  reboot { 'dsc_reboot':
    when    => pending,
    timeout => 15,
  }
}
