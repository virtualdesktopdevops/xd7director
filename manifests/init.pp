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
  $director_svc_username,
  $director_svc_password,
  $setup_svc_username,
  $setup_svc_password,
  $sourcePath,
  $deliveryControllers,
  $loadbalandedDirector = false,
  $loadbalancedDirectorFqdn = '',
  $https = false,
  $sslCertificateSourcePath = '',
  $sslCertificatePassword = '',
  $sslCertificateThumbprint = '',
  $caCertificateSourcePath = '',
  $caCertificateThumbprint = ''
)

{
  contain xd7director::install
  contain xd7director::serviceaccounts
  contain xd7director::config
  contain xd7director::sslconfig

  #Install Director & IIS before configuring the service account (IIS_IUSRS group needed in serviceaccounts.pp)
  Class['::xd7director::install'] ->
  Class['::xd7director::serviceaccounts'] ->
  Class['::xd7director::config'] ->
  Class['::xd7director::sslconfig']

  reboot { 'dsc_reboot':
    when    => pending,
    timeout => 15,
  }
}
