#!/usr/bin/env bash
# After booting the puppet master server for the first time, I ssh'd in an ran these commands:

# Install pre-reqs:
sudo yum install -y vim git ntp tree
sudo service ntpd start
sudo chkconfig ntpd on


# Install Ruby:
sudo yum install -y ruby-devel ruby rubygems


# Install Passenger and it's dependencies:
sudo gem install rake -v 10.5.0
sudo gem install rack -v 1.6.4
sudo gem install passenger -v 5.0.29


# Install Apache:
sudo yum install -y httpd


# Install Puppet:
sudo rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
sudo yum install -y puppet


# Install puppet master server:
sudo yum install -y puppet-server
puppet master --version # 3.8.7


# Setting up the directory environments:
sudo mkdir -p /etc/puppet/environments/production/{modules,manifests}
sudo vim /etc/puppet/environments/production/environment.conf # Add in the contents of files/environment.conf
sudo vim /etc/puppet/puppet.conf # Add in the contents of files/puppet.conf


# Setting SELinux to permissive mode:
sudo setenforce permissive
# Ensuring the system boots SELinux in permissive mode:
sudo sed -i 's\=enforcing\=permissive\g' /etc/sysconfig/selinux


# Generate the SSL certificates used by puppet master:
# Start puppet master. Each time master boots up, it checks if the certs exist. If not, then master creates them.
sudo puppet master --verbose --no-daemonize


# Make sure iptables allows puppet to accept requests on port 8140. NOTE: I did not have to do this because iptables
# is disabled, but it would probably be useful for a production environment.
sudo vim /etc/sysconfig/iptables # See the contents of files/iptables as an example.
sudo service iptables restart


# Puppet master is a ruby on rails app, so we need to setup Apache and Phusion Passenger:
sudo yum -y install httpd-devel mod_ssl gcc gcc-c++ libcurl-devel openssl-devel
sudo passenger-install-apache2-module
# [Press enter]
# [Ensure that ruby is the only thing selected and press enter]
# When the install completes, it will give you a snippet to add to your apache configuration. Use this to update the config at: files/puppetmaster.conf

# Creating configuration for puppet master:
sudo mkdir -p /usr/share/puppet/rack/puppetmasterd/{public,tmp}
sudo cp /usr/share/puppet/ext/rack/config.ru /usr/share/puppet/rack/puppetmasterd/
sudo chown puppet:puppet /usr/share/puppet/rack/puppetmasterd/config.ru


# Creating configuration for Apache:
# After you have updated files/puppetmaster.conf with the snippet obtained via the passenger apache module install, copy it to: /etc/httpd/conf.d/puppetmaster.conf


# Start Apache, and thus the puppet master server:
sudo service httpd start
sudo chkconfig httpd on


# After setting up the agent on the other centos and ubuntu server, and sending the certificate sign requests, we signed the certificates:
sudo puppet cert sign wiki
sudo puppet cert sign wikitest


# Copy allonone/provision/production/manifests to /etc/puppet/environments/production/manifests
# Copy allonone/provision/production/modules to /etc/puppet/environments/production/modules


# Setting up Hiera:
# Copy the contents of files/hiera.yaml to: /etc/puppet/hiera.yaml. This will require a restart of httpd.
sudo service httpd restart
# Copy allonone/provision/production/hiera/wiki.yaml to /var/lib/hiera/wiki.yaml
# Copy allonone/provision/production/hiera/wikitest.yaml to /var/lib/hiera/wikitest.yaml
# Copy allonone/provision/production/hiera/wikidefault.yaml to /var/lib/hiera/wikidefault.yaml
