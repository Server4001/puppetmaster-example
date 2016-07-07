#!/usr/bin/env bash

# Copy the hosts file from files/hosts to /etc/hosts


# Install puppet. Remember, the box comes with puppet 3.8.7 installed.
sudo rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
sudo yum install -y puppet

# Edit the puppet agent configuration:
# Copy the contents of files/puppet.conf to /etc/puppet/puppet.conf


# Generate the certificates, and send them to the puppet master server to be signed.
sudo puppet agent --verbose --no-daemonize --onetime


# After the certificates have been signed on the master server, initialize them:
sudo puppet agent --verbose --no-daemonize --onetime

# After configuring the agent to run automatically, we must start the service and configure it to start at server boot:
sudo chkconfig puppet on
sudo service puppet start
