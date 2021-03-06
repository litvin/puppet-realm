class realm::ad(
	String $domain_name	    = $::realm::domain_name,
	String $host_ad_name	    = $::realm::host_ad_name,
	String $admin   	    = $::realm::admin,
	String $admin_passwd	    = $::realm::admin_passwd,
	Array[String] $package_name = $::realm::package_name,
	
){
case $::osfamily {
    'Debian': {
        	package { "fly-admin-ad-client":
    	                ensure   => present 
		}
	
        	exec { 'realm AD Debian':
  	  		path    => '/usr/bin:/usr/sbin:/bin',
 	  		command => "/usr/bin/astra-winbind -dc $host_ad_name -d $domain_name -g AM -n 10.44.0.1 -u $admin -p $admin_passwd -y ",
  	  		unless  => "astra-winbind -i | grep succeeded",
	   	     }
	      }
    'Redhat': {
		$package_name.each | $index, $value | {
       			package { "$value":
    	                ensure   => 'present' 
	  		}
		}
# 		file { "/etc/samba/smb.conf":
#	 	        ensure => file,
#		        owner  => 0,
#		        group  => 0,
#	                mode   => "644",
#		        content => template("$module_name/redos.smb.conf.erb"),
#	        }
       		exec { 'realm AD Redhat':
  			path    => '/usr/bin:/usr/sbin:/bin',
 			command => "echo '$admin_passwd' |  /usr/sbin/realm join -U $admin  $domain_name",
  			unless  => "/usr/sbin/realm discover $domain_name | grep configured | grep kerberos-member",
	   	}
 		file { "/etc/sssd/sssd.conf":  
		        ensure  => file,
                        owner  => 0,
                        group  => 0,
                        mode   => "600",
 			content =>  template("$module_name/redos.sssd.conf.erb"), 
	        }
                file { "/etc/krb5.conf":
                       ensure => file,
                       owner  => 0,
                       group  => 0,
                       mode   => "644",
                       content => template("$module_name/redos.krb5.conf.erb"),
                }
       		exec { 'eanble mkhomedir Redhat':
  			path    => '/usr/bin:/usr/sbin:/bin',
 			command => "authconfig --enablemkhomedir --updateall",
			unless  => "authselect current | grep with-mkhomedir"
#  			unless  => "authconfig --test | grep mkhomedir | grep enabled",
	   	}

       		exec { 'enable sssdauth Redhat':
  			path    => '/usr/bin:/usr/sbin:/bin',
			command => "systemctl enable sssd ",
			unless  => "systemctl status sssd | grep enable",
	   	}

        	service { 'sssd.service':
			ensure     => 'running',
			hasstatus  => 'true',
			hasrestart => 'true',
			}
	    }
      }
}	

