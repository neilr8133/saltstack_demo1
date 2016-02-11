# Known Issues

* Downloads Nginx directly from public repos with no version check.
  - Should pin external dependencies to a specific version number
  - Should use a private repo (to save bandwidth)
* No concept of dev/QA/production environments
* Unable to walk the list of `/sites-available` and symlink them because
   they don't exist until after the update is complete; best we can do is
   to add our own 'sites-enabled' list in the Pillar and use Jinja to iterate
   iterate over them.
* Turns off SELinux
  - During testing, could not get Nginx to work under SELinux (even manually),
    would need more time to understand the problem.
* Flushes/replaces the configured firewall
  - Should append to the existing firewall rules instead.
    (CentOS was found to have an extensive set of firewall rules that, among
     other things, blocked access to :8888.)


# Things to be aware of

* Destination for nginx.conf file is templatized per-os, so install will fail
  if OS is not recognized.  (Nginx docs say the config can go into one of
  3 locations; this suggests it can change on different OS's so we use a
  template to figure out correct placement.)
* In this implementation there is explicitly no webserver/init.sls file;
  it is assumed that in production we would potentially have other webserver
  software (httpd, etc) and minions would explicitly have the server to be
  installed called out rather than having a default.
* By editing `/srv/pillar/webserver/nginx.sls` we can remove previously-deployed
  server configurations by editing `nginx:lookup:sites_disabled` (currently
  set to an empty list); syntax is the same as for `nginx:lookup:sites_enabled`.


# Installation instructions

## CentOS

From https://docs.saltstack.com/en/latest/topics/installation/rhel.html:

* Import the package key:

		# rpm --import https://repo.saltstack.com/yum/redhat/7/x86_64/latest/SALTSTACK-GPG-KEY.pub

* Save the following to /etc/yum.repos.d/saltstack.repo:

		[saltstack-repo]
		name=SaltStack repo for RHEL/CentOS $releasever
		baseurl=https://repo.saltstack.com/yum/redhat/$releasever/$basearch/latest
		enabled=1
		gpgcheck=1
		gpgkey=https://repo.saltstack.com/yum/redhat/$releasever/$basearch/latest/SALTSTACK-GPG-KEY.pub

* Refresh the package-manager cache and install the minion:

		# yum clean expire-cache
		# yum update
		# yum install salt-minion

## Ubuntu 14.x

Modified from https://docs.saltstack.com/en/latest/topics/installation/ubuntu.html:

* Import the package key:

		$ wget -O - https://repo.saltstack.com/apt/ubuntu/14.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -

* Append the following to `/etc/apt/sources.list`:

		deb http://repo.saltstack.com/apt/ubuntu/14.04/amd64/latest trusty main

* Refresh the package-manager cache and install the minion:

		$ sudo apt-get update
		$ sudo apt-get install salt-minion


## Install the demo code

We will use a 'headless minion' configuration:

* Install to `/srv` using your preferred mechanism (Git, scp, etc).
* Refresh the pillar: `$ sudo salt-call --local saltutil.refresh_pillar`
* Review the state changes using `$ sudo salt-call local state.apply test=True`
  (*NOTE*: This requires the OS-level configuration parameters be set
  in `/srv/salt/webserver/nginx/map.jinja` or Salt will fail!)
* Apply the configuration using `$ sudo salt-call --local state.apply` 
