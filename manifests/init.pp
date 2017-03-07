class openresty {

        exec { 'yum-update':                    
                command => '/usr/bin/yum -y update'  
        }
        exec { 'development-tools':
                require => Exec['yum-update'],
                command => "/usr/bin/yum -y groupinstall 'Development Tools'",
        }
	    exec { 'prereq':
                require => Exec['development-tools'],
                command => '/usr/bin/yum -y install readline-devel pcre-devel openssl-devel gcc',
                    
        }

        file { "/usr/local/src/openresty-1.9.7.4.tar.gz":
                require => Exec['prereq'],
                ensure => present,
                mode => 0600,
                source => "puppet:///modules/openresty/openresty-1.9.7.4.tar.gz",
                before => Exec['unpack-tar'],
        }
        exec { 'unpack-tar':
                cwd => '/usr/local/src',
                command => '/bin/tar -zxf openresty-1.9.7.4.tar.gz',
        }
        exec { 'install-openresty':
             require => Exec['unpack-tar'],
	         user => 'root',
             cwd => '/usr/local/src/openresty-1.9.7.4',
	     path    => ['/usr/local/src/openresty-1.9.7.4','/usr/bin','/bin','/sbin'],
	     command => './configure --with-openssl=/usr/include/openssl  --with-pcre --with-pcre-jit --with-luajit --without-http_ssl_module,
                                
        } 	
	exec { 'make':
	     user => 'root',
             cwd => '/usr/local/src/openresty-1.9.7.4',
	     path => ['/usr/local/src/openresty-1.9.7.4','/usr/bin','/bin','/sbin'],
	     command => 'make',
	} 	exec { 'make-install':  
             user => 'root',
	     cwd => '/usr/local/src/openresty-1.9.7.4',
             path => ['/usr/local/src/openresty-1.9.7.4','/usr/bin','/bin','/sbin'],
             command => 'make install',
        }		
	file { '/etc/profile.d/append-nginx-path.sh':
    	    mode    => 644,
            content => 'PATH=/usr/local/openresty/nginx/sbin:$PATH',
	    before => Exec['run-nginx'],
        }
	exec { 'run-nginx':
	     require => Exec['make-install'],
	     cwd => '/usr/local/openresty/nginx',
	     path => ['/usr/bin','/bin','/sbin','/usr/local/openresty/nginx/sbin'],
	     command => 'nginx -p `pwd`/ -c conf/nginx.conf',
	}

}

