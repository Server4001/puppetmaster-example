node "wiki" {
  $wiki_site_name = "Wiki"
  $wiki_server = "http://dev.puppet-fundamentals-centos.loc"

  class { "ntpd": }
  class { "common_packages": }
  class { "mediawiki": }
}

node "wikitest" {
  $wiki_site_name = "Wiki Test"
  $wiki_server = "http://dev.puppet-fundamentals-ubuntu.loc"

  class { "ntpd": }
  class { "common_packages": }
  class { "mediawiki": }
}
