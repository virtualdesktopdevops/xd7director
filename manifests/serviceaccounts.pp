class xd7director::serviceaccounts inherits xd7director {
  #Needed for ActiveDirectory remote management using Powershell
	dsc_windowsfeature{ 'RSAT-AD-Powershell':
	 dsc_ensure => 'Present',
	 dsc_name => 'RSAT-AD-Powershell'
	}

	#Director service account creation (Active Directory)
	dsc_xaduser{'SvcDirectorAccount':
		dsc_domainname => $domain,
		dsc_domainadministratorcredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password},
		dsc_username => $director_svc_username,
		dsc_password => {'user' => $director_svc_username, 'password' => $director_svc_password},
		dsc_ensure => 'Present',
		require => Dsc_windowsfeature['RSAT-AD-Powershell']
	}

	#Configure SPN on Director service account
	#In A load-balanced deployment, the SPN is linked to the FQDN of the Director virtual server configured on the load-balancer
	if $loadbalandedDirector {
		dsc_xadserviceprincipalname{'DirectorLoadBalancedSPN':
	    dsc_account => $director_svc_username,
	    dsc_serviceprincipalname => "http/${loadbalancedDirectorFqdn}",
		  dsc_ensure => present,
		  dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password},
      require => Dsc_xaduser['SvcDirectorAccount']
		}
	}
	#In a standalone deployment, the SPN is linked to the computer FQDN
	else {
	  dsc_xadserviceprincipalname{'DirectorStandaloneSPN':
      dsc_account => $director_svc_username,
      dsc_serviceprincipalname => "http/${fqdn}",
      dsc_ensure => present,
      dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password},
      require => Dsc_xaduser['SvcDirectorAccount']
    }
	}

	#Add service accounts to local admins IIS_IUSRS group (local machine)
	dsc_xgroup{'SvcDirectorIISGroup':
		dsc_groupname => 'IIS_IUSRS',
		dsc_ensure => 'Present',
		dsc_memberstoinclude => "${domainnetbiosname}\\$director_svc_username",
		#dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password},
		require => Dsc_xaduser['SvcDirectorAccount']
	}

	#Grant "Log on as a batch job" and  "Impersonate a client after authentication" to Director service account
	dsc_userrightsassignment{'AssignLogOnAsBatchToDirector':
    dsc_policy => 'Log_on_as_a_batch_job',
    dsc_identity => ["${domainnetbiosname}\\$director_svc_username", 'Administrators', 'Backup Operators', 'Performance Log Users'],
    require => Dsc_xaduser['SvcDirectorAccount']
  }

  dsc_userrightsassignment{'AssignImpersonateAfterAuthenticationToDirector':
    dsc_policy => 'Impersonate_a_client_after_authentication',
    dsc_identity => ["${domainnetbiosname}\\$director_svc_username", 'Administrators', 'Local Service', 'Network Service', 'Service'],
    require => Dsc_xaduser['SvcDirectorAccount']
  }

}
