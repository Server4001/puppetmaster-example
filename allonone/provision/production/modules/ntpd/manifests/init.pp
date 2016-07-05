class ntpd {
    $ntpservice = $osfamily ? {
        "redhat" => "ntpd",
        default  => "ntp",
    }

    package { "ntp":
        ensure => "installed",
    }

    service { $ntpservice:
        ensure  => "running",
        enable  => true,
        require => Package["ntp"],
    }
}
