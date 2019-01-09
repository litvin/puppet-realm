class realm::ad(
	String $domain_name	= $::realm::domain_name,
	String $host_ad_name	= $::realm::host_ad_name,
	String $admin   	= $::realm::admin,
	String $admin_passwd	= $::realm::admin_passwd,
){
        package { "fly-admin-ad-client":
    	                ensure   => present 
		}
	
        exec { 'realm AD':
  	  path    => '/usr/bin:/usr/sbin:/bin',
 	  command => "/usr/bin/astra-winbind -dc $host_ad_name -d $domain_name -g AM -n 10.44.0.1 -u $admin -p $admin_passwd -y ",
  	  unless  => "astra-winbind -i | grep succeeded",
	     }
}	

