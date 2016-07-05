class mediawiki {
  $wiki_db_type = "mysql"
  $wiki_db_server = "localhost"
  $wiki_db_name = "mediawiki"
  $wiki_db_user = "mediawiki"
  $wiki_db_pass = "password"
  $wiki_upgrade_key = "90ef24f503f8624e"

  $mediawiki_database_file = "/tmp/mediawiki.sql"

  $phpmysql = $osfamily ? {
    "debian" => "php5-mysql",
    default  => "php-mysql",
  }

  package { $phpmysql:
    ensure => "present",
  }

  if $osfamily == "redhat" {
    package { "php-xml":
      ensure => "present",
    }
  }

  class { "::apache":
    docroot    => "/var/www/html",
    mpm_module => "prefork",
    subscribe  => Package[$phpmysql],
  }

  class { "::apache::mod::php": }

  file { "/var/www/html/index.html":
    ensure => "absent",
  }

  # vcsrepo { "/var/www/html":
  #   ensure   => "present",
  #   provider => "git",
  #   source   => "https://github.com/wikimedia/mediawiki.git",
  #   revision => "REL1_23"
  # }

  # File["/var/www/html/index.html"] -> Vcsrepo["/var/www/html"]

  file { "mediawiki_settings":
    path    => "/var/www/html/LocalSettings.php",
    content => template("mediawiki/LocalSettings.php.erb"),
    owner   => "root",
    group   => "root",
    mode    => 0644,
  }

  # File["/var/www/html/LocalSettings.php"] <- Vcsrepo["/var/www/html"]

  file { "mediawiki_database":
    path    => $mediawiki_database_file,
    content => file("mediawiki/mediawiki.sql"),
    owner   => "root",
    group   => "root",
    mode    => 0644,
  }

  class { "::mysql::server":
    root_password => "password",
  }

  ::mysql::db { "mediawiki":
    user           => "mediawiki",
    password       => "password",
    host           => "localhost",
    grant          => ["ALL"],
    charset        => "utf8",
    collate        => "utf8_general_ci",
    ensure         => "present",
    sql            => $mediawiki_database_file,
    import_timeout => 60,
    require        => File["mediawiki_database"],
  }

  class { "::firewall": }

  firewall { "000 allow http access":
    dport   => 80,
    proto   => "tcp",
    action  => "accept",
  }
}
