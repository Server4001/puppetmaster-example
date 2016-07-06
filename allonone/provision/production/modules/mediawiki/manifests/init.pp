class mediawiki {
  $wiki_site_name = hiera("mediawiki::wikisitename")
  $wiki_server = hiera("mediawiki::wikiserver")
  $wiki_db_type = hiera("mediawiki::dbtype")
  $wiki_db_server = hiera("mediawiki::dbserver")
  $wiki_db_name = hiera("mediawiki::dbname")
  $wiki_db_user = hiera("mediawiki::dbuser")
  $wiki_db_pass = hiera("mediawiki::dbpass")
  $wiki_upgrade_key = hiera("mediawiki::wikiupgradekey")

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

  file { "html_index_file":
    path   => "/var/www/html/index.html",
    ensure => "absent",
  }

  vcsrepo { "mediawiki":
    name     => "/var/www/html",
    ensure   => "present",
    owner    => "root",
    group    => "root",
    provider => "git",
    source   => "https://github.com/wikimedia/mediawiki.git",
    revision => "REL1_23",
    require  => File["html_index_file"],
  }

  file { "mediawiki_settings":
    path    => "/var/www/html/LocalSettings.php",
    content => template("mediawiki/LocalSettings.php.erb"),
    owner   => "root",
    group   => "root",
    mode    => 0644,
    require => Vcsrepo["mediawiki"],
  }

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
