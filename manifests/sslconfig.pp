#Class configuring SSL secured access to Citrix Director
class xd7director::sslconfig inherits xd7director {
  if $xd7director::https {
    if ($xd7director::cacertificatesourcepath != '') {
      #Import and install CA certificate in LocalMachine Root store
      dsc_file{ 'CACert':
        dsc_sourcepath      => $xd7director::cacertificatesourcepath,
        dsc_destinationpath => 'c:\SSL\ca.pem',
        dsc_type            => 'File'
      }

      dsc_xcertificateimport{ 'ImportCACert':
        dsc_thumbprint => $xd7director::cacertificatethumbprint,
        dsc_path       => 'c:\SSL\ca.pem',
        dsc_location   => 'LocalMachine',
        dsc_store      => 'Root',
        require        => Dsc_file['CACert']
      }
    }

    #Import and install server certificate
    dsc_file{ 'SSLCert':
      dsc_sourcepath      => $xd7director::sslcertificatesourcepath,
      dsc_destinationpath => 'c:\SSL\cert.pfx',
      dsc_type            => 'File'
    }

    dsc_xpfximport{ 'ImportSSLCert':
      dsc_thumbprint => $xd7director::sslcertificatethumbprint,
      dsc_path       => 'c:\SSL\cert.pfx',
      dsc_location   => 'LocalMachine',
      dsc_store      => 'WebHosting',
      dsc_credential => {'user' => 'cert', 'password' => $xd7director::sslcertificatepassword },
      require        => Dsc_file['SSLCert']
    }


    dsc_xwebsite{ 'DefaultWebSiteSSL':
      dsc_name        => 'Default Web Site',
      dsc_bindinginfo => [
        { protocol              => 'https',
          port                  => '443',
          certificatethumbprint => $xd7director::sslcertificatethumbprint,
          certificatestorename  => 'WebHosting' }
        ],
      require         => Dsc_xpfximport['ImportSSLCert']
    }

  }
  else {
    dsc_xwebsite{ 'DefaultWebSite':
      dsc_name        => 'Default Web Site',
      dsc_bindinginfo => [
        { protocol => 'http',
          port     => '80'}
      ],
    }
  }
}
