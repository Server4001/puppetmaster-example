class common_packages {
    $packages = $osfamily ? {
        "redhat" => ["git", "vim-enhanced", "screen"],
        default  => ["git", "vim", "screen"],
    }

    package { $packages:
        ensure => "installed",
    }
}
