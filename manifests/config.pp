class xd7director::config inherits xd7director {
   
  #Pairing Director to Delivery Controllers
  dsc_xwebconfigkeyvalue{ 'ServiceAutoDiscovery':
      dsc_configsection => 'AppSettings',
      dsc_key => 'Service.AutoDiscoveryAddresses',
      dsc_value => $deliveryControllers,
      dsc_isattribute => false,
      dsc_websitepath => 'IIS:\Sites\Default Web Site\Director'
  }
  
  #Configue Director ApplicationPool service account
	dsc_xwebapppool{'DirectorAppPool':
		dsc_name => 'Director',
		dsc_ensure => 'Present',
		dsc_autostart => true,
		dsc_enable32bitapponwin64 => false,
		dsc_managedruntimeversion => 'v4.0',
		dsc_managedpipelinemode => 'Integrated',
		dsc_disallowoverlappingrotation    => true,
		dsc_disallowrotationonconfigchange => true,
		dsc_restartschedule => ['00:00:00'],
		dsc_identitytype => 'SpecificUser',
		dsc_credential => {'user' => "${domainNetbiosName}\\${director_svc_username}", 'password' => $director_svc_password},
		dsc_state => 'Started',
	}
  
  #Changing authentication mode to use ApplicationPool
  dsc_script{ 'DirectorUseAppPoolCredentials':
		dsc_getscript =>  '$useAppPoolCredentials = Get-WebConfigurationProperty -pspath \'MACHINE/WEBROOT/APPHOST\' -location \'Default Web Site/Director\' -filter \'system.webServer/security/authentication/windowsAuthentication\' -name \'useAppPoolCredentials\'
		  return @{ Result = $useAppPoolCredentials.Value }',
  	dsc_testscript => '$useAppPoolCredentials = Get-WebConfigurationProperty -pspath \'MACHINE/WEBROOT/APPHOST\' -location \'Default Web Site/Director\' -filter \'system.webServer/security/authentication/windowsAuthentication\' -name \'useAppPoolCredentials\'
		  return (\'true\' -eq $useAppPoolCredentials.Value)',
		dsc_setscript => 'Set-WebConfigurationProperty -pspath \'MACHINE/WEBROOT/APPHOST\' -location \'Default Web Site/Director\' -filter \'system.webServer/security/authentication/windowsAuthentication\' -name \'useAppPoolCredentials\' -value \'true\''
  }

  #Disable kernel mode authentication
  dsc_script{ 'DirectorDisableKernelMode':
    dsc_getscript =>  '$useKernelMode = Get-WebConfigurationProperty -pspath \'MACHINE/WEBROOT/APPHOST\' -location \'Default Web Site/Director\' -filter \'system.webServer/security/authentication/windowsAuthentication\' -name \'useKernelMode\'
      return @{ Result = $useKernelMode.Value }',
    dsc_testscript => '$useKernelMode = Get-WebConfigurationProperty -pspath \'MACHINE/WEBROOT/APPHOST\' -location \'Default Web Site/Director\' -filter \'system.webServer/security/authentication/windowsAuthentication\' -name \'useKernelMode\'
      return (\'false\' -eq $useKernelMode.Value)',
    dsc_setscript => 'Set-WebConfigurationProperty -pspath \'MACHINE/WEBROOT/APPHOST\' -location \'Default Web Site/Director\' -filter \'system.webServer/security/authentication/windowsAuthentication\' -name \'useKernelMode\' -value \'false\''
  } 
  
  #Redirect from default IIS page to Director
  if $https {
    file{'c:/inetpub/wwwroot/index.html':
      ensure  => file,
      content => template('xd7director/director_https.erb')  
    }
  }
  else {
    file{'c:/inetpub/wwwroot/index.html':
      ensure  => file,
      content => template('xd7director/director_http.erb')  
    }
  } 
  
  
}