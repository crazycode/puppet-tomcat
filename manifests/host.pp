/*

== Definition: tomcat::host

This definition will create an host in a dedicated file
included in server.xml with an XML entity inclusion.Have a
look at http://tomcat.apache.org/tomcat-6.0-doc/config/host.html
for more details.

Parameters:
- *name*: the filename prefix
- *ensure*: define if this file is present or absent
- *instance*: the name of the instance
- *owner*: the owner of this file (useful if manage=false)
- *thread_priority*: (int) the thread priority for threads in the host
- *daemon*: whether the threads should be daemon threads or not
- *name_prefix*: the prefix for each thread created by the host
- *max_threads*: (int) max number of active threads in this pool
- *min_spare_threads*: (int) minimum number of threads always kept alive
- *max_idle_time*: (int) number of milliseconds before an idle thread shutsdown
- *manage*: only add this file/host if it isn’t already present

Requires:
- one of the tomcat classes which installs tomcat binaries.
- a resource tomcat::instance.

Example usage:

  tomcat::host {"sales":
    ensure            => present,
    instance          => "tomcat1",
    domain_name       => "sales.xxx.com",
    aliases           => ["sales.xxx.org", "sales.xxx.net"],
    max_threads       => 150,
    min_spare_threads => 25,
  }

  tomcat::host {"sales":
    ensure            => present,
    instance          => "tomcat1",
    domain_name       => "sales.uhuila.com",
    aliases           => ["sales.xxx.org", "sales.xxx.net"],
    doc_base          => "/app/webapps/sales"
  }

  tomcat::instance { "tomcat1":
    ensure    => present,
    group     => "tomcat-admin",
    manage    => true,
    hosts => ["sales"]
  }

*/
define tomcat::host($ensure="present",
                        $instance,
                        $doc_base,
                        $aliases = [],
                        $owner="tomcat",
                        $group="adm",
                        $domain_name = nil,
                        $unpack_wars=true,
                        $auto_deploy=true,
                        $xml_validation=false,
                        $xml_namespace_aware=false,
                        $manage=false) {

  include tomcat::params

  if $owner == "tomcat" {
    $filemode = 0460
  } else {
    $filemode = 0664
  }

  exec { "mkdir ${doc_base} -p":
    cwd => "/tmp",
    user => "root",
    creates => "${doc_base}",
    path => ["/usr/bin", "/usr/sbin"]
  }

  file {
    "${doc_base}":
      ensure => directory,
      owner  => $owner,
      group  => $group,
      mode   => 0664,
      require => Exec["mkdir ${doc_base} -p"]
  }

  file {
    "${tomcat::params::instance_basedir}/${instance}/conf/host-${name}.xml":
      ensure  => $ensure,
      owner   => $owner,
      group   => $group,
      mode    => $filemode,
      content => template("tomcat/host.xml.erb"),
      replace => $manage,
      require => File["${tomcat::params::instance_basedir}/${instance}/conf"];
  }

}
