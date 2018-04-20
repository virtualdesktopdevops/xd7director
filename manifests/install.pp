#Class installing Citrix Director
class xd7director::install inherits xd7director {

  #Install Citrix Director
  dsc_xd7feature { 'XD7Director':
    dsc_role       => 'Director',
    dsc_sourcepath => $xd7director::sourcepath,
    dsc_ensure     => 'present'
  }

}
