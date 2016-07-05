#!/usr/bin/env bash

# Copy the hosts file from files/hosts to /etc/hosts


# Install puppet:
wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
sudo dpkg -i puppetlabs-release-trusty.deb
rm ~/puppetlabs-release-trusty.deb
sudo apt-get update
sudo apt-get -y install puppet


# Configure the puppet agent:
# Copy files/puppet.conf to /etc/puppet/puppet.conf
sudo puppet agent --enable


# Generate the certificates, and send them to the puppet master server to be signed.
sudo puppet agent --verbose --no-daemonize --onetime


# After the certificates have been signed on the master server, initialize them:
sudo puppet agent --verbose --no-daemonize --onetime

