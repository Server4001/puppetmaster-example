#!/usr/bin/env bash
# After booting the puppet master server for the first time, I ssh'd in an ran these commands:

# Install pre-reqs:
sudo yum install -y vim git ntp tree
sudo service ntpd start
sudo chkconfig ntpd on


# Install Ruby, Puppet, and r10k:
sudo su
command curl -sSL https://rvm.io/mpapis.asc | sudo gpg2 --import -
curl -sSL https://get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh
rvm requirements
rvm install 2.0.0
rvm use 2.0.0 --default
mkdir /root/puppet-source
cp /vagrant/puppet_source/*.tar.gz /root/puppet-source/
cd ~/puppet-source/
tar -zxvf hiera-3.2.1.tar.gz
tar -zxvf puppet-3.8.7.tar.gz
rm -rf *.tar.gz
cd hiera-3.2.1/
ruby install.rb
cd ..
cd puppet-3.8.7/
gem install facter
ruby install.rb
puppet resource group puppet ensure=present
puppet resource user puppet ensure=present gid=puppet shell='/sbin/nologin'
cp /vagrant/puppet_source/puppetmaster.init.d /etc/init.d/puppetmaster
chmod 755 /etc/init.d/puppetmaster
mv /etc/init.d/puppetmaster /etc/init.d/puppet
gem install r10k
exit


# Install Passenger and it's dependencies:
sudo su
gem install rake -v 10.5.0
gem install rack -v 1.6.4
gem install passenger -v 5.0.29
exit


# Install Apache:
sudo yum install -y httpd


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
sudo su
puppet master --verbose --no-daemonize
exit


# Make sure iptables allows puppet to accept requests on port 8140. NOTE: I did not have to do this because iptables
# is disabled, but it would probably be useful for a production environment.
sudo vim /etc/sysconfig/iptables # See the contents of files/iptables as an example.
sudo service iptables restart


# Puppet master is a ruby on rails app, so we need to setup Apache and Phusion Passenger:
sudo yum -y install httpd-devel mod_ssl gcc gcc-c++ libcurl-devel openssl-devel
sudo su
passenger-install-apache2-module
# [Press enter]
# [Ensure that ruby is the only thing selected and press enter]
# When the install completes, it will give you a snippet to add to your apache configuration. Use this to update the config at: files/puppetmaster.conf
exit

# Creating configuration for puppet master:
sudo mkdir -p /usr/share/puppet/rack/puppetmasterd/{public,tmp}

# If config.ru is not present, copy files/config-rack.ru, which I got from:
# https://github.com/puppetlabs/puppet/blob/3.8.7/ext/rack/config.ru
sudo cp /usr/share/puppet/ext/rack/config.ru /usr/share/puppet/rack/puppetmasterd/
sudo chown puppet:puppet /usr/share/puppet/rack/puppetmasterd/config.ru


# Creating configuration for Apache:
# After you have updated files/puppetmaster.conf with the snippet obtained via the passenger apache module install, copy it to: /etc/httpd/conf.d/puppetmaster.conf


# Start Apache, and thus the puppet master server:
sudo service httpd start
sudo chkconfig httpd on


# After setting up the agent on the other centos and ubuntu server, and sending the certificate sign requests, we signed the certificates:
sudo su
puppet cert sign wiki
puppet cert sign wikitest
exit


# Copy allonone/provision/production/manifests to /etc/puppet/environments/production/manifests
# Copy allonone/provision/production/modules to /etc/puppet/environments/production/modules


# Setting up Hiera:
# Copy the contents of files/hiera.yaml to: /etc/puppet/hiera.yaml. This will require a restart of httpd.
sudo service httpd restart
# Copy allonone/provision/production/hiera/wiki.yaml to /var/lib/hiera/wiki.yaml
# Copy allonone/provision/production/hiera/wikitest.yaml to /var/lib/hiera/wikitest.yaml
# Copy allonone/provision/production/hiera/wikidefault.yaml to /var/lib/hiera/wikidefault.yaml
