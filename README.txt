Problems that would need to be fixed before moving to production:
=================================================================
* Downloads Nginx directly from public repos with no version check.
  -> Should use a private repo (to save bandwidth)
  -> Should pin external dependencies to a specific version number
* No concept of dev/QA/production environments
* Unable to walk the list of /sites-available and symlink them because
   they don't exist until after the update is complete; best we can do is
   to add our own 'sites-enabled.map' file which lists the enabled sites
   and use Jinja to iterate over them, similar to how has been set up in the
   'auto_symlink_all_sites' branch (commit e9a91c845).
* There is not currently a mechanism to disable sites and remove their
   configuration files; however in same way that we iterate over sites_enabled
   it is trivial to add one that removes both the
   /sites_available and /sites_enabled components.

Things to be aware of:
======================
* Destination for nginx.conf file is templatized per-os, so install will fail
  if OS is not recognized.  (Nginx docs say the config can go into one of
  3 locations; this suggests it can change on different OS's so we use a
  template to figure out correct placement.)
* In this implementation there is explicitly no webserver/init.sls file;
  it is assumed that in production we would potentially have other webserver
  software (httpd, etc) and minions would explicitly have the server to be
  installed called out rather than having a default.

Other comments:
===============

