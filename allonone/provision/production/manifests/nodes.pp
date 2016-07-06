node "wiki" {
  class { "ntpd": }
  class { "common_packages": }
  class { "mediawiki": }
}

node "wikitest" {
  class { "ntpd": }
  class { "common_packages": }
  class { "mediawiki": }
}
