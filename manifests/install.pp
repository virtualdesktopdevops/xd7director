class xd7director::install inherits xd7director {
 
  #Install Citrix Director 
	dsc_xd7feature { 'XD7Director':
	  dsc_role => 'Director',
	  dsc_sourcepath => $sourcePath,
	  dsc_ensure => 'present'
	}

}