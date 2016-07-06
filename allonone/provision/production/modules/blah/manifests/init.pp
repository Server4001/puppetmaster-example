class blah {
  file { "/home/vagrant/blah.txt":
    ensure => "present",
    content => inline_template("This is whatever"),
    owner => "vagrant",
    group => "vagrant",
    mode => 0644,
  }
}
