# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions
alias ll="ls -lah"
alias deploy="sudo rm -rf /etc/puppet/environments/production/manifests && sudo rm -rf /etc/puppet/environments/production/modules && sudo cp -R /vagrant/provision/production/manifests /etc/puppet/environments/production/manifests && sudo cp -R /vagrant/provision/production/modules /etc/puppet/environments/production/modules"
